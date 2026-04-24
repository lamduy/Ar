class User {
  String _name = "";
  int _age = 0;
  bool _isChecked = false;

  // User(String name, int age) {
  //   this.name = name;
  //   this.age = age;
  // }
  //getter setter
  String get name => _name;
  set name(String value) {
    _name = value;
  }

  bool get isChecked => _isChecked;
  set isChecked(bool value) {
    _isChecked = value;
  }

  int get age => _age;
  set age(int value) {
    _age = value;
  }

  User({required name, required age, bool isChecked = false}) {
    _name = name;
    _age = age;
    _isChecked = isChecked;
  }
}

class Student extends User {
  late String _school;
  String get school => _school;
  set school(String value) {
    _school = value;
  }

  Student({required super.name, required super.age, required school}) {
    _school = school;
  }
}
