// ignore_for_file: unnecessary_null_comparison

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:animated_floating_buttons/animated_floating_buttons.dart';

// ignore: camel_case_types
class canvasPainting extends StatefulWidget {
  const canvasPainting({Key? key, required this.imagePath}) : super(key: key);
  final String imagePath;
  @override
  State<canvasPainting> createState() => _canvasPaintingState();
}

// ignore: camel_case_types
class _canvasPaintingState extends State<canvasPainting> {
  List<TouchPoints?> points = [];
  double opacity = 1.0;
  StrokeCap strokeType = StrokeCap.round;
  double strokeWidth = 3.0;
  Color selectedColor = Colors.black;
  GlobalKey globalKey = GlobalKey();
  Future<void> _pickStroke() async {
    //Shows AlertDialog
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ClipOval(
          child: AlertDialog(
            actions: <Widget>[
              IconButton(
                  onPressed: () {
                    strokeWidth = 3.0;
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.clear,
                  )),
              IconButton(
                  onPressed: () {
                    strokeWidth = 10.0;
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.brush,
                    size: 24,
                  )),
              IconButton(
                  onPressed: () {
                    strokeWidth = 30.0;
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.brush,
                    size: 40,
                  )),
              IconButton(
                  onPressed: () {
                    strokeWidth = 50.0;
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.brush,
                    size: 60,
                  )),
            ],
          ),
        );
      },
    );
  }

  Future<void> _opacity() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ClipOval(
          child: AlertDialog(
            actions: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.opacity,
                  size: 24,
                ),
                onPressed: () {
                  opacity = 0.1;
                  Navigator.of(context).pop();
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.opacity,
                  size: 40,
                ),
                onPressed: () {
                  opacity = 0.5;
                  Navigator.of(context).pop();
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.opacity,
                  size: 60,
                ),
                onPressed: () {
                  opacity = 1.0;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    final RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    print(pngBytes);
    if (!(await Permission.storage.status.isGranted)) {
      await Permission.storage.request();
    }

    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(pngBytes),
        quality: 60,
        name: "canvas_image");
    print(result);
  }

  List<Widget> fabOption() {
    return <Widget>[
      FloatingActionButton(
        heroTag: "save",
        child: const Icon(Icons.save),
        tooltip: 'Stroke',
        onPressed: () {
          setState(() {
            _save();
          });
        },
      ),
      FloatingActionButton(
        heroTag: "erase",
        child: const Icon(Icons.clear),
        tooltip: 'Stroke',
        onPressed: () {
          setState(() {
            points.clear();
          });
        },
      ),
      FloatingActionButton(
        heroTag: "paint_stroke",
        child: const Icon(Icons.brush),
        tooltip: 'Stroke',
        onPressed: () {
          setState(() {
            _pickStroke();
          });
        },
      ),
      FloatingActionButton(
        heroTag: "paint_opacity",
        child: const Icon(Icons.opacity),
        tooltip: 'Opacity',
        onPressed: () {
          //min:0, max:1
          setState(() {
            _opacity();
          });
        },
      ),
      FloatingActionButton(
        backgroundColor: Colors.white,
        heroTag: "color_red",
        child: colorMenuItem(Colors.red),
        tooltip: 'Color',
        onPressed: () {
          setState(() {
            selectedColor = Colors.red;
          });
        },
      ),
      FloatingActionButton(
        backgroundColor: Colors.white,
        heroTag: "color_green",
        child: colorMenuItem(Colors.green),
        tooltip: 'Color',
        onPressed: () {
          setState(() {
            selectedColor = Colors.green;
          });
        },
      ),
      FloatingActionButton(
        backgroundColor: Colors.white,
        heroTag: "color_pink",
        child: colorMenuItem(Colors.pink),
        tooltip: 'Color',
        onPressed: () {
          setState(() {
            selectedColor = Colors.pink;
          });
        },
      ),
      FloatingActionButton(
        backgroundColor: Colors.white,
        heroTag: "color_blue",
        child: colorMenuItem(Colors.blue),
        tooltip: 'Color',
        onPressed: () {
          setState(() {
            selectedColor = Colors.blue;
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  points.add(TouchPoints(
                      points: renderBox.globalToLocal(details.globalPosition),
                      paint: Paint()
                        ..strokeCap = strokeType
                        ..isAntiAlias = true
                        ..color = selectedColor.withOpacity(opacity)
                        ..strokeWidth = strokeWidth));
                });
              },
              onPanStart: (details) {
                setState(() {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  points.add(TouchPoints(
                      points: renderBox.globalToLocal(details.globalPosition),
                      paint: Paint()
                        ..strokeCap = strokeType
                        ..isAntiAlias = true
                        ..color = selectedColor.withOpacity(opacity)
                        ..strokeWidth = strokeWidth));
                });
              },
              onPanEnd: (details) {
                setState(() {
                  points.add(null);
                });
              },
              child: RepaintBoundary(
                key: globalKey,
                child: Stack(
                  children: <Widget>[
                    Container(
                      child: Image.file(File(widget.imagePath)),
                    ),
                    CustomPaint(
                      size: Size.infinite,
                      painter: MyPainter(
                        pointsList: points,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedFloatingActionButton(
        fabButtons: fabOption(),
        colorStartAnimation: Colors.blue,
        colorEndAnimation: Colors.cyan,
        animatedIconData: AnimatedIcons.menu_close,
      ),
    );
  }

  Widget colorMenuItem(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 8.0),
          height: 36,
          width: 36,
          color: color,
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  MyPainter({required this.pointsList});

  List<TouchPoints?> pointsList;
  List<Offset> offsetPoints = [];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i]!.points, pointsList[i + 1]!.points,
            pointsList[i]!.paint);
      } else if (pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i]!.points);
        offsetPoints.add(Offset(
            pointsList[i]!.points.dx + 0.1, pointsList[i]!.points.dy + 0.1));

        canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) => true;
}

class TouchPoints {
  Paint paint;
  Offset points;
  TouchPoints({
    required this.points,
    required this.paint,
  });
}
