import 'package:flutter/material.dart';

class ThreatMeterTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  /// Create a slider track that draws two rectangles with rounded outer edges.
  const ThreatMeterTrackShape();

  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        @required RenderBox parentBox,
        @required SliderThemeData sliderTheme,
        @required Animation<double> enableAnimation,
        @required TextDirection textDirection,
        @required Offset thumbCenter,
        bool isDiscrete = false,
        bool isEnabled = false,
        double additionalActiveTrackHeight = 2,
      }) {
    assert(context != null);
    assert(offset != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    assert(enableAnimation != null);
    assert(textDirection != null);
    assert(thumbCenter != null);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting  can be a no-op.
    if (sliderTheme.trackHeight <= 0) {
      return;
    }

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween = ColorTween(begin: sliderTheme.disabledActiveTrackColor, end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(begin: sliderTheme.disabledInactiveTrackColor, end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation);
    final Paint inactivePaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation);
    Paint leftTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        break;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    int _radiusMultiplier = 4;

    final Radius trackRadius = Radius.circular(trackRect.height * _radiusMultiplier);
    final Radius trackOutlineRadius = Radius.circular(trackRect.height * _radiusMultiplier + 1);
    final Paint outlinePaint = Paint()..color = Colors.black;

    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.left - 12,
        trackRect.top - 11,
        trackRect.right + 12,
        trackRect.bottom + 11,
        topLeft: trackOutlineRadius,
        bottomLeft: trackOutlineRadius,
        topRight: trackOutlineRadius,
        bottomRight: trackOutlineRadius,
      ),
      outlinePaint,
    );

    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.left - 11,
        trackRect.top - 10,
        trackRect.right + 11,
        trackRect.bottom + 10,
        topLeft: trackRadius,
        bottomLeft: trackRadius,
        topRight: trackRadius,
        bottomRight: trackRadius,
      ),
      leftTrackPaint,
    );
  }
}
