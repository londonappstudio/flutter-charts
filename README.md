
# charter

A collection of chart implementations for Flutter.

So far this supports the following:
 - PolarAreaChart

## Screenshots

![polar-area-chart-example.png](https://github.com/londonappstudio/flutter-charts/raw/master/example/screenshots/polar-area-chart-example.png)

## QuickStart

### Add Dependency
	dependencies:
		charter: 0.0.1-alpha-2

### Update Packages
	$ flutter pub get

### Import Package

	import 'package:charter/charter.dart';


Add the following code snippet and tweak

	PolarAreaChart.basic(
	  grid: [5,10,15], // Scale for the whole chart
	  features: [
	    "broccoli",
	    "cheese",
	    "salmon",
	    "potato",
	    "carrot",
	    "rice",
	    "lentils",
	    "covfefe",
	    "pasta",
	    "beef",
	    "grains"
	  ],
	  // Features and data must be same length
	  data: [3,1,5,14,6,2,9,13,5,6,10],
	  featuresTextStyle: TextStyle (
	    fontWeight: FontWeight.bold,
	    fontSize: 12
	  ),
	  drawSegmentDividers: true,
	  // Colours are repeated if less than data.length
	  featureColors: [
	    Colors.green,
	    Colors.blue,
	    Colors.red,
	    Colors.orange,
	    Colors.yellow,
	    Colors.pink,
	    Colors.brown
	  ]
	)

