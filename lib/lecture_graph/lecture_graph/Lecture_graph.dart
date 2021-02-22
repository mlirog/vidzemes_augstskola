import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vidzemes_augstskola/lecture_graph/course_selection/CourseSelectionStepper.dart';
import 'package:vidzemes_augstskola/lecture_graph/objects/Lecture.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

class Lecture_graph extends StatefulWidget {
  Lecture_graph({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyLecturesGraphState();
}

class _MyLecturesGraphState extends State<Lecture_graph> {
  Future<List<Lecture>> _future;
  List<Lecture> lectures;
  DateTime _selectedDate;
  List<LectureTime> _times;
  bool _isDownloading = false;
  bool isJoin, isBreaks;

  var coursecode = "";

  @override
  void initState() {
    _selectedDate = new DateTime.now();
    _future = downloadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(coursecode + " | Lectures"),
          actions: [
            PopupMenuButton<String>(
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {'Select course', 'Join lectures', 'Show breaks'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: lectureGraphList());
  }

  Future<String> _checkSavedCourse() async {

    //check saved parameters for lecture requests too
    await checkSavedParameters();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _coursecode = prefs.getString('savedCourse');

    if (_coursecode == "" || _coursecode == null) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CourseSelectionPage()),
      );

      return null;
    } else {
      return _coursecode;
    }
  }

  Future<void> checkSavedParameters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isBreaks = prefs.getBool('lectures_breaks') == null ? false :  prefs.getBool('lectures_breaks');
    isJoin = prefs.getBool('lectures_join') == null ? false : prefs.getBool('lectures_join');
  }

  Future<void> _saveVales(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Sharedpref $key is set to $value now");
    prefs.setBool(key, value);
  }

  Widget lectureGraphList() {
    return FutureBuilder<List<Lecture>>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<List<Lecture>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _isDownloading) {
          return Center(
            child: SizedBox(
              child: const Expanded(
                  child: Center(child: const CircularProgressIndicator())),
              width: 100,
              height: 100,
            ),
          );
        } else {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          else
            return showLectures(lectures);
        }
      },
    );
  }

  Future<List<Lecture>> downloadData() async {
    print("Selected calendar Date is $_selectedDate");

    if (!_isDownloading) {
      _isDownloading = true;

      //get saved course
      if (coursecode == "" || coursecode == null) {
        coursecode = await _checkSavedCourse();
        //debug
        print('courscode recieved from sharedprefs');
      }

      //build request URL
      var requestURL =
          'https://lekcijas.va.lv/lekcijas_android/getMonthLectures.php?date=' +
              DateFormat('yyyy-MM').format(_selectedDate) +
              ( isBreaks ? "&breaks" : "" ) +
              ( isJoin ? "&join" : "" ) +
              "&program=" + coursecode;
      print("Lecture request url : $requestURL");
      //wait for response
      var response = await http.get(requestURL);
      var data = json.decode(response.body)["result"];

      //clear array after each request
      if (lectures != null) lectures.clear();

      try {
        //create lectures from json response
        lectures = List<Lecture>.from(data.map((x) => Lecture.fromJson(x)));
        _getDataSource(lectures);
      } catch (e) {
        print(e.toString());
      }
      return Future.value(lectures);
    }
  }

  Widget showLectures(List<Lecture> lectures) {
    return Card(
      child: Row(
        children: [
          Expanded(
              child: SfCalendar(
                  view: CalendarView.month,
                  firstDayOfWeek: 1,
                  onViewChanged: (ViewChangedDetails details) {
                    _selectedDate = details.visibleDates[15];
                    _future = downloadData();
                  },
                  dataSource: LectureTimeDataSource(_times),
                  monthViewSettings: MonthViewSettings(
                    appointmentDisplayMode:
                        MonthAppointmentDisplayMode.indicator,
                    showAgenda: true,
                  ),
                  showNavigationArrow: true))
        ],
      ),
    );
  }

  void _getDataSource(List<Lecture> lectures) {
    var lectureTimes = <LectureTime>[];
    lectures.forEach((element) {
      lectureTimes.add(LectureTime(
          (element.classroom + "  " + element.lecture),
          DateTime.parse(element.lecture_date + " " + element.start),
          DateTime.parse(element.lecture_date + " " + element.end),
          hexToColor(element.color),
          false));
    });

    setState(() {
      _times = lectureTimes;
    });

    _isDownloading = false;
  }

  void handleClick(String value) {
    print("Lecture button clicked: $value");
    String _snackbarText;
    switch (value) {
      case 'Select course':
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CourseSelectionPage()),
        );
        break;
      case 'Join lectures':
        _saveVales('lectures_breaks', !isBreaks);
        isJoin = !isJoin;
        _future = downloadData();
        break;
      case 'Show breaks':
        _saveVales('lectures_join', !isJoin);
        isBreaks = !isBreaks;
        _future = downloadData();
        break;
    }
  }
}

class LectureTimeDataSource extends CalendarDataSource {
  LectureTimeDataSource(List<LectureTime> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getSubject(int index) {
    return appointments[index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }
}

class LectureTime {
  LectureTime(
      this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}

Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}
