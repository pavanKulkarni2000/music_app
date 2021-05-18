import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SliderData {
  double _min, _max, _value;

  set value(double newValue) {
    if (newValue < _min)
      _value = _min;
    else if (newValue > _max)
      _value = _max;
    else
      _value = (newValue * 100).round() / 100;
    print("setting $_value");
  }

  double get value => _value;

  double get min => _min;

  double get max => _max;

  int get divisions => ((_max - _min) / 100).round();

  SliderData({double min, double max, double value}) {
    _min = min;
    _max = max;
    this.value = value;
  }

  disableIncrease() {
    return _value >= _max;
  }

  disableDecrease() {
    return _value <= _min;
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
        fontSize: thumbRadius * .7,
        fontWeight: FontWeight.w600,
        color: Colors.white, //Text Color of Value on Thumb
      ),
      text: "${getValue(value)} x",
    );

    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter =
        Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: center, width: thumbRadius * 3, height: thumbRadius * 1.8),
      Radius.circular(thumbRadius * .6),
    ), paint);
    // canvas.drawRRect(center, thumbRadius * .9, paint);
    tp.paint(canvas, textCenter);
  }

  double getValue(double value) {
    return ((min + (max - min) * value) * 100).round() / 100;
  }
}


class CustomSliderThumbOverlay extends SliderComponentShape {
  final double thumbRadius;

  const CustomSliderThumbOverlay({
    @required this.thumbRadius
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

    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: center, width: thumbRadius * 3, height: thumbRadius * 1.8),
      Radius.circular(thumbRadius * .6),
    ), paint);
  }
}
