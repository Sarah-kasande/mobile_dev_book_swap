import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BookCoverGenerator {
  static Future<String> generateBookCover({
    required String title,
    required String author,
    Color? backgroundColor,
    Color? textColor,
  }) async {
    // Create a custom painter to generate book cover
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(200, 300);
    
    // Background
    final backgroundPaint = Paint()
      ..color = backgroundColor ?? _getColorFromTitle(title);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
    
    // Add a gradient overlay
    final gradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.black.withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gradient);
    
    // Title text
    final titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    titlePainter.layout(maxWidth: size.width - 20);
    titlePainter.paint(canvas, Offset(10, size.height * 0.3));
    
    // Author text
    final authorPainter = TextPainter(
      text: TextSpan(
        text: 'by $author',
        style: TextStyle(
          color: (textColor ?? Colors.white).withOpacity(0.8),
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    authorPainter.layout(maxWidth: size.width - 20);
    authorPainter.paint(canvas, Offset(10, size.height * 0.7));
    
    // Create image
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    
    return base64Encode(bytes);
  }
  
  static Color _getColorFromTitle(String title) {
    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.purple.shade600,
      Colors.orange.shade600,
      Colors.red.shade600,
      Colors.teal.shade600,
      Colors.indigo.shade600,
      Colors.brown.shade600,
    ];
    
    final hash = title.hashCode;
    return colors[hash.abs() % colors.length];
  }
}
