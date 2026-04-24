abstract class Machine {
  void run();
  void stop() {
    print('Stop machine');
  }
}

class C1 extends Machine {
  @override
  void run() {}
}

class C2 implements Machine {
  @override
  void run() {}

  @override
  void stop() {
    print('C2 Stop');
  }
}

mixin M1 {
  void doWork() {
    print('M1 do work');
  }

  void stop() {
    print('M1 stop');
  }
}
mixin M2 {
  void doWork() {
    print('M2 do work');
  }

  void stop() {
    print('M2 stop');
  }
}

class C3 with M1, M2 {}

class MyDateTime extends DateTime {
  MyDateTime() : super.now();
  void convertToHoursFromSeconds(int seconds) {
    int hours = seconds ~/ 3600;
    print('$seconds seconds is equal to $hours hours.');
  }
}

extension MyDateTime1 on DateTime {
  void convertToHoursFromSeconds(int seconds) {
    int hours = seconds ~/ 3600;
    print('$seconds seconds is equal to $hours hours.');
  }
}
