import 'dart:math';

import '../../common/data.dart';
import '../../common/tables.dart';
import '../../common/workloads.dart';

main(List<String> args) async {
  int sampleSize = int.parse(args[0]);
  int randomNumberGeneratorSeed = int.parse(args[1]);

  final Random randomNumberGenerator = Random(randomNumberGeneratorSeed);
  final List<DataPoint> data = await DataPoint.generateNDataPoints(sampleSize, randomNumberGenerator).toList();

  List<List<dynamic>> results = [];

  final Stopwatch stopwatch = Stopwatch();

  int workloadSum = 0;

  stopwatch.start();

  for(DataPoint dataPoint in data) workloadSum += workloadWithPositionalArguments(dataPoint.x, dataPoint.y);

  stopwatch.stop();

  double microsecondsPerIteration = stopwatch.elapsedTicks / stopwatch.frequency / sampleSize * 1000000;

  results.add([
    true, false, num.parse(microsecondsPerIteration.toStringAsPrecision(2))
  ]);

  stopwatch.reset();

  workloadSum = 0;

  stopwatch.start();

  for(DataPoint dataPoint in data) workloadSum += workloadWithNamedArguments(x: dataPoint.x, y: dataPoint.y);

  stopwatch.stop();

  microsecondsPerIteration = stopwatch.elapsedTicks / stopwatch.frequency / sampleSize * 1000000;

  results.add([
    false, true, num.parse(microsecondsPerIteration.toStringAsPrecision(2))
  ]);

  stopwatch.reset();

  workloadSum = 0;

  stopwatch.start();

  for(DataPoint dataPoint in data) workloadSum += workloadWithPositionalAndNamedArguments(dataPoint.x, y: dataPoint.y);

  stopwatch.stop();

  microsecondsPerIteration = stopwatch.elapsedTicks / stopwatch.frequency / sampleSize * 1000000;

  results.add([
    true, true, num.parse(microsecondsPerIteration.toStringAsPrecision(2))
  ]);

  Table table = Table([
    BooleanColumn('Positional arguments', alignment: Alignment.CENTER),
    BooleanColumn('Named arguments', alignment: Alignment.CENTER),
    NumericColumn('Run time **(μs)**')
  ]);

  print(table.generate(results));
}