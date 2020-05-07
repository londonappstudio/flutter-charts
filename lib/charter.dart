library flutter_charts;

import 'dart:ui';
import 'dart:math' as math;
import 'dart:developer';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'dart:math' show pi, cos, sin, max;

const defaultColours = [
  Colors.green,
  Colors.blue,
  Colors.red,
  Colors.orange,
  Colors.purple,
  Colors.yellow,
  Colors.brown
];

class PolarAreaChart extends StatefulWidget {
  final List<int> grid;
  final List<String> features;
  final List<double> data;
  final TextStyle ticksTextStyle;
  final TextStyle featureLabelsTextStyle;
  final bool drawSegmentDividers;
  final List<Color> featureColors;

  const PolarAreaChart({
    Key key,
    @required this.grid,
    @required this.features,
    @required this.data,
    this.ticksTextStyle = const TextStyle(color: Colors.grey, fontSize: 12),
    this.featureLabelsTextStyle = const TextStyle(color: Colors.black, fontSize: 16),
    this.drawSegmentDividers = false,
    this.featureColors = defaultColours,
  }) : super(key: key);

  factory PolarAreaChart.basic({
    @required List<int> grid,
    @required List<String> features,
    @required List<double> data,
    bool drawSegmentDividers = false,
    TextStyle featuresTextStyle,
    List<Color> featureColors = defaultColours
  }) {
    return PolarAreaChart(
      grid: grid,
      features: features,
      data: data,
      featureLabelsTextStyle: featuresTextStyle,
      drawSegmentDividers: drawSegmentDividers,
      featureColors: featureColors,
    );
  }

  @override
  _PolarAreaChartState createState() => _PolarAreaChartState();

}


class _PolarAreaChartState extends State<PolarAreaChart>
    with SingleTickerProviderStateMixin {
  double fraction;
  Animation<double> animation;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);

    animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: animationController,
    ))
      ..addListener(() {
        setState(() {
          fraction = animation.value;
        });
      });

    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PolarAreaChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    animationController.reset();
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, double.infinity),
      painter: PolarAreaChartPainter(
          widget.grid,
          widget.features,
          widget.data,
          widget.ticksTextStyle,
          widget.featureLabelsTextStyle,
          widget.drawSegmentDividers,
          widget.featureColors,
          this.fraction),
    );
  }
}

class PolarAreaChartPainter extends CustomPainter {
  final List<int> gridLines;
  final List<String> features;
  final List<double> values;
  final TextStyle ticksTextStyle;
  final TextStyle featuresTextStyle;
  final List<Color> featureColors;
  final double fraction;
  final bool drawSegmentDividers;

  PolarAreaChartPainter(
      this.gridLines,
      this.features,
      this.values,
      this.ticksTextStyle,
      this.featuresTextStyle,
      this.drawSegmentDividers,
      this.featureColors,
      this.fraction);

  @override
  void paint(Canvas canvas, Size size) {

    //Calculate center point of canvas
    final centerX = size.width / 2.0;
    final centerY = size.height / 2.0;
    final centerOffset = Offset(centerX, centerY);

    //Radius of the graph has to be smaller than the
    final radius = math.min(centerX, centerY) * 0.70;
    final int maxValue = gridLines.last;

    //To determine how big to render the segments on the canvas
    final scale = radius / maxValue * 2;

    // Remember we are in Radians
    var angle = (2 * pi) / features.length;
    var segmentSize = angle;

    // Painting the chart outline (A circle)
    for(int i = 0; i < features.length; i++){

      Path outline = Path();
      var outlinePaint = Paint()
        ..color = featureColors[i%featureColors.length].withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0
        ..isAntiAlias = true;

      outline.moveTo(centerX, centerY);
      outline.arcTo(
          Rect.fromCenter(
            center: centerOffset,
            width: scale*maxValue,
            height: scale*maxValue
          ),
          angle*i,
          angle,
          true
      );
      outline.moveTo(centerX, centerY);
      outline.close();
      canvas.drawPath(outline, outlinePaint);
    }


    // Paint for segmentDividers and grid scale
    var gridLinePaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;


    // Painting the circles and labels for the given ticks (could be auto-generated)
    // The last tick is ignored, since it overlaps with the feature label
    var tickDistance = radius / (gridLines.length);
    var tickLabels = gridLines;

    tickLabels.sublist(0, gridLines.length - 1).asMap().forEach((index, tick) {
      var tickRadius = tickDistance * (index + 1);

      canvas.drawCircle(centerOffset, tickRadius, gridLinePaint);

      TextPainter(
        text: TextSpan(text: tick.toString(), style: ticksTextStyle),
        textDirection: TextDirection.ltr,
      )
        ..layout(minWidth: 0, maxWidth: size.width)
        ..paint(canvas,
            Offset(centerX, centerY - tickRadius - ticksTextStyle.fontSize));
    });


    if(drawSegmentDividers){
      features.asMap().forEach((index, feature) {
        var xAngle = cos((angle * index));
        var yAngle = sin((angle * index));
        var featureOffset = Offset(centerX + radius * xAngle, centerY + radius * yAngle);
        canvas.drawLine(centerOffset, featureOffset, gridLinePaint);
      });
    }

    features.asMap().forEach((index, feature) {

      var xAngle = cos((angle * index) + (angle / 2));
      var yAngle = sin((angle * index) + (angle / 2));

      var labelRadius = radius * 1.1;

      var featureOffset = Offset(
          centerX + labelRadius * xAngle,
          centerY + labelRadius * yAngle
      );

      var maxLineLength = feature.split("\n").map((e) => e.length).reduce((value, element) => math.max(value, element));
      var featureLabelFontHeight = featuresTextStyle.fontSize;
      var featureLabelFontWidth = featuresTextStyle.fontSize - 4;
      var labelYOffset = yAngle < 0 ? - featureLabelFontHeight : 0;
      var labelXOffset = xAngle < 0 ?
              (featureLabelFontWidth * maxLineLength * xAngle) : // Left side
              - (featureLabelFontWidth * maxLineLength * (1 - xAngle)) / 2; // Right side

      var coloredTextStyle = featuresTextStyle.copyWith(color: featureColors[index%featureColors.length]);
      TextPainter(
        text: TextSpan(text: feature,
              style: coloredTextStyle
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )
        ..layout(minWidth: 0, maxWidth: size.width)
        ..paint(
            canvas,
            Offset(featureOffset.dx + labelXOffset, featureOffset.dy + labelYOffset));
    });

    // Paint the slices
    for (var i = 0; i < values.length; i++) {

      var slicePaint = Paint()
        ..color = featureColors[i%featureColors.length].withOpacity(0.6)
        ..style = PaintingStyle.fill;

      var path = Path();
      path.moveTo(centerX, centerY);
      path.arcTo(
          Rect.fromCenter(
              center: centerOffset,
              width: scale * values[i],
              height: scale * values[i]
          ),
          i*segmentSize,
          segmentSize,
          false);

      path.lineTo(centerX, centerY);
      path.close();
      canvas.drawPath(path, slicePaint);
    }

  }

  @override
  bool shouldRepaint(PolarAreaChartPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}