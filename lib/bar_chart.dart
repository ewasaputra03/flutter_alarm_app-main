import 'package:charts_flutter/flutter.dart' as bar;
import 'package:flutter/material.dart';

class BarChart extends StatelessWidget {
  final List<TimeOpen> data;
  const BarChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<bar.Series<TimeOpen, String>> series = [
      bar.Series(
        id: "notif",
        data: data,
        domainFn: (TimeOpen series, _) => series.notif!,
        measureFn: (TimeOpen series, _) => series.range,
        colorFn: (TimeOpen series, _) => series.color,
      )
    ];
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: Container(
          height: 400,
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              Text(
                'Bar Chart Time Open In Second',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: bar.BarChart(
                  series,
                  animate: true,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TimeOpen {
  final String? notif;
  final int range;
  final bar.Color color;

  TimeOpen(this.notif, this.range, this.color);
}
