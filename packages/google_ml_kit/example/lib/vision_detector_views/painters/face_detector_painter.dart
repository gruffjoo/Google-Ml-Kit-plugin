import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'coordinates_translator.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.faces, this.absoluteImageSize, this.rotation);

  final List<Face> faces;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.green;
    final Paint paintEye = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0
      ..color = Colors.red;
    final Paint paintMouth = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 10.0
      ..color = Colors.blue;
    
    for (final Face face in faces) {
      
      canvas.drawRect(
        Rect.fromLTRB(
          translateX(face.boundingBox.left, rotation, size, absoluteImageSize),
          translateY(face.boundingBox.top, rotation, size, absoluteImageSize),
          translateX(face.boundingBox.right, rotation, size, absoluteImageSize),
          translateY(
              face.boundingBox.bottom, rotation, size, absoluteImageSize),
        ),
        paint,
      );

      void paintContour(FaceContourType type) {
        final faceContour = face.contours[type];
        if (faceContour?.points != null) {
          for (final Point point in faceContour!.points) {
            canvas.drawCircle(
                Offset(
                  translateX(
                      point.x.toDouble(), rotation, size, absoluteImageSize),
                  translateY(
                      point.y.toDouble(), rotation, size, absoluteImageSize),
                ),
                1,
                paint);
          }
        }
      }

      void paintContourMouth(FaceContourType type) {
        final faceContour = face.contours[type];
        if (faceContour?.points != null) {
          for (final Point point in faceContour!.points) {
            canvas.drawCircle(
                Offset(
                  translateX(
                      point.x.toDouble(), rotation, size, absoluteImageSize),
                  translateY(
                      point.y.toDouble(), rotation, size, absoluteImageSize),
                ),
                1,
                paintMouth);
          }
        }
      }

      void paintContourEye(FaceContourType type) {
        final faceContour = face.contours[type];
        if (faceContour?.points != null) {
          for (final Point point in faceContour!.points) {
            canvas.drawCircle(
                Offset(
                  translateX(
                      point.x.toDouble(), rotation, size, absoluteImageSize),
                  translateY(
                      point.y.toDouble(), rotation, size, absoluteImageSize),
                ),
                1,
                paintEye);
          }
        }
      }

      paintContour(FaceContourType.face);
      paintContour(FaceContourType.leftEyebrowTop);
      paintContour(FaceContourType.leftEyebrowBottom);
      paintContour(FaceContourType.rightEyebrowTop);
      paintContour(FaceContourType.rightEyebrowBottom);
      paintContourEye(FaceContourType.leftEye);
      paintContourEye(FaceContourType.rightEye);
      paintContourMouth(FaceContourType.upperLipTop);
      paintContour(FaceContourType.upperLipBottom);
      paintContour(FaceContourType.lowerLipTop);
      paintContourMouth(FaceContourType.lowerLipBottom);
      paintContour(FaceContourType.noseBridge);
      paintContour(FaceContourType.noseBottom);
      paintContour(FaceContourType.leftCheek);
      paintContour(FaceContourType.rightCheek);
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.faces != faces;
  }
}
