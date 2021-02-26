import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:vidzemes_augstskola/functions/hexToColor.dart';
import 'package:vidzemes_augstskola/lecture_graph/course_selection/CourseSelectionStepper.dart';
import 'package:vidzemes_augstskola/lecture_graph/objects/Lecture.dart';
import 'dart:convert';
import '../../main.dart';

class Lecture_graph extends StatefulWidget {
  Lecture_graph({Key key}) : super(key: key);

  @override
  State<Lecture_graph> createState() => myLectureGraph();
}

class myLectureGraph extends State<Lecture_graph> with TickerProviderStateMixin {
  List _selectedEvents;
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, List<Lecture>> _events;
  CalendarController _calendarController;
  AnimationController _animationController;
  List<Lecture> _lectures;
  String coursecode = "";
  bool isJoin, isBreaks = false;
  bool isLoading = true;

  final Map<DateTime, List> _holidays = {
    DateTime(2021, 1, 1): ['New Year\'s Day'],
    DateTime(2021, 2, 14): ['Valentine\'s Day'],
    DateTime(2021, 3, 8): ['Woman\'s Day'],
  };

  Future<Map<DateTime, List>> getLectures(DateTime _selectedDate) async {
    print("getLectures started.");
    setState(() {
      isLoading = true;
    });

    Map<DateTime, List<Lecture>> mapFetch = {};

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
            (isBreaks ? "&breaks" : "") +
            (isJoin ? "&join" : "") +
            "&program=" +
            coursecode;
    print("Lecture request url : $requestURL");
    //wait for response
    var response = await http.get(requestURL);
    var data = json.decode(response.body)["result"];

    //clear array after each request
    if (_lectures != null) _lectures.clear();

    try {
      //create lectures from json response
      _lectures = List<Lecture>.from(data.map((x) => Lecture.fromJson(x)));
    } on Exception catch (_) {
      print("Error occured getting lectures");
    }

    _lectures.forEach((element) {
      if (mapFetch[element.lecture_date] != null) {
        mapFetch[element.lecture_date] += [element];
      } else {
        mapFetch[element.lecture_date] = [element];
      }
    });

    print("getLectures finished.");
    return mapFetch;
  }

  Future<void> _saveVales(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Sharedpref $key is set to $value now");
    prefs.setBool(key, value);
  }

  Future<void> _checkSavedParameters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isBreaks = prefs.getBool('lectures_breaks') == null
        ? false
        : prefs.getBool('lectures_breaks');
    isJoin = prefs.getBool('lectures_join') == null
        ? false
        : prefs.getBool('lectures_join');
  }

  Future<String> _checkSavedCourse() async {
    //check saved parameters for lecture requests too
    await _checkSavedParameters();

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

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
    });
  }

  @override
  void initState() {
    _selectedEvents = [];
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLectures(_selectedDate).then((val) => setState(() {
            _events = val;
            isLoading = false;
          }));
    });
    super.initState();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(coursecode + " | Lectures"),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleClick,
            itemBuilder: (BuildContext context) {
              return {'Select course', 'Join lectures', 'Show breaks'}
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            isLoading
                ? Expanded(child: Center(child: CircularProgressIndicator()))
                : _buildTableCalendarWithBuilders(),
            const SizedBox(height: 8.0),
            const SizedBox(height: 8.0),
            Expanded(child: _buildEventList()),
          ],
        ),
      ),
    );
  }

  void _handleClick(String value) {
    print("Lecture button clicked: $value");
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          getLectures(_selectedDate).then((val) => setState(() {
            _events = val;
            isLoading = false;
          }));
        });
        break;
      case 'Show breaks':
        _saveVales('lectures_join', !isJoin);
        isBreaks = !isBreaks;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          getLectures(_selectedDate).then((val) => setState(() {
            _events = val;
            isLoading = false;
          }));
        });
        break;
    }
  }

  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      //locale: 'pl_PL',
      initialSelectedDay: _selectedDate,
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.scale,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
        CalendarFormat.twoWeeks: '',
        CalendarFormat.week: '',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
        holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
      ),
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        formatButtonVisible: false,
      ),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color: Colors.deepOrange[300],
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Colors.amber[400],
            width: 100,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }

          if (holidays.isNotEmpty) {
            children.add(
              Positioned(
                right: -2,
                top: -2,
                child: _buildHolidaysMarker(),
              ),
            );
          }

          return children;
        },
      ),
      onDaySelected: (date, events, holidays) {
        _onDaySelected(date, events);
        _animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    _selectedDate = first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLectures(_selectedDate).then((val) => setState(() {
            _events = val;
            isLoading = false;
          }));
    });
    print('CALLBACK: _onVisibleDaysChanged');
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date)
                ? Colors.brown[300]
                : Colors.green[400],
      ),
      width: 18.0,
      height: 18.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
              color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((lecture) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.1),
                  // borderRadius: BorderRadius.circular(2.0),
                  color: hexToColor(lecture.color),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.5),
                child: ListTile(
                  title: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          lecture.start + " - " + lecture.end,
                          style: new TextStyle(
                            fontSize: 12.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(lecture.lecture,
                          style: new TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        )),
                      ),
                    ],
                  ),
                  onTap: () => displayDialog(lecture, context),
                ),
              ))
          .toList(),
    );
  }

  void displayDialog(Lecture selectedLecture, BuildContext ctx){
    //if selected lecture is a break
    if(!selectedLecture.lecturer.isEmpty && !selectedLecture.classroom.isEmpty && !selectedLecture.programs.isEmpty){
      showDialog(
        barrierDismissible: true,
        context: ctx,
        builder: (BuildContext context) => new AlertDialog(
          title: new Text("Lecture info"),
          content: new Wrap(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Time : " + selectedLecture.start + " - " + selectedLecture.end),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Lecturer : " + selectedLecture.lecturer),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Classroom : " + selectedLecture.classroom),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Lecture : " + selectedLecture.lecture),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Date : " + DateFormat('yyyy-MM-dd').format(selectedLecture.lecture_date).toString()),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Programs : " + selectedLecture.programs),
              ),
            ],

          ),
          actions: [
            new TextButton(
              child: const Text("Ok"),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );
    }

  }
}
