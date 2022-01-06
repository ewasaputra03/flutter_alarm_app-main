import 'package:alarm_app/clock/clock_dial.dart';
import 'package:alarm_app/clock/clock_text.dart';
import 'package:alarm_app/constant/theme_data.dart';
import 'package:flutter/material.dart';

import 'hour_hand.dart';
import 'minute_hand.dart';
import 'wheel_circle_painter.dart';

class Clock extends StatefulWidget {
  const Clock({Key? key}) : super(key: key);

  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> with TickerProviderStateMixin {
  double wheelSize = 400;
  final double longNeedleHeight = 40;
  final double shortNeedleHeight = 25;

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
                color: Colors.transparent,
                width: wheelSize,
                height:wheelSize,
                child: CustomPaint(
                    painter:
                        ClockDialPainter(clockText: ClockText.roman))),
            Container(
              width: wheelSize,
              height: wheelSize,
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                      color: CustomColors.primaryColor,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            MinuteHand(),
            HourHand(),
          ],
        )
      ],
    );
  }
}
