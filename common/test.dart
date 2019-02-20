import 'data.dart';

typedef num Workload<T>(T);

abstract class Test<T> {
  Workload<T> workload;

  num call(Iterable<T> dataPoint);
}