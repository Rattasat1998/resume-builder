import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Service to convert Flutter widget to PDF
/// This ensures the preview and exported PDF look exactly the same
class WidgetToPdfService {
  /// Capture a widget using GlobalKey and convert to PDF
  Future<Uint8List> generatePdfFromWidget(GlobalKey key) async {
    // Capture widget as image
    final imageBytes = await _captureWidget(key);
    if (imageBytes == null) {
      throw Exception('Failed to capture widget');
    }

    // Create PDF with the image
    final pdf = pw.Document();
    final image = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.FullPage(
            ignoreMargins: true,
            child: pw.Image(image, fit: pw.BoxFit.contain),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Capture widget as PNG bytes with high quality
  Future<Uint8List?> _captureWidget(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('RenderRepaintBoundary not found');
        return null;
      }

      // Wait for the boundary to be ready
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Use pixel ratio of 4.0 for high quality PDF (300 DPI equivalent)
      // A4 at 72 DPI = 595x842, at 300 DPI = 2480x3508
      final image = await boundary.toImage(pixelRatio: 4.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        debugPrint('Failed to get byte data from image');
        return null;
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing widget: $e');
      return null;
    }
  }

  /// Generate PDF from image bytes directly
  Future<Uint8List> generatePdfFromImageBytes(Uint8List imageBytes) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.FullPage(
            ignoreMargins: true,
            child: pw.Image(image, fit: pw.BoxFit.contain),
          );
        },
      ),
    );

    return pdf.save();
  }
}

