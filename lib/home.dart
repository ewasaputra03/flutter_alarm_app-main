import 'dart:async';

import 'package:alarm_app/constant/theme_data.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'bar_chart.dart';
import 'bloc/hour/hour_bloc.dart';
import 'bloc/minute/minute_bloc.dart';
import 'clock/clock.dart';
import 'notification_api.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String hour = '0';
  String minute = '0';
  String status = '';
  bool isActived = false;
  bool isAm = true;
  List<bool> isSelected = List.generate(2, (index) => false);

  @override
  void initState() {
    super.initState();
    NotificationApi.init();
    listenNotification();
    isSelected[0] = true;
  }

  void listenNotification() =>
      NotificationApi.onNotification.stream.listen(onClickNotification);

  void onClickNotification(String? payload) {
    showModalBottomSheet<void>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: BarChart(
            data: [
              TimeOpen(
                payload,
                DateTime.now().difference(DateTime.parse(payload!)).inSeconds,
                charts.ColorUtil.fromDartColor(
                  CustomColors.primaryColor,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void showSnackBar() {
    String formattedDate = DateFormat('yyyy-MM-dd  hh:mm a').format(
      setDateTime(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alarm set for $formattedDate'),
      ),
    );
  }

  DateTime setDateTime() {
    DateTime now = DateTime.now();
    return DateTime(
        now.year,
        now.month,
        now.hour > (isAm ? int.parse(hour) : int.parse(hour) + 12)
            ? now.day + 1
            : now.hour == (isAm ? int.parse(hour) : int.parse(hour) + 12) &&
                    now.minute >= int.parse(minute) &&
                    now.second > 0
                ? now.day + 1
                : now.day,
        isAm ? int.parse(hour) : int.parse(hour) + 12,
        int.parse(minute));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.menuBackgroundColor,
      body: Stack(
        children: [
          Align(alignment: Alignment.center, child: Clock()),
          SizedBox(
            height: 32,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 96.0, left: 16, right: 16),
              child: activateButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget activateButton() {
    return Container(
      child: Row(
        children: [clockText(), Spacer(), switchNya()],
      ),
    );
  }

  Widget clockText() {
    return Opacity(
      opacity: isActived ? 1 : 0.5,
      child: Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<HourBloc, HourState>(
              builder: (context, state) {
                Future.delayed(Duration.zero, () {
                  if (state is LoadedHour) {
                    setState(() {
                      hour = state.hour;
                    });
                  }
                });
                return Text(state is LoadedHour ? state.hour : '00',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: CustomColors.primaryTextColor));
              },
            ),
            SizedBox(
              width: 5,
            ),
            Text(':',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.primaryTextColor)),
            SizedBox(
              width: 5,
            ),
            BlocBuilder<MinuteBloc, MinuteState>(
              builder: (context, state) {
                Future.delayed(Duration.zero, () {
                  if (state is LoadedMinute) {
                    setState(() {
                      minute = state.minute;
                    });
                  }
                });
                return Text(state is LoadedMinute ? state.minute : '00',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: CustomColors.primaryTextColor));
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Container(
                // color: CustomColors.dividerColor,
                child: ToggleButtons(
                  selectedColor: CustomColors.primaryColor,
                  color: CustomColors.primaryTextColor,
                  fillColor: CustomColors.dividerColor,
                  disabledColor: CustomColors.dividerColor,
                  borderColor: CustomColors.dividerColor,
                  children: const [
                    Text(
                      'AM',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'PM',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                  onPressed: (int index) {
                    setState(() {
                      for (int buttonIndex = 0;
                          buttonIndex < isSelected.length;
                          buttonIndex++) {
                        if (buttonIndex == index) {
                          isAm = index == 0 ? true : false;
                          isActived = false;
                          isSelected[buttonIndex] = true;
                          NotificationApi.cancel();
                        } else {
                          isSelected[buttonIndex] = false;
                        }
                      }
                    });
                  },
                  isSelected: isSelected,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget switchNya() {
    return Opacity(
      opacity: isActived ? 1 : 0.5,
      child: Switch(
          value: isActived,
          activeColor: CustomColors.primaryColor,
          onChanged: (value) {
            setState(() {
              isActived = value;
              if (isActived) {
                NotificationApi.showNotificationSchedule(
                    title: 'Alarm',
                    body: 'Your alarm is active',
                    payload: setDateTime().toString(),
                    scheduleDate: setDateTime());
                Future.delayed(
                    Duration(
                        seconds: setDateTime()
                            .difference(DateTime.now())
                            .inSeconds), () {
                  isActived = false;
                });
                showSnackBar();
              } else {
                NotificationApi.cancel();
              }
            });
          }),
    );
  }
}
