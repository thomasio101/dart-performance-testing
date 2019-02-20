import 'data.dart';

typedef num Workload<T>(T dataPoint);

abstract class Test<T> {
  Workload<T> workload;

  num call(Iterable<T> dataPoints);
}