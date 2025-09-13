import 'package:flutter/material.dart';
import 'package:hw1/favorite_widget.dart';
import 'package:hw1/image_section.dart';
import 'package:hw1/text_section.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'Flutter layout demo';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        // appBar: AppBar(title: const Text(appTitle)),
        body: Center(
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: const [
              ImageSection(
    image: 'images/lake.jpg',
  ),
              TitleSection(
                name: '천주현',
                location: '22000747',
              ),
              Divider(height: 1.0,color: Colors.black,),
              ButtonSection(),
              Divider(height: 1.0,color: Colors.black,),
              Row(
  crossAxisAlignment: CrossAxisAlignment.start, 
  children: [
    SizedBox(width: 24,),
     Padding(
      padding: EdgeInsets.only(left: 16.0, top: 12.0),
      child: Icon(Icons.message, size: 40),
    ),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          TextSection(
            description: 'Recent Message',
            padding:  EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0), 
            style:  TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSection(
            description: 'Long time no see!',
            padding:  EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),  
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ),
  ],
),
             
            ],
          ),
        ),
      ),
    );
  }
}

class TitleSection extends StatelessWidget {
  const TitleSection({super.key, required this.name, required this.location});

  final String name;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(location, style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          ),
          /*3*/
          const FavoriteWidget(),
        ],
      ),
    );
  }
}

class ButtonSection extends StatelessWidget {
  const ButtonSection({super.key});

   @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          ButtonWithText(color: Colors.black, icon: Icons.call, label: 'CALL'),
          ButtonWithText(color: Colors.black, icon: Icons.message, label: 'MESSAGE'),
          ButtonWithText(color: Colors.black, icon: Icons.email, label: 'EMAIL'),
          ButtonWithText(color: Colors.black, icon: Icons.share, label: 'SHARE'),
          ButtonWithText(color: Colors.black, icon: Icons.description, label: 'ETC'),
        ],
      ),
    );
  }
}

class ButtonWithText extends StatelessWidget {
  const ButtonWithText({
    super.key,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}