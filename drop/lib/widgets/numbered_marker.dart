import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> createNumberedMarker(int number, Color color) async {
  const int size = 23;
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  const double radius = size / 2.2;
  const double strokeWidth = 1.8;

  final Paint strokePaint = Paint()
    ..color = const ui.Color.fromARGB(255, 22, 125, 159)
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth;

  final Paint fillPaint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  canvas.drawCircle(
      const Offset(size / 2, size / 2), radius - strokeWidth / 2, strokePaint);

  canvas.drawCircle(
      const Offset(size / 2, size / 2), radius - strokeWidth, fillPaint);

  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: number.toString(),
      style: const TextStyle(
        fontSize: size / 2,
        fontWeight: FontWeight.bold,
        color: ui.Color.fromARGB(255, 1, 40, 53),
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

Future<BitmapDescriptor> createRedMarker() async {
  const int size = 23;
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  const double strokeWidth = 1.0;
  final Paint strokePaint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth;

  final Paint fillPaint = Paint()..color = Colors.red;

  canvas.drawCircle(const Offset(size / 2, size / 2),
      size / 2.2 - strokeWidth / 2, strokePaint);
  canvas.drawCircle(
      const Offset(size / 2, size / 2), size / 2.2 - strokeWidth, fillPaint);

  final ui.Image img = await recorder.endRecording().toImage(size, size);
  final ByteData? byteData =
      await img.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
}

Future<BitmapDescriptor> createFlutterIconMarker(
    IconData icon, Color color, double size) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: icon.fontFamily,
        color: color,
      ),
    ),
    textDirection: TextDirection.ltr,
  );

  textPainter.layout();
  textPainter.paint(canvas, const Offset(0, 0));

  final ui.Image img =
      await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final ByteData? byteData =
      await img.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
}
