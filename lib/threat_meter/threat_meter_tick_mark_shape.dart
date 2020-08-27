import 'package:flutter/material.dart';

class ThreatMeterTickMarkShape extends SliderTickMarkShape {
  /// Create a slider tick mark that draws a circle.
  ThreatMeterTickMarkShape({
    this.tickMarkRadius,
  });

  /// The preferred radius of the round tick mark.
  ///
  /// If it is not provided, then 1/4 of the [SliderThemeData.trackHeight] is used.
  final double tickMarkRadius;

  var paints = [null, Paint()..color = Colors.yellow[800], Paint()..color = Colors.red];

  int paintsIndex = 0;

  @override
  Size getPreferredSize({
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
  }) {
    assert(sliderTheme != null);
    assert(sliderTheme.trackHeight != null);
    assert(isEnabled != null);
    // The tick marks are tiny circles. If no radius is provided, then the
    // radius is defaulted to be a fraction of the
    // [SliderThemeData.trackHeight]. The fraction is 1/4.
    return Size.fromRadius(tickMarkRadius ?? sliderTheme.trackHeight / 4);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        @required RenderBox parentBox,
        @required SliderThemeData sliderTheme,
        @required Animation<double> enableAnimation,
        @required TextDirection textDirection,
        @required Offset thumbCenter,
        bool isEnabled = false,
      }) {
    assert(context != null);
    assert(center != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledActiveTickMarkColor != null);
    assert(sliderTheme.disabledInactiveTickMarkColor != null);
    assert(sliderTheme.activeTickMarkColor != null);
    assert(sliderTheme.inactiveTickMarkColor != null);
    assert(enableAnimation != null);
    assert(textDirection != null);
    assert(thumbCenter != null);
    assert(isEnabled != null);

    if (paintsIndex != 0) {
      context.canvas.drawRect(
          Rect.fromCenter(center: center, width: 2, height: 22),
          paints[paintsIndex++]);
    } else {
      paintsIndex++;
    }
    if (paintsIndex >= paints.length) {
      paintsIndex = 0;
    }
  }
}
