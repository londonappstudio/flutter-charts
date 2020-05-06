library flutter_charts;

import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'dart:math' show pi, cos, sin;

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
  final List<int> ticks;
  final List<String> features;
  final List<List<int>> data;
  final bool reverseAxis;
  final TextStyle ticksTextStyle;
  final TextStyle featuresTextStyle;
  final Color outlineColor;
  final Color axisColor;
  final List<Color> graphColors;

  const PolarAreaChart({
    Key key,
    @required this.ticks,
    @required this.features,
    @required this.data,
    @required this.reverseAxis,
    this.ticksTextStyle = const TextStyle(color: Colors.grey, fontSize: 12),
    this.featuresTextStyle = const TextStyle(color: Colors.black, fontSize: 16),
    this.outlineColor = Colors.black,
    this.axisColor = Colors.grey,
    this.graphColors = defaultColours,
  }) : super(key: key);

  factory PolarAreaChart.light({
    @required List<int> ticks,
    @required List<String> features,
    @required List<List<int>> data,
    bool reverseAxis = false,
  }) {
    return PolarAreaChart(
      ticks: ticks,
      features: features,
      data: data,
      reverseAxis: reverseAxis,
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
          widget.ticks,
          widget.features,
          widget.data,
          widget.reverseAxis,
          widget.ticksTextStyle,
          widget.featuresTextStyle,
          widget.outlineColor,
          widget.axisColor,
          widget.graphColors,
          this.fraction),
    );
  }
}

class PolarAreaChartPainter extends CustomPainter {
  final List<int> gridLines;
  final List<String> features;
  final List<List<int>> data;
  final bool reverseAxis;
  final TextStyle ticksTextStyle;
  final TextStyle featuresTextStyle;
  final Color outlineColor;
  final Color axisColor;
  final List<Color> graphColors;
  final double fraction;

  PolarAreaChartPainter(
      this.gridLines,
      this.features,
      this.data,
      this.reverseAxis,
      this.ticksTextStyle,
      this.featuresTextStyle,
      this.outlineColor,
      this.axisColor,
      this.graphColors,
      this.fraction);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2.0;
    final centerY = size.height / 2.0;
    final centerOffset = Offset(centerX, centerY);
    final radius = math.min(centerX, centerY) * 0.8;
    final scale = radius / gridLines.last;

    // Painting the chart outline (A circle)
    var outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    var ticksPaint = Paint()
      ..color = axisColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    canvas.drawCircle(centerOffset, radius, outlinePaint);

    // Painting the circles and labels for the given ticks (could be auto-generated)
    // The last tick is ignored, since it overlaps with the feature label
    var tickDistance = radius / (gridLines.length);
    var tickLabels = reverseAxis ? gridLines.reversed.toList() : gridLines;

    tickLabels.sublist(0, gridLines.length - 1).asMap().forEach((index, tick) {
      var tickRadius = tickDistance * (index + 1);

      canvas.drawCircle(centerOffset, tickRadius, ticksPaint);

      TextPainter(
        text: TextSpan(text: tick.toString(), style: ticksTextStyle),
        textDirection: TextDirection.ltr,
      )
        ..layout(minWidth: 0, maxWidth: size.width)
        ..paint(canvas,
            Offset(centerX, centerY - tickRadius - ticksTextStyle.fontSize));
    });

//    // Painting the axis for each given feature
//    var angle = (2 * pi) / features.length;
//
//    features.asMap().forEach((index, feature) {
//      var xAngle = cos(angle * index - pi / 2);
//      var yAngle = sin(angle * index - pi / 2);
//
//      var featureOffset =
//      Offset(centerX + radius * xAngle, centerY + radius * yAngle);
//
//      canvas.drawLine(centerOffset, featureOffset, ticksPaint);
//
//      var featureLabelFontHeight = (featuresTextStyle as TextStyle).fontSize;
//      var featureLabelFontWidth = (featuresTextStyle as TextStyle).fontSize - 4;
//      var labelYOffset = yAngle < 0 ? -featureLabelFontHeight : 0;
//      var labelXOffset =
//      xAngle < 0 ? -featureLabelFontWidth * feature.length : 0;
//
//      TextPainter(
//        text: TextSpan(text: feature, style: featuresTextStyle),
//        textAlign: TextAlign.center,
//        textDirection: TextDirection.ltr,
//      )
//        ..layout(minWidth: 0, maxWidth: size.width)
//        ..paint(
//            canvas,
//            Offset(featureOffset.dx + labelXOffset,
//                featureOffset.dy + labelYOffset));
//    });

    // Take these as a param from somewhere
    var values = [3,1,5,4,6,2,9,13,5,6,10];

    var sweep = 360 / values.length;

    // Paint the slices
    for (var i = 0; i < values.length; i++) {

      var slicePaint = Paint()
        ..color = graphColors[i%defaultColours.length].withOpacity(0.9)
        ..style = PaintingStyle.fill;

      var edgesPaint = Paint()
        ..color = graphColors[i%defaultColours.length].withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..isAntiAlias = true;

      var path = Path();


      num degToRad(num deg) => deg * (math.pi / 180.0);
      
      path.moveTo(centerX, centerY); // OK


      print("Scale: $scale ");
//      Offset(centerX,centerY), 50.0,50.0
      path.arcTo(
          Rect.fromCenter(
              center: centerOffset,
              width: scale * values[i],
              height: scale * values[i]
          ),
          degToRad(i*sweep),
          degToRad(sweep),
          false);
      path.lineTo(centerX, centerY);
//          lastend+(Math.PI*2*(values[i]/myTotal)));


//      path.lineTo(100.0 + (i * 5), 200);


      path.close();
      canvas.drawPath(path, slicePaint); // fill it in
//      canvas.drawPath(path, edgesPaint);


      //Stolen from a JS fiddle so I don't have to do any math
//      ctx.beginPath();
//      ctx.moveTo(200,150);
//      ctx.arc(200,150,myRadius[i],lastend,lastend+
//          (Math.PI*2*(myData[i]/myTotal)),false);
//      console.log(myRadius[i]);
//      ctx.lineTo(200,150);
//      ctx.fill();
//      lastend += Math.PI*2*(myData[i]/myTotal);
    }


//
//    // Painting each graph
//    data.asMap().forEach((index, graph) {
//      var graphPaint = Paint()
//        ..color = graphColors[index % graphColors.length].withOpacity(0.3)
//        ..style = PaintingStyle.fill;
//
//      var graphOutlinePaint = Paint()
//        ..color = graphColors[index % graphColors.length]
//        ..style = PaintingStyle.stroke
//        ..strokeWidth = 2.0
//        ..isAntiAlias = true;
//
//      // Start the graph on the initial point
//      var scaledPoint = scale * graph[0] * fraction;
//      var path = Path();
//
//      if (reverseAxis) {
//        path.moveTo(centerX, centerY - (radius * fraction - scaledPoint));
//      } else {
//        path.moveTo(centerX, centerY - scaledPoint);
//      }
//
//      graph.asMap().forEach((index, point) {
//        if (index == 0) return;
//
//        var xAngle = cos(angle * index - pi / 2);
//        var yAngle = sin(angle * index - pi / 2);
//        var scaledPoint = scale * point * fraction;
//
//        if (reverseAxis) {
//          path.lineTo(centerX + (radius * fraction - scaledPoint) * xAngle,
//              centerY + (radius * fraction - scaledPoint) * yAngle);
//        } else {
//          path.lineTo(
//              centerX + scaledPoint * xAngle, centerY + scaledPoint * yAngle);
//        }
//      });
//
//      path.close();
//      canvas.drawPath(path, graphPaint);
//      canvas.drawPath(path, graphOutlinePaint);
//    });
  }

  @override
  bool shouldRepaint(PolarAreaChartPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}