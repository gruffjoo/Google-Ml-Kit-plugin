import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'camera_view.dart';
import 'painters/face_detector_painter.dart';
import 'painters/pose_painter.dart';

class FaceDetectorView extends StatefulWidget {
  @override
  _FaceDetectorViewState createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  CustomPaint? _customPaint2;
  String? _text;
  Faces_list? _facesList;
  List<Face>? faces;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CameraView(
          title: 'Joo Pose Face Detector',
          customPaint: _customPaint,
          customPaint2: _customPaint2,
          text: _text,
          onImage: (inputImage) {
            processImage(inputImage);
          },
          initialDirection: CameraLensDirection.front,
        ),
        _facesList?.faces != null
            ? ListView.builder(
                itemCount: _facesList?.faces.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: Column(
                      children: [
                        Text(
                          '${_facesList?.faces[index].contours.entries.first.value?.points.first}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '${_facesList?.faces[index].headEulerAngleZ.toString()}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '${_facesList?.faces[index].headEulerAngleX.toString()}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                },
              )
            : Container(),
        // Center(
        //   child: Text(
        //     'Joo Pose Face Detector',
        //     style: TextStyle(
        //       fontSize: 30,
        //       fontWeight: FontWeight.bold,
        //       color: Colors.white,
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final faces = await _faceDetector.processImage(inputImage);
    // print(faces[0].headEulerAngleX);

    final poses = await _poseDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
      final painter2 = PosePainter(poses, inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint2 = CustomPaint(painter: painter2);
      _facesList = Faces_list(
        faces: faces,
      );
    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
      _customPaint2 = null;
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

// ignore: camel_case_types
class Faces_list extends StatelessWidget {
  const Faces_list({
    Key? key,
    required this.faces,
    this.contours,
  }) : super(key: key);
  final List<Face> faces;

  final List<FaceContour>? contours;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: faces.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Face ${index + 1}'),
          subtitle: Text(
            'Bounding box: ${faces[index].boundingBox}',
            style: TextStyle(fontSize: 10),
          ),
        );
      },
    );
  }
}
