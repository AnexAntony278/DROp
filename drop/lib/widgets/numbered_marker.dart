import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> createNumberedMarker(int number, Color color) async {
  const int size = 23; // Marker size in pixels
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  const double radius = size / 2.2; // Outer circle radius
  const double strokeWidth = 3.0; // Stroke thickness

  final Paint strokePaint = Paint()
    ..color =
        const ui.Color.fromARGB(255, 1, 40, 53) // Stroke color (same as number)
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth;

  final Paint fillPaint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  // Draw Circle Outline (Stroke First, So It Goes Inside)
  canvas.drawCircle(
      const Offset(size / 2, size / 2), radius - strokeWidth / 2, strokePaint);

  // Draw Filled Circle (Slightly Smaller To Keep Stroke Inside)
  canvas.drawCircle(
      const Offset(size / 2, size / 2), radius - strokeWidth, fillPaint);

  // Draw Number
  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: number.toString(),
      style: const TextStyle(
        fontSize: size / 2,
        fontWeight: FontWeight.bold,
        color: ui.Color.fromARGB(255, 1, 40, 53), // Number color
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2));

  final ui.Image img = await recorder.endRecording().toImage(size, size);
  final ByteData? byteData =
      await img.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List byteList = byteData!.buffer.asUint8List();

  return BitmapDescriptor.bytes(byteList);
}
