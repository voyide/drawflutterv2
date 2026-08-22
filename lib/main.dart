import 'package:flutter/material.dart';

void main() {
  runApp(const BrutalDrawApp());
}

class BrutalDrawApp extends StatelessWidget {
  const BrutalDrawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BRUTAL DRAW',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFC0C0C0), // Raw brutalist grey
        fontFamily: 'Courier', // Raw monospace typography
        useMaterial3: true,
      ),
      home: const DrawingPage(),
    );
  }
}

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  List<DrawnLine> lines = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 8.0;

  final List<Color> brutalColors = [
    Colors.black,
    Colors.white,
    const Color(0xFFFF0000), // Pure Red
    const Color(0xFF00FF00), // Neon Green
    const Color(0xFF0000FF), // Pure Blue
    const Color(0xFFFFFF00), // Pure Yellow
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // SAFE AREA guarantees no overlap with Android native buttons
        child: Column(
          children: [
            // BRUTAL HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.black,
                border: Border(bottom: BorderSide(color: Colors.black, width: 4)),
              ),
              child: const Text(
                'BRUTAL DRAW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // CANVAS AREA
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 6), // Heavy monolithic borders
                ),
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      lines.add(DrawnLine(
                        points: [details.localPosition],
                        color: selectedColor,
                        width: strokeWidth,
                      ));
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      lines.last.points.add(details.localPosition);
                    });
                  },
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: BrutalPainter(lines: lines),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),
            
            // BRUTALIST TOOLBAR
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.black, width: 6)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Color Palette
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: brutalColors.map((color) {
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = color),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                              color: Colors.black,
                              width: selectedColor == color ? 6 : 2, // Aggressive highlight
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Controls
                  Row(
                    children: [
                      const Text(
                        'WIDTH',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 10,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14, pressedElevation: 0),
                          ),
                          child: Slider(
                            value: strokeWidth,
                            min: 2.0,
                            max: 30.0,
                            activeColor: Colors.black,
                            inactiveColor: Colors.black26,
                            onChanged: (val) {
                              setState(() => strokeWidth = val);
                            },
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => lines.clear()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF0000),
                            border: Border.all(color: Colors.black, width: 4),
                          ),
                          child: const Text(
                            'NUKE', // Brutal terminology
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double width;
  DrawnLine({required this.points, required this.color, required this.width});
}

class BrutalPainter extends CustomPainter {
  final List<DrawnLine> lines;
  BrutalPainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    for (var line in lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeCap = StrokeCap.square // Hard, aggressive edges. No rounded corners.
        ..strokeJoin = StrokeJoin.bevel
        ..strokeWidth = line.width
        ..style = PaintingStyle.stroke;
      
      // Edge case: single tap generates 1 point. Draw a harsh square instead of ignoring.
      if (line.points.length == 1) {
        canvas.drawRect(
          Rect.fromCenter(center: line.points.first, width: line.width, height: line.width),
          paint..style = PaintingStyle.fill,
        );
      } else {
        final path = Path();
        path.moveTo(line.points.first.dx, line.points.first.dy);
        for (int i = 1; i < line.points.length; i++) {
          path.lineTo(line.points[i].dx, line.points[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
