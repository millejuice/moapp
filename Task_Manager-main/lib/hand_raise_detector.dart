import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:permission_handler/permission_handler.dart';

class HandRaiseDetector extends StatefulWidget {
  final VoidCallback onHandRaised;
  final VoidCallback onClose;

  const HandRaiseDetector({
    Key? key,
    required this.onHandRaised,
    required this.onClose,
  }) : super(key: key);

  @override
  State<HandRaiseDetector> createState() => _HandRaiseDetectorState();
}

class _HandRaiseDetectorState extends State<HandRaiseDetector> {
  CameraController? _cameraController;
  PoseDetector? _poseDetector;
  bool _isDetecting = false;
  bool _hasPermission = false;
  String _statusMessage = '카메라 권한을 확인하는 중...';
  DateTime? _lastProcessTime;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    PermissionStatus status;
    try {
      // 카메라 권한 상태 확인
      status = await Permission.camera.status;
      
      // 권한이 없거나 거부된 경우 요청
      if (status.isDenied || status.isRestricted) {
        setState(() {
          _statusMessage = '카메라 권한을 요청하는 중...';
        });
        status = await Permission.camera.request();
      }
      
      // 권한이 영구적으로 거부된 경우 설정으로 이동 안내
      if (status.isPermanentlyDenied) {
        setState(() {
          _statusMessage = '카메라 권한이 거부되었습니다.\n설정에서 권한을 허용해주세요.';
          _hasPermission = false;
        });
        return;
      }
      
      if (!status.isGranted) {
        setState(() {
          _statusMessage = '카메라 권한이 필요합니다.\n아래 버튼을 눌러 권한을 허용해주세요.';
          _hasPermission = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('Permission error: $e');
      setState(() {
        _statusMessage = '권한 확인 중 오류가 발생했습니다.\n앱을 완전히 재시작해주세요.';
        _hasPermission = false;
      });
      return;
    }

    setState(() {
      _hasPermission = true;
      _statusMessage = '카메라를 초기화하는 중...';
    });

    // 카메라 초기화
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() {
        _statusMessage = '카메라를 찾을 수 없습니다.';
      });
      return;
    }

    // 전면 카메라 우선 사용 (selfie)
    CameraDescription? selectedCamera;
    for (var camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.front) {
        selectedCamera = camera;
        break;
      }
    }
    selectedCamera ??= cameras[0]; // 전면 카메라가 없으면 첫 번째 카메라 사용

    _cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    // 카메라 프리뷰가 먼저 표시되도록 setState
    setState(() {
      _statusMessage = '양손을 들어주세요! 🙌';
      _isDetecting = true;
    });

    // 프리뷰가 완전히 렌더링될 때까지 대기
    await Future.delayed(const Duration(milliseconds: 500));

    // ML Kit Pose Detector 초기화
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream, // 스트림 모드로 변경
      model: PoseDetectionModel.accurate,
    );
    _poseDetector = PoseDetector(options: options);

    // 이미지 스트림 시작 (프리뷰와 함께 작동)
    _startDetection();
  }

  Future<void> _startDetection() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || !_isDetecting) {
      return;
    }

    // 프리뷰가 완전히 준비될 때까지 대기 (에뮬레이터에서는 더 오래 걸릴 수 있음)
    await Future.delayed(const Duration(milliseconds: 1500));

    // 프리뷰가 실제로 렌더링되었는지 확인
    if (_cameraController == null || !_cameraController!.value.isInitialized || !_isDetecting) {
      debugPrint('⚠️ 카메라가 초기화되지 않았거나 감지가 중지되었습니다');
      return;
    }

    // 이미 스트림이 실행 중이면 중지
    if (_cameraController!.value.isStreamingImages) {
      debugPrint('⚠️ 이미지 스트림이 이미 실행 중입니다. 중지 후 재시작...');
      try {
        await _cameraController!.stopImageStream();
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        debugPrint('⚠️ 기존 스트림 중지 중 오류: $e');
      }
    }

    try {
      debugPrint('📸 이미지 스트림 시작 중...');
      await _cameraController!.startImageStream((CameraImage image) {
        // 리소스가 해제되었는지 확인
        if (!_isDetecting || _cameraController == null) {
          return;
        }
        // 비동기로 처리하여 스트림이 블로킹되지 않도록 함
        _processImage(image).catchError((e) {
          debugPrint('⚠️ 이미지 처리 오류: $e');
        });
      });
      debugPrint('✅ 이미지 스트림 시작 성공');
    } catch (e) {
      debugPrint('⚠️ 이미지 스트림 시작 실패: $e');
    }
  }

  Future<void> _processImage(CameraImage image) async {
    // 리소스가 해제되었는지 확인
    if (_poseDetector == null || !_isDetecting || _cameraController == null) {
      return;
    }

    // 이미지 처리 빈도 제한 (1초마다 한 번씩만 처리하여 성능 개선)
    final now = DateTime.now();
    if (_lastProcessTime != null && 
        now.difference(_lastProcessTime!).inMilliseconds < 1000) {
      return;
    }
    _lastProcessTime = now;

    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      return;
    }

    try {
      // 리소스가 해제되었는지 다시 확인
      if (!_isDetecting || _poseDetector == null) {
        return;
      }
      
      final poses = await _poseDetector!.processImage(inputImage);
      
      // 리소스가 해제되었는지 최종 확인
      if (!_isDetecting || _poseDetector == null) {
        return;
      }
      
      if (poses.isNotEmpty) {
        final pose = poses.first;
        
        if (_isHandRaised(pose)) {
          debugPrint('✅ 손을 든 것을 감지했습니다!');
          setState(() {
            _isDetecting = false;
            _statusMessage = '성공! 손을 들었습니다! ✅';
          });
          
          // 이미지 스트림 즉시 중지
          try {
            if (_cameraController != null && _cameraController!.value.isStreamingImages) {
              await _cameraController!.stopImageStream();
            }
          } catch (e) {
            debugPrint('⚠️ 이미지 스트림 중지 중 오류: $e');
          }
          
          await Future.delayed(const Duration(milliseconds: 500));
          widget.onHandRaised();
        }
      }
    } catch (e) {
      debugPrint('❌ Pose detection error: $e');
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    try {
      // YUV_420_888 포맷의 경우 올바른 순서로 변환
      InputImageFormat format;
      Uint8List bytes;
      
      if (image.format.raw == 35) {
        // NV21 포맷
        format = InputImageFormat.nv21;
        final List<int> allBytes = [];
        for (final Plane plane in image.planes) {
          allBytes.addAll(plane.bytes);
        }
        bytes = Uint8List.fromList(allBytes);
      } else if (image.format.raw == 17) {
        // YUV_420_888 포맷 - Y, U, V plane을 올바른 순서로 결합
        format = InputImageFormat.yuv_420_888;
        final yPlane = image.planes[0];
        final uPlane = image.planes[1];
        final vPlane = image.planes[2];
        
        final yBytes = yPlane.bytes;
        final uBytes = uPlane.bytes;
        final vBytes = vPlane.bytes;
        
        // Y plane + U plane + V plane 순서로 결합
        final List<int> allBytes = [];
        allBytes.addAll(yBytes);
        allBytes.addAll(uBytes);
        allBytes.addAll(vBytes);
        bytes = Uint8List.fromList(allBytes);
      } else {
        // 기타 포맷 (BGRA 등)
        format = InputImageFormat.bgra8888;
        final List<int> allBytes = [];
        for (final Plane plane in image.planes) {
          allBytes.addAll(plane.bytes);
        }
        bytes = Uint8List.fromList(allBytes);
      }

      final imageRotation = InputImageRotation.rotation90deg;

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: imageRotation,
          format: format,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } catch (e) {
      debugPrint('❌ 이미지 변환 오류: $e');
      return null;
    }
  }


  bool _isHandRaised(Pose pose) {
    // 양손 어깨와 손목 위치 확인
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

    if (leftWrist == null || rightWrist == null || 
        leftShoulder == null || rightShoulder == null) {
      return false;
    }

    // 양손이 어깨보다 위에 있는지 확인
    final leftHandRaised = leftWrist.y < leftShoulder.y;
    final rightHandRaised = rightWrist.y < rightShoulder.y;

    // 양손 모두 들어야 성공
    return leftHandRaised && rightHandRaised;
  }

  @override
  void dispose() {
    debugPrint('🧹 HandRaiseDetector 리소스 정리 시작');
    
    // 감지 중지
    _isDetecting = false;
    
    // 이미지 스트림 중지 및 카메라 해제
    _disposeCamera();
    
    // ML Kit 리소스 해제
    _poseDetector?.close();
    _poseDetector = null;
    
    super.dispose();
    debugPrint('✅ HandRaiseDetector 리소스 정리 완료');
  }

  Future<void> _disposeCamera() async {
    if (_cameraController == null) return;
    
    try {
      // 이미지 스트림이 실행 중이면 먼저 중지
      if (_cameraController!.value.isStreamingImages) {
        debugPrint('📸 이미지 스트림 중지 중...');
        await _cameraController!.stopImageStream();
        debugPrint('✅ 이미지 스트림 중지 완료');
      }
      
      // 카메라 컨트롤러 해제
      await _cameraController!.dispose();
      _cameraController = null;
      debugPrint('✅ 카메라 컨트롤러 해제 완료');
    } catch (e) {
      debugPrint('⚠️ 카메라 해제 중 오류: $e');
      // 오류가 발생해도 강제로 null로 설정
      _cameraController = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 카메라 프리뷰 - 수정된 버전
          if (_cameraController != null && 
              _cameraController!.value.isInitialized &&
              _cameraController!.value.previewSize != null)
            Positioned.fill(
              child: OverflowBox(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _cameraController!.value.previewSize!.height,
                    height: _cameraController!.value.previewSize!.width,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              ),
            )
          else if (_cameraController != null && _cameraController!.value.isInitialized)
            // previewSize가 null인 경우 기본 프리뷰 사용
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFFFF7B31),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _statusMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!_hasPermission && _statusMessage.contains('권한'))
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              final status = await Permission.camera.request();
                              if (status.isGranted) {
                                await _initializeCamera();
                              } else if (status.isPermanentlyDenied) {
                                setState(() {
                                  _statusMessage = '카메라 권한이 거부되었습니다.\n설정에서 권한을 허용해주세요.';
                                });
                                await openAppSettings();
                              } else {
                                setState(() {
                                  _statusMessage = '카메라 권한이 필요합니다.\n다시 시도해주세요.';
                                });
                              }
                            } catch (e) {
                              debugPrint('Permission request error: $e');
                              setState(() {
                                _statusMessage = '권한 요청 중 오류가 발생했습니다.\n앱을 완전히 재시작해주세요.';
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7B31),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                          ),
                          child: const Text(
                            '권한 허용',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // 상단 안내 메시지 - 반투명 배경 추가
          if (_cameraController != null && _cameraController!.value.isInitialized)
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _statusMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '양손을 어깨 위로 들어주세요!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          // 닫기 버튼
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: widget.onClose,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

