import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vidzemes_augstskola/assets/ViAColors.dart';
import 'package:vidzemes_augstskola/lecture_graph/lecture_graph/Lecture_graph.dart';
import 'package:vidzemes_augstskola/lecture_graph/objects/Course.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class CourseSelectionPage extends StatefulWidget{
  // receive data from the FirstScreen as a parameter
  CourseSelectionPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CourseSelectionState();
}

class CourseSelectionState extends State<CourseSelectionPage>{

  int selectedCourse = 0;
  List<Course> courses;
  List<String> nonYearCourses = ["ESME", "Exchange", "Exchange Master"];
  int _currentstep = 0;
  double _yearFrom = 1, _yearTo = 5;
  double _currentSliderValue = 1;
  Future<List<Course>> _future;
  Future<SharedPreferences> prefs;
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  go(int step) {
    setState(() => _currentstep += step);
    //exchange students doesnt need to select study year
    if (nonYearCourses.contains(courses[selectedCourse].abbreviation) &&
        _currentstep == 1)
      openLectureGraphScreen(courses[selectedCourse].abbreviation);
    //subscribe to FCM topic
    _firebaseMessaging.subscribeToTopic(courses[selectedCourse].abbreviation)
  }

  @override
  void initState() {
    prefs = _checkSavedCourse();
    _future = downloadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Course selection"),
      ),
      body: Stepper(
        currentStep: _currentstep,
        onStepContinue: () {
          if (selectedCourse >= 0 && _currentstep == 1) {
            //build returnable course code
            String returnCourse;
            //exchange students doesnt need to select year
            if (nonYearCourses.contains(courses[selectedCourse].abbreviation))
              //exchange courscode doesnt contain study year
              returnCourse = courses[selectedCourse].abbreviation;
            else
              //other student coursecodes contain study year
              returnCourse = courses[selectedCourse].abbreviation +
                  _currentSliderValue.toInt().toString();

            //open new screen
            openLectureGraphScreen(returnCourse);
          } else if (_currentstep != 1 && selectedCourse >= 0) {
            go(1);
          } else {
            Scaffold.of(context)
                .showSnackBar(SnackBar(content: Text('Error !')));
          }
        },
        onStepCancel: () {
          if(_currentstep == 0){
            Navigator.pop(context);
          }else if (_currentstep > 0) {
            go(-1);
          }
        },
        controlsBuilder: (BuildContext context,
            {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
          return Center(
            child: Row(
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(10.0),
                  color: Colors.blue,
                  child: Text(
                    "Next",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: onStepContinue,
                ),
                FlatButton(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text("Back"),
                  ),
                  onPressed: onStepCancel,
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: Text("Pick your study program"),
            isActive: _currentstep == 0,
            content: Center(
              child: FutureBuilder<List<Course>>(
                future: _future, // function where you call your api
                builder: (BuildContext context,
                    AsyncSnapshot<List<Course>> snapshot) {
                  // AsyncSnapshot<Your object type>
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: Text('Please wait its loading...'));
                  } else {
                    if (snapshot.hasError)
                      return Center(child: Text('Error: ${snapshot.error}'));
                    else
                      return showCoursePicker();
                    // snapshot.data  :- get your object which is pass from your downloadData() function
                  }
                },
              ),
            ),
          ),
          Step(
            isActive: _currentstep == 1,
            state: StepState.indexed,
            title: const Text('Pick your study year'),
            content: Row(
              children: [
                Column(
                  children: [Text(_yearFrom.toInt().toString())],
                ),
                Column(
                  children: [
                    Slider(
                      activeColor: ViAOrange,
                      min: _yearFrom,
                      max: _yearTo == _yearFrom ? _yearTo + 1 : _yearTo,
                      divisions: _yearTo == _yearFrom
                          ? _yearTo.toInt() - _yearFrom.toInt() + 1
                          : _yearTo.toInt() - _yearFrom.toInt(),
                      value: _currentSliderValue,
                      label: _currentSliderValue.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _currentSliderValue = value;
                        });
                      },
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(_yearTo.toInt().toString()),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Course>> downloadData() async {
    var response = await http
        .get('https://lekcijas.va.lv/lekcijas_android/getAllCourseData.php');
    var data = json.decode(response.body)["result"];
    courses = List<Course>.from(data.map((x) => Course.fromJson(x)));
    return Future.value(courses);
  }

  Future<SharedPreferences> _checkSavedCourse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _savedCourse = prefs.getString('savedCourse');
    // if (_savedCourse != "" && _savedCourse != null)
    //   openLectureGraphScreen(_savedCourse);
    return prefs;
  }

  Future<SharedPreferences> _updateSavedCourse(String newVal) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('savedCourse', newVal);
    return prefs;
  }

  Widget showCoursePicker() {
    return Container(
      height: 250,
      child: CupertinoPicker.builder(
          childCount: courses.length,
          itemExtent: 40,
          useMagnifier: true,
          magnification: 1.3,
          onSelectedItemChanged: (value) {
            selectedCourse = value;
            _currentSliderValue = 1;
            setState(() {
              _yearFrom = double.parse(courses[selectedCourse].course_from);
              _yearTo = double.parse(courses[selectedCourse].course_to);
            });
          },
          itemBuilder: (ctx, index) {
            return Center(
              child: Text(
                courses.isEmpty ? '' : courses[index].abbreviation,
              ),
            );
          }),
    );
  }

  void openLectureGraphScreen(String returnCourse) {
    prefs = _updateSavedCourse(returnCourse);
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Lecture_graph()),
    );
  }
}