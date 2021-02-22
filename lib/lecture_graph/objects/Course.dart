class Course {
  final String id;
  final String abbreviation;
  final String course_from;
  final String course_to;

  Course({this.id, this.abbreviation, this.course_from, this.course_to});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      abbreviation: json['abbreviation'] as String,
      course_from: json['course_from'] as String,
      course_to: json['course_to'] as String,
    );
  }
}