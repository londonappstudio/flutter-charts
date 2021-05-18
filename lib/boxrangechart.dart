const defaultColours = [
  Colors.lightBlue,
  Colors.blue,
];

class BoxRangeChart extends StatefulWidget {
  final String title;
  final String subTitle;
  final double min;
  final double max;
  final double rangeMin;
  final double rangeMax;
  final Color featureColor;
  final List<Color> gradientColors;

  const BoxRangeChart({
    Key key,
    this.title = '',
    this.subTitle = '',
    this.min,
    this.max,
    this.rangeMin,
    this.rangeMax,
    this.featureColor,
    this.gradientColors = defaultColours,
  }) : super(key: key);
  _RangeState createState() => _RangeState();
}

class _RangeState extends State<BoxRangeChart> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: RichText(
                text: TextSpan(
                  text: widget.title,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: ' ' + widget.subTitle,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.topRight,
                  child: Text(
                    widget.min.floor().toString() + ' ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: CustomPaint(
                            foregroundPainter: MyProgressLine(
                              min: widget.min,
                              max: widget.max,
                              rangeMin: widget.rangeMin,
                              rangeMax: widget.rangeMax,
                              featureColor: widget.featureColor,
                            ),
                            child: Container(
                              width: double.infinity,
                              height: 10,
                              child: ConstrainedBox(
                                constraints: BoxConstraints.expand(),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: widget.gradientColors),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    ' ' + widget.max.floor().toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: RichText(
                  text: TextSpan(
                      text: 'Min\n',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: widget.rangeMin.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ]),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: RichText(
                  text: TextSpan(
                      text: 'Max\n',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: widget.rangeMax.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ]),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyProgressLine extends CustomPainter {
  MyProgressLine({
    this.min,
    this.max,
    this.rangeMin,
    this.rangeMax,
    this.featureColor,
  });

  final double min;
  final double max;
  final double rangeMin;
  final double rangeMax;
  final Color featureColor;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = featureColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    Paint endLine = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    double width = size.width;

    double steps = width / max;

    // Draws the min and max line at each end
    canvas.drawLine(Offset(0, -10), Offset(0, 10), endLine);
    canvas.drawLine(Offset(width, -10), Offset(width, 10), endLine);

    // Draws bottom lines
    endLine.color = featureColor.withOpacity(0.8);
    canvas.drawLine(Offset(0, 10), Offset(steps * rangeMin + 1.5, 10), endLine);
    canvas.drawLine(
        Offset(width, 10), Offset(steps * rangeMax + 1.5, 10), endLine);

    // Draws current range lines
    canvas.drawLine(
        Offset(steps * rangeMin, -10), Offset(steps * rangeMin, 11), paint);
    canvas.drawLine(
        Offset(steps * rangeMax, -10), Offset(steps * rangeMax, 11), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}