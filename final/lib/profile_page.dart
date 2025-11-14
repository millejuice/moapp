import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'package:shrine/services/user_profile_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = AuthService();

    // Provide the UserProfileProvider for this page and load the user doc
    if (user != null) {
      // ensure provider is available
      final provider = Provider.of<UserProfileProvider>(context, listen: false);
      // load only if not already loaded
      if (provider.data == null) {
        provider.load(user.uid);
      }
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('로그인이 필요합니다.')),
      );
    }

  // Determine user info based on login method and Firestore user doc when available
  final isAnonymous = user.isAnonymous;
  final profilePhotoUrl = isAnonymous
    ? 'http://handong.edu/site/handong/res/img/logo.png'
    : user.photoURL ?? 'http://handong.edu/site/handong/res/img/logo.png';
  final email = isAnonymous ? 'Anonymous' : (user.email ?? 'Anonymous');
  final displayName = isAnonymous ? 'Guest User' : (user.displayName ?? 'User');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Profile Photo
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: ClipOval(
                child: Image.network(
                  profilePhotoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.person, size: 100);
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            // UID
            Text(
              user.uid,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Email
            Text(
              email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            // Name
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            // Status message / Honor Code (from Firestore when available)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Consumer<UserProfileProvider>(
                builder: (context, profileProvider, _) {
                  final data = profileProvider.data;
                  final status = data != null && data['status_message'] != null
                      ? data['status_message'] as String
                      : 'I promise to take the test honestly before GOD.';

                  if (profileProvider.isEditing) {
                    final controller = TextEditingController(text: status);
                    return Column(
                      children: [
                        TextField(
                          controller: controller,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final success = await profileProvider.save(user.uid, controller.text);
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Saved')),
                                  );
                                }
                              },
                              child: const Text('Save'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () => profileProvider.stopEditing(),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Text(
                        status,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => profileProvider.startEditing(),
                        child: const Text('Edit'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

