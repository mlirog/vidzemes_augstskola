class Lecture{
  final String programs;
  final String lecture;
  final String lecturer;
  final String start;
  final String end;
  final String classroom;
  final String color;
  final String lecture_date;

  Lecture({this.programs, this.lecture, this.lecturer, this.start, this.end, this.classroom, this.color, this.lecture_date});

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      programs: json['nodala'] as String,
      lecture: json['kurss'] as String,
      lecturer : json['lektors'] as String,
      start: json['sakums'] as String,
      end: json['beigas'] as String,
      classroom: json['nosaukums'] as String,
      color: json['iela'] as String,
      lecture_date: json['datums'] as String,
    );
  }
}