import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:music_app/languageUtils.dart';

class SliderData {
  double minValue, maxValue, currentValue;
  String translatedValue;

  SliderData({double min, double max, double value}) {
    minValue = min;
    maxValue = max;
    currentValue = value;
  }

  set value(double newValue) {
    translatedValue = "";
    if (newValue < minValue)
      currentValue = minValue;
    else if (newValue > maxValue)
      currentValue = maxValue;
    else
      currentValue = (newValue * 100).round() / 100;
    print("setting $currentValue");
  }

  double get value => currentValue;

  double get min => minValue;

  double get max => maxValue;

  int get divisions => ((maxValue - minValue) / 100).round();

  disableIncrease() {
    return currentValue >= maxValue;
  }

  disableDecrease() {
    return currentValue <= minValue;
  }
}

class CustomSliderThumb extends SliderComponentShape {
  final double thumbRadius;
  final double min;
  final double max;

  const CustomSliderThumb({
    @required this.thumbRadius,
    this.min,
    this.max,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
    double textScaleFactor,
    Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = sliderTheme.thumbColor //Thumb Background Color
      ..style = PaintingStyle.fill;

    TextSpan span = new TextSpan(
      style: new TextStyle(
        fontSize: thumbRadius * .9,
        fontWeight: FontWeight.w300,
        color: Colors.white, //Text Color of Value on Thumb
      ),
      text: "${getValue(value)}x",
    );

    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter =
        Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: center,
              width: thumbRadius * 3,
              height: thumbRadius * 1.8),
          Radius.circular(thumbRadius * .6),
        ),
        paint);
    // canvas.drawRRect(center, thumbRadius * .9, paint);
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    return translateNumber(((min + (max - min) * value) * 10).round() / 10);
  }
}

class CustomSliderThumb1 extends RoundSliderThumbShape {
  final indicatorShape = const RectangularSliderValueIndicatorShape();
  

  const CustomSliderThumb1();

  @override
  void paint(PaintingContext context, Offset center,
      {Animation<double> activationAnimation,
      Animation<double> enableAnimation,
      bool isDiscrete,
      TextPainter labelPainter,
      RenderBox parentBox,
      SliderThemeData sliderTheme,
      TextDirection textDirection,
      double textScaleFactor,
      double value,
      Size sizeWithOverflow}) {
    super.paint(context, center,
        activationAnimation: activationAnimation,
        enableAnimation: enableAnimation,
        sliderTheme: sliderTheme,
        value: value,
        textScaleFactor: textScaleFactor,
        sizeWithOverflow: sizeWithOverflow);
    indicatorShape.paint(
      context,
      center,
      activationAnimation: const AlwaysStoppedAnimation(1),
      enableAnimation: enableAnimation,
      labelPainter: labelPainter,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      value: value,
// test different testScaleFactor to find your best fit
      textScaleFactor: 0.6,
      sizeWithOverflow: sizeWithOverflow,
    );
  }
}
