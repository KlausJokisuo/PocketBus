import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//Nexus5X
//Every widget that uses screenAwareSize
const double baseHeight = 592.0;
const double baseWidth = 360.0;

double screenAwareHeight(double size, BuildContext context) {
  final double drawingHeight = MediaQuery.of(context).size.height -
      MediaQuery.of(context).padding.vertical;

//  debugPrint('Widget: ' + MediaQuery.of(context).toString());
//  debugPrint('Widget: ' + context.widget.toString());
//  debugPrint('drawingHeight: ' + drawingHeight.toString());
//  debugPrint('Original size ' + size.toString());
//  debugPrint('Scaled size ' + (size * drawingHeight / baseHeight).toString());
  return size * drawingHeight / baseHeight;
}

double screenAwareWidth(double width, BuildContext context) {
  final double drawingWidth = MediaQuery.of(context).size.width -
      MediaQuery.of(context).padding.horizontal;

//  debugPrint('Widget: ' + MediaQuery.of(context).toString());
//  debugPrint('Widget: ' + context.widget.toString());
//  debugPrint('drawingWidth: ' + drawingWidth.toString());
//  debugPrint('Original size ' + width.toString());
//  debugPrint('Scaled size ' + (width * drawingWidth / baseWidth).toString());
  return width * drawingWidth / baseWidth;
}

// Reads api-keys file into Map<String, String>.
Future<Map<String, String>> readApiKeys(String filePath) async {
  return rootBundle.loadStructuredData(filePath, (String data) async {
    final List<String> lines = const LineSplitter().convert(data);

    final keysMap = <String, String>{};

    for (final line in lines) {
      final List<String> apiValues = line.split('=');
      keysMap.putIfAbsent(apiValues[0], () => apiValues[1]);
    }

    return keysMap;
  });
}

//'images/icons8-bus-48.png'
///Creates a custom bus marker. Currently specified to 'images/icons8-bus-48.png'
Future<ui.Image> _getImageFromAsset(String assetImagePath) async {
  final ByteData imageData = await rootBundle.load(assetImagePath);
  final Uint8List lst = Uint8List.view(imageData.buffer);
  final ui.Codec codec = await ui.instantiateImageCodec(lst);
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

Future<ByteData> customBusMarkerData(
    String assetImagePath, String busNumber) async {
  final Offset imageOffset =
      Offset(18.0 + (2.5 * (busNumber.length - 1.0)), 50);
  final Offset textOffset =
      Offset(39.5 - (12.75 * (busNumber.length - 1.0)), 0.0);

  final ui.PictureRecorder recorder = ui.PictureRecorder();

  final Canvas canvas = Canvas(recorder);

  final Paint imagePaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high;

  final Paint rectPaint = Paint()
    ..color = Colors.white
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..filterQuality = FilterQuality.high;

  final Paint rectOutlinePaint = Paint()
    ..color = Colors.black26
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5
    ..strokeCap = ui.StrokeCap.butt
    ..filterQuality = FilterQuality.high;

  final TextSpan textSpan = TextSpan(
    style: const TextStyle(
        color: Colors.orange, fontSize: 50, fontWeight: FontWeight.bold),
    text: busNumber,
  );
  final TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center);

  final ui.Image image = await _getImageFromAsset(assetImagePath);

  final Size sourceImageSize =
      Size(image.width.toDouble(), image.height.toDouble());
  final Size wantedImageSize = sourceImageSize * 1.5;

  final ui.Rect inputRect = Offset.zero & sourceImageSize;
  final ui.Rect outputRect = imageOffset & wantedImageSize;

  final FittedSizes sizes =
      applyBoxFit(BoxFit.contain, sourceImageSize, wantedImageSize);

  final Rect inputSubrect = Alignment.center.inscribe(sizes.source, inputRect);

  final Rect outputSubrect =
      Alignment.center.inscribe(sizes.destination, outputRect);

  canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        0.0,
        0.0,
        105.0 + (busNumber.length * 5.75),
        120.0,
        bottomRight: const Radius.circular(25),
        topLeft: const Radius.circular(25),
      ),
      rectPaint);

  canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        0.0,
        0.0,
        105.0 + (busNumber.length * 5.75),
        120.0,
        bottomRight: const Radius.circular(25),
        topLeft: const Radius.circular(25),
      ),
      rectOutlinePaint);

  canvas.drawImageRect(image, inputSubrect, outputSubrect, imagePaint);

  textPainter.layout();
  textPainter.paint(canvas, textOffset);

  final ui.Picture picture = recorder.endRecording();

  final ByteData pngBytes = await picture
      .toImage(128, 128)
      .then((image) => image.toByteData(format: ui.ImageByteFormat.png));

  picture.dispose();
  return pngBytes;
}

List<LatLng> coordinatesBetweenCoordinatesX(LatLng pointA, pointB) {
  final double diffX = pointB.longitude - pointA.longitude;
  final double diffY = pointB.latitude - pointA.latitude;
  const int pointNum = 20;

  final double intervalX = diffX / (pointNum + 1);
  final double intervalY = diffY / (pointNum + 1);

  final List<LatLng> pointList = <LatLng>[];
  for (int i = 1; i <= pointNum; i++) {
    pointList.add(LatLng(
        pointA.latitude + intervalX * i, pointA.longitude + intervalY * i));
  }

  return pointList;
}

///Calculates points between startingPoint and endingPoint
List<LatLng> equidisLatLngBetweenLatLngs(
    LatLng startingPoint, LatLng endingPoint, int numberOfPoints) {
  final List<LatLng> extendedPoints = <LatLng>[];

  for (double d = 1; d < numberOfPoints - 1; d++) {
    final double a = (max(startingPoint.latitude, endingPoint.latitude) -
                min(startingPoint.latitude, endingPoint.latitude)) *
            d /
            (numberOfPoints - 1) +
        min(startingPoint.latitude, endingPoint.latitude);
    final double b = (max(startingPoint.longitude, endingPoint.longitude) -
                min(startingPoint.longitude, endingPoint.longitude)) *
            d /
            (numberOfPoints - 1) +
        min(startingPoint.longitude, endingPoint.longitude);
    final LatLng pt2 = LatLng(a, b);
    extendedPoints.add(pt2);
  }
  return extendedPoints;
}

class NotchClipper extends CustomClipper<Path> {
  NotchClipper(this.rect);

  final Rect rect;

  @override
  Path getClip(Size size) {
    return Path.combine(PathOperation.difference,
        Path()..addRect(Offset.zero & size), Path()..addOval(rect));
  }

  @override
  bool shouldReclip(NotchClipper oldClipper) => false;
}

Offset offsetFromRect(Rect rect, BuildContext context) {
  final Size _contextSize = MediaQuery.of(context).size;
  final double dx = (rect.center.dx / (_contextSize.width / 2.0)) - 1.0;
  final double dy = (rect.center.dy / (_contextSize.height / 2.0)) - 1.0;

  return Offset(dx, dy);
}

Offset offsetFromCoordinates(double x, double y, BuildContext context) {
  final Size _contextSize = MediaQuery.of(context).size;
  final double dx = (x / (_contextSize.width / 2.0)) - 1.0;
  final double dy = (y / (_contextSize.height / 2.0)) - 1.0;

  return Offset(dx, dy);
}
