import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final Color blue = Color.fromRGBO(0, 105, 255, 1);
  final Color borderColor = Colors.white24;
  final Color white = Colors.white.withOpacity(.9);

  double size = 120;
  final double borderSize = 4;
  final double lineWidth = 4;

  double lineHeight = 40;
  final double rad = pi / 180;

  bool isStartAnimation = false;
  bool isBallMoving = false;
  bool isPercentShow = false;
  bool isDone = false;

  AnimationController a1;
  AnimationController a2;
  AnimationController a3;
  AnimationController a4;

  @override
  void initState() {
    super.initState();

    a1 =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    a2 =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    a3 =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    a4 = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
        lowerBound: 0,
        upperBound: 100);
  }

  void startAnimation() {
    setState(() {
      isStartAnimation = true;
    });
    a1.forward();
    a2.forward().then((value) {
      setState(() {
        isBallMoving = true;
      });
      a3.forward().then((value) {
        setState(() {
          isPercentShow = true;
        });
        a4.forward().then((value) {
          setState(() {
            isDone = true;
          });
          Timer(Duration(milliseconds: 1000), () {
          setState(() {
            isStartAnimation = false;
          });
          resetAnimation();
        });
        });
        
      });
    });
  }

  void resetAnimation() {
    setState(() {
      isStartAnimation = false;
      isBallMoving = false;
      isPercentShow = false;
      isDone = false;
    });
    a1.reset();
    a2.reset();
    a3.reset();
    a4.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blue,
      body: Center(
        child: GestureDetector(
          onTapDown: (d) {
            setState(() {
              size = 110;
            });
          },
          onTapUp: (d) {
            setState(() {
              size = 120;
            });
            !isStartAnimation ? startAnimation() : resetAnimation();
          },
          child: Container(
            child: Stack(
              children: [
                // *** outer circle ***
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: borderSize),
                  ),
                ),
                // *** mid line ***
                AnimatedBuilder(
                  animation: isBallMoving ? a3 : a1,
                  builder: (context, child) {
                    return Positioned(
                      left: (size - lineWidth) / 2,
                      top: ((size - (lineHeight * (1 - a1.value))) / 2) -
                          (size / 2 * a3.value),
                      child: Container(
                        width: lineWidth,
                        height: lineHeight * (1 - a1.value) > lineWidth
                            ? (lineHeight * (1 - a1.value))
                            : (lineWidth),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(lineWidth / 2),
                        ),
                      ),
                    );
                  },
                ),
                // *** left line ***
                AnimatedBuilder(
                  animation: a2,
                  builder: (context, child) {
                    return Positioned(
                      left: (size - (lineHeight * cos(-45 * rad))) / 2,
                      top: (size - (lineHeight / 2)) / 2,
                      child: Transform.rotate(
                        angle: (-45 * rad) + (-45 * rad * a2.value),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: lineWidth,
                          height: lineHeight,
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(lineWidth / 2),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // *** right line ***
                AnimatedBuilder(
                  animation: a2,
                  builder: (context, child) {
                    return Positioned(
                      right: (size - (lineHeight * cos(-45 * rad))) / 2,
                      top: (size - (lineHeight / 2)) / 2,
                      child: Transform.rotate(
                        angle: (45 * rad) + (45 * rad * a2.value),
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: lineWidth,
                          height: lineHeight,
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(lineWidth / 2),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // *** Progression circle ***
                AnimatedBuilder(
                  animation: a4,
                  builder: (context, _) {
                    return CustomPaint(
                        painter:
                            DrawArc(context: context, value: a4.value / 100.0));
                  },
                ),
                // *** Percent ***
                AnimatedBuilder(
                  animation: a4,
                  builder: (context, child) {
                    return Positioned(
                      left: (size - 14) / 2 - 5,
                      top: (size - 14) / 2 + 20,
                      child: !isPercentShow
                          ? Container()
                          : Text(
                              !isDone ? '${a4.value.toInt()} %' : 'Done',
                              style: TextStyle(color: white, fontSize: 14),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrawArc extends CustomPainter {
  final double value;
  final BuildContext context;
  DrawArc({@required this.context, this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(.9)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(60, 60), width: 120 - 2.0, height: 120 - 2.0),
        -pi / 2,
        2 * pi * value,
        false,
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    //throw UnimplementedError();
    return true;
  }
}
