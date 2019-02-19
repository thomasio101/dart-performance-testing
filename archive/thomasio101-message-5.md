@tatumizer : Based on your constructive criticism, I have redesigned the experiment, here it is!
# Code
**simpleTest.dart**
```dart
import 'dart:math';

final int maxInteger = pow(2, 32);

main(List<String> args) {
  final int numberOfIterations = int.parse(args[0]);
  final int seed = int.parse(args[1]);

  final Random rng = Random(seed);
  final Stopwatch stopwatch = Stopwatch();

  int workloadSum = 0;

  // Positional arguments + Function.apply

  stopwatch.start();

  for(int i = 0; i < numberOfIterations; i++) {
    final List<int> positionalArguments = [rng.nextInt(maxInteger), rng.nextInt(maxInteger)];
    workloadSum += Function.apply(workloadWithPositionalArguments, positionalArguments);
  }

  stopwatch.stop();

  num microSecondsPerIteration = stopwatch.elapsedTicks / stopwatch.frequency / numberOfIterations * 1000000;

  print('Positional arguments + Function.apply: $microSecondsPerIteration');

  // Positional arguments + verbose

  stopwatch.reset();

  stopwatch.start();

  for(int i = 0; i < numberOfIterations; i++) {
    final List<int> positionalArguments = [rng.nextInt(maxInteger), rng.nextInt(maxInteger)];
    workloadSum += workloadWithPositionalArguments(positionalArguments[0], positionalArguments[1]);
  }

  stopwatch.stop();

  microSecondsPerIteration = stopwatch.elapsedTicks / stopwatch.frequency / numberOfIterations * 1000000;

  print('Positional arguments + verbose: $microSecondsPerIteration');

  // Named arguments + Function.apply

  stopwatch.reset();

  stopwatch.start();

  for(int i = 0; i < numberOfIterations; i++) {
    final Map<Symbol, int> namedArguments = {
      Symbol('x'): rng.nextInt(maxInteger),
      Symbol('y'): rng.nextInt(maxInteger)
    };

    workloadSum += Function.apply(workloadWithNamedArguments, [], namedArguments);
  }

  stopwatch.stop();

  microSecondsPerIteration = stopwatch.elapsedTicks / stopwatch.frequency / numberOfIterations * 1000000;

  print('Named arguments + Function.apply: $microSecondsPerIteration');

  // Named arguments + verbose

  stopwatch.reset();

  stopwatch.start();

  for(int i = 0; i < numberOfIterations; i++) {
    final Map<String, int> namedArguments = {
      'x': rng.nextInt(maxInteger),
      'y': rng.nextInt(maxInteger)
    };

    workloadSum += workloadWithNamedArguments(x: namedArguments['x'], y: namedArguments['y']);
  }

  stopwatch.stop();

  microSecondsPerIteration = stopwatch.elapsedTicks / stopwatch.frequency / numberOfIterations * 1000000;

  print('Named arguments + verbose: $microSecondsPerIteration');

  // Positional + named arguments + Function.apply

  stopwatch.reset();

  stopwatch.start();

  for(int i = 0; i < numberOfIterations; i++) {
    final List<int> positionalArguments = [rng.nextInt(maxInteger), rng.nextInt(maxInteger)];

    final Map<Symbol, int> namedArguments = {
      Symbol('z'): rng.nextInt(maxInteger),
      Symbol('w'): rng.nextInt(maxInteger)
    };

    workloadSum += Function.apply(workloadWithPositionalAndNamedArguments, positionalArguments, namedArguments);
  }

  stopwatch.stop();

  microSecondsPerIteration = stopwatch.elapsedTicks / stopwatch.frequency / numberOfIterations * 1000000;

  print('Positional arguments + named arguments + Function.apply: $microSecondsPerIteration');

  // Positional arguments + named arguments + verbose

  stopwatch.reset();

  stopwatch.start();

  for(int i = 0; i < numberOfIterations; i++) {
    final List<int> positionalArguments = [rng.nextInt(maxInteger), rng.nextInt(maxInteger)];

    final Map<String, int> namedArguments = {
      'z': rng.nextInt(maxInteger),
      'w': rng.nextInt(maxInteger)
    };

    workloadSum += workloadWithPositionalAndNamedArguments(positionalArguments[0], positionalArguments[1], z: namedArguments['z'], w: namedArguments['w']);
  }

  stopwatch.stop();

  microSecondsPerIteration = stopwatch.elapsedTicks / stopwatch.frequency / numberOfIterations * 1000000;

  print('Positional arguments + named arguments + verbose: $microSecondsPerIteration');
}

int workloadWithPositionalArguments(int x, int y) {
  return x * y;
}

int workloadWithNamedArguments({int x, int y}) {
  return x * y;
}

int workloadWithPositionalAndNamedArguments(int x, int y, {int z, int w}) {
  return x * y * z * w;
}
```
# Execution
I ran the following command;
```
dart .\simpleTest.dart 20000000 2587937845
```
**This runs the test with 20000000 iterations, and provides the random number generator with the following seed; `2587937845`.**
# Results
The program outputted the following results to the console;
```
Positional arguments + Function.apply: 0.28505682221507334
Positional arguments + verbose: 0.033560882724747734
Named arguments + Function.apply: 3.4785595158803155
Named arguments + verbose: 0.17321951521577264
Positional arguments + named arguments + Function.apply: 3.4713856026726715
Positional arguments + named arguments + verbose: 0.2015003571919427
```
| Positional arguments | Named arguments | Average run time (μs)<br>*[Function.apply](https://api.dartlang.org/stable/2.1.1/dart-core/Function/apply.html)* | Average run time (μs)<br>*verbose*
|:---:|:---:| --- | --- |
| ✔️ | ❌ | 0.29 | 0.03 |
| ❌ | ✔️ | 3,48 | 0,17 |
| ✔️ | ✔️ | 3,47 | 0,20 |
# Conclusion
In the case of positional arguments, your hypothesis is partially correct; both methods will result in sub-microsecond run times, although the verbose method still provides a tenfold performance improvement over [Function.apply](https://api.dartlang.org/stable/2.1.1/dart-core/Function/apply.html). Whenever named arguments get involved, however, your hypothesis fails, as the verbose method still provides sub-microsecond performance, where [Function.apply](https://api.dartlang.org/stable/2.1.1/dart-core/Function/apply.html) fails to do so.
# Remarks
## Result precision
Tomorrow I will try to provide more data on the performance of these methods, firstly, I think I'll need to provide more context on the error margin of the provided measurements. As I have noticed a slight margin when repeating the test. (The conclusion still holds, though.) Secondly, I'll run the experiment with an increased sample size, to reduce the likelihood of significant errors.
## Introducing additional variables
I'd like to expand the experiment to measure the influence of factors such as the number of arguments, or even the effect of the, by both of us aforementioned, optimization that the VM - and the CPU, as I personally suspect - performs.
## Improved visualization
- I could potentially write a simple Dart library that can take data and provide me with a formatted markdown table. (I've already got an idea for this.)
- I think a number of graphs could be useful, especially for visualizing the error margin.
## Underlying causes
I'm actually quite interested in this performance differential's cause, I do have a few suspects:
- Unnecessary casting by [`Function.apply`](https://api.dartlang.org/stable/2.1.1/dart-core/Function/apply.html)
- Overhead caused by iterating over the [`Map<Symbol, dynamic>`](https://api.dartlang.org/stable/2.1.1/dart-core/Map-class.html) containing the named arguments.

> *I have to much free time*
> -Me, at 23:30 in the evening, writing a research paper on the performance gains from a piece of syntactic sugar.

**EDIT** So... I just realized that, even though I didn't print `workloadSum`, there is still significant scaling of the run time when the number of iterations is increased, which means the optimizer didn't realize that `workloadSum` is actually a dead variable... I should sleep now.