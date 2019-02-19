@tatumizer : *Man... this ended up being way more interesting than I expected.*

***Scroll down to the bottom of this comment for a summary of the experiment's results.***

This post will detail my performance tests of [Function.apply](https://api.dartlang.org/stable/2.1.1/dart-core/Function/apply.html) in comparison to the performance of manually destructuring values to function arguments.
# Preface
All the tests detailed in this post were performed in the Dart VM (Dart 2) on Windows 10.  
The runtimes are given in microseconds.
# Attempt 1
My first attempt at testing the performance of [Function.apply](https://api.dartlang.org/stable/2.1.1/dart-core/Function/apply.html).
## Code
**common.dart**
```dart
hypotheticalFunction(int x, int y) {
  return;
}

Stream<int> runFunctionNTimes(Function() function, num numberOfTimes) async* {
  for(num i = 0; i < numberOfTimes; i++) yield function();
}
```
**applyTest.dart**
```dart
import 'common.dart';

main(List<String> args) async {
  final int expectedNumberOfRuns = 100;
  int actualNumberOfRuns = 0;
  int sumOfResults = 0;

  await for(int runTime in runFunctionNTimes(withPositionalArguments, expectedNumberOfRuns)) {
    actualNumberOfRuns++;
    sumOfResults += runTime;
    print(runTime);
  }

  double averageRunTime = sumOfResults / actualNumberOfRuns;

  print('-- With positional arguments\n# of runs: $actualNumberOfRuns\nAverage runtime: $averageRunTime');
}

int withPositionalArguments() {
  final Stopwatch stopwatch = Stopwatch();
  final List<int> arguments = [1, 2];

  stopwatch.start();

  Function.apply(hypotheticalFunction, arguments);

  stopwatch.stop();

  return stopwatch.elapsedMicroseconds;
}
```
## Results
```
1051
21
19
15
13
11
11
12
12
11
11
11
11
11
11
11
15
11
11
11
11
12
11
12
15
12
11
12
11
11
11
11
12
11
11
12
12
12
15
46
42
27
9
38
29
16
15
13
13
15
26
27
21
34
20
16
16
48
21
17
47
17
50
49
18
46
32
46
34
48
45
12
13
12
12
12
12
12
11
13
11
11
14
12
13
13
19
14
13
13
13
14
13
13
13
13
13
14
13
12
-- With positional arguments
# of runs: 100
Average runtime: 35.84
```
After seeing these results, I hypothesized that the VM is optimizing the function calls, as each function call is identical.
# Attempt 2
In this attempt I provided each call with randomly generated arguments.
## Code
**common.dart**
```dart
import 'dart:math';

hypotheticalFunction(int x, int y) {
  return;
}

Stream<int> runFunctionNTimes(Function() function, num numberOfTimes) async* {
  for(num i = 0; i < numberOfTimes; i++) yield function();
}

final int maxRandomNumberValue = pow(2, 32);
final int randomNumberGeneratorSeed = 2587937845;
final Random randomNumberGenerator = Random(randomNumberGeneratorSeed);

int getRandomNumber() => randomNumberGenerator.nextInt(maxRandomNumberValue);
```
**applyTest.dart**
```dart
import 'common.dart';

main(List<String> args) async {
  final int expectedNumberOfRuns = 100;
  int actualNumberOfRuns = 0;
  int sumOfResults = 0;

  await for(int runTime in runFunctionNTimes(withPositionalArguments, expectedNumberOfRuns)) {
    actualNumberOfRuns++;
    sumOfResults += runTime;
    print(runTime);
  }

  double averageRunTime = sumOfResults / actualNumberOfRuns;

  print('-- With positional arguments\n# of runs: $actualNumberOfRuns\nAverage runtime: $averageRunTime');
}

int withPositionalArguments() {
  final Stopwatch stopwatch = Stopwatch();
  final List<int> arguments = [getRandomNumber(), getRandomNumber()];

  stopwatch.start();

  Function.apply(hypotheticalFunction, arguments);

  stopwatch.stop();

  return stopwatch.elapsedMicroseconds;
}
```
## Results
```
1034
16
14
12
11
11
11
11
11
12
12
12
11
11
16
10
11
12
11
23
11
11
12
11
11
11
11
14
12
12
12
12
12
12
12
12
12
11
12
11
12
11
14
12
12
11
11
12
11
12
12
12
12
12
12
11
12
11
13
12
11
12
11
12
10
12
11
12
12
12
12
12
12
12
12
12
11
12
12
11
12
11
11
11
15
11
13
13
11
12
12
12
12
12
12
12
12
12
11
11
-- With positional arguments
# of runs: 100
Average runtime: 22.14
```
It seems like the VM (or the processor) is still optimizing the function calls, and thus I will exclude the first result in future tests.
# Attempt 3
In this attempt, I modified the code so it excludes the first result.  
I've also implemented the other tests.
## Code
**common.dart**
```dart
import 'dart:math';

hypotheticalFunction(int x, int y) {
  return;
}

Stream<int> runFunctionNTimes(Function() function, num numberOfTimes) async* {
  for(num i = 0; i < numberOfTimes; i++) yield function();
}

final int maxRandomNumberValue = pow(2, 32);
final int randomNumberGeneratorSeed = 2587937845;
final Random randomNumberGenerator = Random(randomNumberGeneratorSeed);

int getRandomNumber() => randomNumberGenerator.nextInt(maxRandomNumberValue);
```
**applyTest.dart**
```dart
import 'common.dart';

main(List<String> args) async {
  final int expectedNumberOfRuns = 100;
  int actualNumberOfRuns = 0;
  int sumOfResults = 0;

  bool first = true;

  await for(int runTime in runFunctionNTimes(withPositionalArguments, expectedNumberOfRuns)) {
    if(first) {
      first = false;
      continue;
    }
    actualNumberOfRuns++;
    sumOfResults += runTime;
    print(runTime);
  }

  double averageRunTime = sumOfResults / actualNumberOfRuns;

  print('-- With positional arguments\n# of runs: $actualNumberOfRuns\nAverage runtime: $averageRunTime');

  actualNumberOfRuns = 0;
  sumOfResults = 0;

  first = true;

  await for(int runTime in runFunctionNTimes(withNamedArguments, expectedNumberOfRuns)) {
    if(first) {
      first = false;
      continue;
    }
    actualNumberOfRuns++;
    sumOfResults += runTime;
    print(runTime);
  }

  averageRunTime = sumOfResults / actualNumberOfRuns;

  print('-- With named arguments\n# of runs: $actualNumberOfRuns\nAverage runtime: $averageRunTime');

  actualNumberOfRuns = 0;
  sumOfResults = 0;

  first = true;

  await for(int runTime in runFunctionNTimes(withPositionalAndNamedArguments, expectedNumberOfRuns)) {
    if(first) {
      first = false;
      continue;
    }
    actualNumberOfRuns++;
    sumOfResults += runTime;
    print(runTime);
  }

  averageRunTime = sumOfResults / actualNumberOfRuns;

  print('-- With positional and named arguments\n# of runs: $actualNumberOfRuns\nAverage runtime: $averageRunTime');
}

int withPositionalArguments() {
  final Stopwatch stopwatch = Stopwatch();
  final List<int> arguments = [getRandomNumber(), getRandomNumber()];

  stopwatch.start();

  Function.apply(hypotheticalFunction, arguments);

  stopwatch.stop();

  return stopwatch.elapsedMicroseconds;
}

int withNamedArguments() {
  final Stopwatch stopwatch = Stopwatch();
  final Map<Symbol, int> namedArguments = {Symbol('x'): getRandomNumber(), Symbol('y'): getRandomNumber()};

  stopwatch.start();

  Function.apply(hypotheticalFunctionWithNamedArguments, [], namedArguments);

  stopwatch.stop();

  return stopwatch.elapsedMicroseconds;
}

int withPositionalAndNamedArguments() {
  final Stopwatch stopwatch = Stopwatch();
  final List<int> positionalArguments = [getRandomNumber(), getRandomNumber()];
  final Map<Symbol, int> namedArguments = {Symbol('z'): getRandomNumber(), Symbol('w'): getRandomNumber()};

  stopwatch.start();

  Function.apply(hypotheticalFunctionWithPositionalAndNamedArguments, positionalArguments, namedArguments);

  stopwatch.stop();

  return stopwatch.elapsedMicroseconds;
}
```
**verboseTest.dart**
```dart
import 'common.dart';

main(List<String> args) async {
  final int expectedNumberOfRuns = 100;
  int actualNumberOfRuns = 0;
  int sumOfResults = 0;

  bool first = true;

  await for(int runTime in runFunctionNTimes(withPositionalArguments, expectedNumberOfRuns)) {
    if(first) {
      first = false;
      continue;
    }
    actualNumberOfRuns++;
    sumOfResults += runTime;
    print(runTime);
  }

  double averageRunTime = sumOfResults / actualNumberOfRuns;

  print('-- With positional arguments\n# of runs: $actualNumberOfRuns\nAverage runtime: $averageRunTime');

  actualNumberOfRuns = 0;
  sumOfResults = 0;

  first = true;

  await for(int runTime in runFunctionNTimes(withNamedArguments, expectedNumberOfRuns)) {
    if(first) {
      first = false;
      continue;
    }
    actualNumberOfRuns++;
    sumOfResults += runTime;
    print(runTime);
  }

  averageRunTime = sumOfResults / actualNumberOfRuns;

  print('-- With named arguments\n# of runs: $actualNumberOfRuns\nAverage runtime: $averageRunTime');

  actualNumberOfRuns = 0;
  sumOfResults = 0;

  first = true;

  await for(int runTime in runFunctionNTimes(withPositionalAndNamedArguments, expectedNumberOfRuns)) {
    if(first) {
      first = false;
      continue;
    }
    actualNumberOfRuns++;
    sumOfResults += runTime;
    print(runTime);
  }

  averageRunTime = sumOfResults / actualNumberOfRuns;

  print('-- With positional and named arguments\n# of runs: $actualNumberOfRuns\nAverage runtime: $averageRunTime');
}

int withPositionalArguments() {
  final Stopwatch stopwatch = Stopwatch();
  final List<int> arguments = [getRandomNumber(), getRandomNumber()];

  stopwatch.start();

  hypotheticalFunction(arguments[0], arguments[1]);

  stopwatch.stop();

  return stopwatch.elapsedMicroseconds;
}

int withNamedArguments() {
  final Stopwatch stopwatch = Stopwatch();
  final Map<String, int> namedArguments = {'x': getRandomNumber(), 'y': getRandomNumber()};

  stopwatch.start();

  hypotheticalFunctionWithNamedArguments(x: namedArguments['x'], y: namedArguments['y']);

  stopwatch.stop();

  return stopwatch.elapsedMicroseconds;
}

int withPositionalAndNamedArguments() {
  final Stopwatch stopwatch = Stopwatch();
  final List<int> positionalArguments = [getRandomNumber(), getRandomNumber()];
  final Map<String, int> namedArguments = {'z': getRandomNumber(), 'w': getRandomNumber()};

  stopwatch.start();

  hypotheticalFunctionWithPositionalAndNamedArguments(
    positionalArguments[0], positionalArguments[1],
    z: namedArguments['z'], w: namedArguments['w']
  );

  stopwatch.stop();

  return stopwatch.elapsedMicroseconds;
}
```
## Results
**Using [Function.apply](https://api.dartlang.org/stable/2.1.1/dart-core/Function/apply.html)**
```
10
13
9
9
9
9
9
9
9
10
14
15
14
12
9
9
9
9
9
9
15
9
9
10
10
10
10
10
13
28
16
15
15
14
15
14
14
14
14
13
15
30
19
14
14
14
12
13
13
14
13
13
17
13
13
13
13
13
12
13
13
20
15
12
14
13
14
12
13
13
13
13
26
13
13
14
12
12
12
13
13
13
13
12
12
12
12
13
12
12
12
12
12
12
12
12
12
12
12
-- With positional arguments
# of runs: 99
Average runtime: 12.88888888888889
22
99
43
43
42
40
55
42
41
43
41
41
42
20
30
26
22
21
19
18
18
19
18
18
40
41
41
40
41
40
37
210
34
25
29
20
18
42
41
43
41
41
56
42
40
40
42
41
41
21
34
29
29
24
27
26
29
23
22
20
23
23
27
29
26
33
69
48
41
34
28
26
31
24
23
25
29
22
20
21
27
22
26
39
33
39
29
60
23
26
25
23
24
23
26
27
24
23
24
-- With named arguments
# of runs: 99
Average runtime: 34.121212121212125
41
44
50
40
35
40
36
38
75
39
37
38
38
39
35
49
48
56
55
52
54
45
83
47
46
41
40
43
40
55
33
45
46
51
45
53
52
38
41
33
35
32
34
35
32
29
29
61
39
36
41
36
31
32
36
32
33
32
36
32
44
31
42
50
29
32
35
50
64
60
52
50
51
49
43
27
30
52
52
29
41
37
40
33
30
31
35
32
30
32
40
29
42
29
33
63
48
30
34
-- With positional and named arguments
# of runs: 99
Average runtime: 41.21212121212121
```
**Verbose**
```
1
0
0
0
0
0
0
0
0
0
0
0
0
1
1
0
0
1
1
0
0
0
0
0
0
0
0
0
0
0
0
0
1
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
-- With positional arguments
# of runs: 99
Average runtime: 0.06060606060606061
3
20
4
18
4
22
4
18
3
5
3
19
3
19
3
4
3
18
3
3
6
4
3
4
3
5
7
4
4
4
4
4
5
5
6
4
4
20
4
18
4
19
5
19
5
22
5
20
7
4
21
4
5
5
5
5
5
5
6
5
5
21
4
4
4
4
19
3
5
5
4
20
4
4
4
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
2
2
2
3
3
3
3
3
-- With named arguments
# of runs: 99
Average runtime: 6.585858585858586
4
6
5
4
4
3
3
3
3
3
3
6
21
2
7
4
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
2
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
3
5
5
3
3
4
3
3
3
3
3
2
3
2
7
24
5
5
27
14
-- With positional and named arguments
# of runs: 99
Average runtime: 4.0
```
As you can see, performance-wise the verbose method is far superior to [Function.apply](https://api.dartlang.org/stable/2.1.1/dart-core/Function/apply.html).
# Attempt 5
The previous experiment showed that the verbose method provided sub-microsecond runtimes, thus I decided to increase the accuracy of the measurements, I've done this by converting the number elapsed clock ticks to microseconds using the clock's frequency.
## Code
**common.dart**
```dart
import 'dart:math';

hypotheticalFunction(int x, int y) {
  return;
}

hypotheticalFunctionWithNamedArguments({int x, int y}) {
  return;
}

hypotheticalFunctionWithPositionalAndNamedArguments(int x, int y, {int z, int w}) {
  return;
}

Stream<num> runFunctionNTimes(Function() function, num numberOfTimes) async* {
  for(num i = 0; i < numberOfTimes; i++) yield function();
}

final int maxRandomNumberValue = pow(2, 32);
final int randomNumberGeneratorSeed = 2587937845;
final Random randomNumberGenerator = Random(randomNumberGeneratorSeed);

int getRandomNumber() => randomNumberGenerator.nextInt(maxRandomNumberValue);

final int clockFrequency = 2648436;
final int millisecondsPerSecond = 1000000;

num convertClockTicksToMicroseconds(int clockTicks) => clockTicks / clockFrequency * millisecondsPerSecond;
```
**applyTest.dart**
```dart
import 'common.dart';

main(List<String> args) async {
  final int expectedNumberOfRuns = 100;
  int actualNumberOfRuns = 0;
  num sumOfResults = 0;

  bool first = true;

  await for(num runTime in runFunctionNTimes(withPositionalArguments, expectedNumberOfRuns)) {
    if(first) {
      first = false;
      continue;
    }
    actualNumberOfRuns++;
    sumOfResults += runTime;
    print(runTime);
  }

  double averageRunTime = sumOfResults / actualNumberOfRuns;

  print('-- With positional arguments\n# of runs: $actualNumberOfRuns\nAverage runtime: $averageRunTime');

  actualNumberOfRuns = 0;
  sumOfResults = 0;

  first = true;

  await for(num runTime in runFunctionNTimes(withNamedArguments, expectedNumberOfRuns)) {
    if(first) {
      first = false;
      continue;
    }
    actualNumberOfRuns++;
    sumOfResults += runTime;
    print(runTime);
  }

  averageRunTime = sumOfResults / actualNumberOfRuns;

  print('-- With named arguments\n# of runs: $actualNumberOfRuns\nAverage runtime: $averageRunTime');

  actualNumberOfRuns = 0;
  sumOfResults = 0;

  first = true;

  await for(num runTime in runFunctionNTimes(withPositionalAndNamedArguments, expectedNumberOfRuns)) {
    if(first) {
      first = false;
      continue;
    }
    actualNumberOfRuns++;
    sumOfResults += runTime;
    print(runTime);
  }

  averageRunTime = sumOfResults / actualNumberOfRuns;

  print('-- With positional and named arguments\n# of runs: $actualNumberOfRuns\nAverage runtime: $averageRunTime');
}

num withPositionalArguments() {
  final Stopwatch stopwatch = Stopwatch();
  final List<int> arguments = [getRandomNumber(), getRandomNumber()];

  stopwatch.start();

  Function.apply(hypotheticalFunction, arguments);

  stopwatch.stop();

  return convertClockTicksToMicroseconds(stopwatch.elapsedTicks);
}

num withNamedArguments() {
  final Stopwatch stopwatch = Stopwatch();
  final Map<Symbol, int> namedArguments = {Symbol('x'): getRandomNumber(), Symbol('y'): getRandomNumber()};

  stopwatch.start();

  Function.apply(hypotheticalFunctionWithNamedArguments, [], namedArguments);

  stopwatch.stop();

  return convertClockTicksToMicroseconds(stopwatch.elapsedTicks);
}

num withPositionalAndNamedArguments() {
  final Stopwatch stopwatch = Stopwatch();
  final List<int> positionalArguments = [getRandomNumber(), getRandomNumber()];
  final Map<Symbol, int> namedArguments = {Symbol('z'): getRandomNumber(), Symbol('w'): getRandomNumber()};

  stopwatch.start();

  Function.apply(hypotheticalFunctionWithPositionalAndNamedArguments, positionalArguments, namedArguments);

  stopwatch.stop();

  return convertClockTicksToMicroseconds(stopwatch.elapsedTicks);
}
```
**verboseTest.dart**
```dart
import 'common.dart';

main(List<String> args) async {
  final int expectedNumberOfRuns = 100;
  int actualNumberOfRuns = 0;
  num sumOfResults = 0;

  bool first = true;

  await for(num runTime in runFunctionNTimes(withPositionalArguments, expectedNumberOfRuns)) {
    if(first) {
      first = false;
      continue;
    }
    actualNumberOfRuns++;
    sumOfResults += runTime;
    print(runTime);
  }

  double averageRunTime = sumOfResults / actualNumberOfRuns;

  print('-- With positional arguments\n# of runs: $actualNumberOfRuns\nAverage runtime: $averageRunTime');

  actualNumberOfRuns = 0;
  sumOfResults = 0;

  first = true;

  await for(num runTime in runFunctionNTimes(withNamedArguments, expectedNumberOfRuns)) {
    if(first) {
      first = false;
      continue;
    }
    actualNumberOfRuns++;
    sumOfResults += runTime;
    print(runTime);
  }

  averageRunTime = sumOfResults / actualNumberOfRuns;

  print('-- With named arguments\n# of runs: $actualNumberOfRuns\nAverage runtime: $averageRunTime');

  actualNumberOfRuns = 0;
  sumOfResults = 0;

  first = true;

  await for(num runTime in runFunctionNTimes(withPositionalAndNamedArguments, expectedNumberOfRuns)) {
    if(first) {
      first = false;
      continue;
    }
    actualNumberOfRuns++;
    sumOfResults += runTime;
    print(runTime);
  }

  averageRunTime = sumOfResults / actualNumberOfRuns;

  print('-- With positional and named arguments\n# of runs: $actualNumberOfRuns\nAverage runtime: $averageRunTime');
}

num withPositionalArguments() {
  final Stopwatch stopwatch = Stopwatch();
  final List<int> arguments = [getRandomNumber(), getRandomNumber()];

  stopwatch.start();

  hypotheticalFunction(arguments[0], arguments[1]);

  stopwatch.stop();

  return convertClockTicksToMicroseconds(stopwatch.elapsedTicks);
}

num withNamedArguments() {
  final Stopwatch stopwatch = Stopwatch();
  final Map<String, int> namedArguments = {'x': getRandomNumber(), 'y': getRandomNumber()};

  stopwatch.start();

  hypotheticalFunctionWithNamedArguments(x: namedArguments['x'], y: namedArguments['y']);

  stopwatch.stop();

  return convertClockTicksToMicroseconds(stopwatch.elapsedTicks);
}

num withPositionalAndNamedArguments() {
  final Stopwatch stopwatch = Stopwatch();
  final List<int> positionalArguments = [getRandomNumber(), getRandomNumber()];
  final Map<String, int> namedArguments = {'z': getRandomNumber(), 'w': getRandomNumber()};

  stopwatch.start();

  hypotheticalFunctionWithPositionalAndNamedArguments(
    positionalArguments[0], positionalArguments[1],
    z: namedArguments['z'], w: namedArguments['w']
  );

  stopwatch.stop();

  return convertClockTicksToMicroseconds(stopwatch.elapsedTicks);
}
```
## Results
**Using [Function.apply](https://api.dartlang.org/stable/2.1.1/dart-core/Function/apply.html)**
```
15.103253391813132
16.235997396199117
17.746322735380428
10.194696039473863
10.194696039473863
9.817114704678534
9.817114704678534
9.439533369883206
9.439533369883206
9.817114704678534
9.439533369883206
9.817114704678534
9.439533369883206
9.439533369883206
9.817114704678534
9.439533369883206
9.817114704678534
9.439533369883206
9.817114704678534
9.817114704678534
9.817114704678534
9.817114704678534
9.817114704678534
9.439533369883206
9.439533369883206
9.439533369883206
9.817114704678534
9.439533369883206
9.817114704678534
9.439533369883206
9.439533369883206
9.817114704678534
9.817114704678534
9.817114704678534
11.705021378655175
9.439533369883206
9.439533369883206
9.817114704678534
9.817114704678534
9.817114704678534
9.817114704678534
9.817114704678534
9.439533369883206
10.194696039473863
11.327440043859848
9.817114704678534
9.817114704678534
9.817114704678534
9.817114704678534
9.439533369883206
9.439533369883206
9.817114704678534
9.817114704678534
9.817114704678534
29.073762779240276
9.817114704678534
9.817114704678534
12.082602713450504
9.817114704678534
9.439533369883206
9.817114704678534
11.327440043859848
9.817114704678534
9.439533369883206
9.817114704678534
9.817114704678534
12.460184048245832
31.339250788012244
13.970509387427144
9.817114704678534
11.327440043859848
9.817114704678534
9.439533369883206
9.817114704678534
9.817114704678534
9.439533369883206
9.817114704678534
9.817114704678534
9.439533369883206
9.439533369883206
13.592928052631816
12.460184048245832
9.817114704678534
9.817114704678534
9.817114704678534
9.439533369883206
9.439533369883206
9.817114704678534
9.817114704678534
9.439533369883206
9.817114704678534
9.439533369883206
9.817114704678534
9.817114704678534
9.817114704678534
9.439533369883206
9.439533369883206
9.439533369883206
9.439533369883206
-- With positional arguments
# of runs: 99
Average runtime: 10.537951798378694
15.48083472660846
24.542786761696338
20.389392078947726
18.123904070175758
18.123904070175758
23.032461422515023
18.501485404971085
17.746322735380428
18.123904070175758
18.123904070175758
17.746322735380428
17.3687414005851
17.746322735380428
18.123904070175758
18.123904070175758
17.746322735380428
18.501485404971085
18.123904070175758
18.123904070175758
17.746322735380428
20.766973413743052
17.746322735380428
17.3687414005851
18.123904070175758
19.63422940935707
19.256648074561742
26.808274770468305
43.42185350146275
46.8200855146207
35.115064135965525
28.31860010964962
21.144554748538383
41.91152816228144
20.766973413743052
23.032461422515023
19.63422940935707
19.63422940935707
29.828925448830933
20.0118107441524
13.970509387427144
13.592928052631816
13.592928052631816
15.103253391813132
13.970509387427144
13.592928052631816
13.592928052631816
15.858416061403787
13.592928052631816
18.87906673976641
13.592928052631816
15.103253391813132
13.970509387427144
13.970509387427144
13.970509387427144
13.970509387427144
13.592928052631816
18.123904070175758
34.7374828011702
33.98232013157954
41.91152816228144
17.3687414005851
17.3687414005851
13.970509387427144
13.970509387427144
13.592928052631816
14.725672057017803
14.348090722222473
14.348090722222473
22.654880087719697
13.970509387427144
13.970509387427144
13.592928052631816
13.592928052631816
13.592928052631816
13.970509387427144
13.592928052631816
13.592928052631816
13.592928052631816
13.592928052631816
13.592928052631816
13.970509387427144
13.970509387427144
13.592928052631816
13.592928052631816
13.592928052631816
15.103253391813132
14.725672057017803
14.725672057017803
32.471994792398235
30.584088118421587
23.78762409210568
19.63422940935707
13.970509387427144
13.21534671783649
18.501485404971085
24.165205426901007
18.87906673976641
19.256648074561742
17.746322735380428
-- With named arguments
# of runs: 99
Average runtime: 18.90957836278018
24.542786761696338
29.828925448830933
26.808274770468305
32.471994792398235
27.185856105263632
42.666690831872096
42.289109497076765
39.64604015350947
27.563437440058962
26.808274770468305
26.808274770468305
25.67553076608232
25.67553076608232
28.31860010964962
26.053112100877648
30.96166945321692
24.920368096491664
29.451344114035606
25.29794943128699
38.513296149123484
25.29794943128699
27.94101877485429
28.696181444444946
25.29794943128699
27.94101877485429
26.808274770468305
25.29794943128699
26.808274770468305
25.29794943128699
25.29794943128699
26.808274770468305
26.053112100877648
25.29794943128699
25.67553076608232
25.67553076608232
25.67553076608232
22.277298752924366
33.60473879678421
26.43069343567298
25.67553076608232
25.29794943128699
25.29794943128699
25.67553076608232
27.185856105263632
26.808274770468305
31.339250788012244
34.35990146637487
34.7374828011702
58.90268822807121
43.79943483625808
44.93217884064406
66.07673358918245
44.17701617105341
51.35106153216464
28.696181444444946
34.7374828011702
31.716832122807574
30.96166945321692
53.99413087573194
36.247808140351516
29.828925448830933
21.144554748538383
19.256648074561742
20.766973413743052
18.87906673976641
18.87906673976641
19.256648074561742
23.78762409210568
18.87906673976641
18.87906673976641
19.256648074561742
25.29794943128699
19.256648074561742
19.256648074561742
18.87906673976641
26.053112100877648
31.339250788012244
33.22715746198889
35.87022680555618
58.14752555848055
44.17701617105341
33.98232013157954
60.0354322324572
33.22715746198889
26.053112100877648
27.185856105263632
23.032461422515023
23.78762409210568
24.542786761696338
26.053112100877648
23.032461422515023
22.654880087719697
24.165205426901007
26.053112100877648
27.563437440058962
35.115064135965525
26.808274770468305
30.206506783626264
30.584088118421587
-- With positional and named arguments
# of runs: 99
Average runtime: 29.79841382581717
```
**Verbose**
```
1.1327440043859849
0.7551626695906565
0.37758133479532824
0.7551626695906565
0.7551626695906565
0.37758133479532824
0.7551626695906565
0.37758133479532824
0.7551626695906565
0.7551626695906565
0.37758133479532824
0.7551626695906565
0.37758133479532824
1.1327440043859849
0.7551626695906565
1.1327440043859849
0.7551626695906565
0.7551626695906565
0.7551626695906565
1.1327440043859849
1.1327440043859849
0.37758133479532824
1.1327440043859849
0.7551626695906565
0.7551626695906565
2.643069343567298
1.510325339181313
1.1327440043859849
0.7551626695906565
1.1327440043859849
3.398232013157954
1.510325339181313
1.1327440043859849
0.7551626695906565
1.1327440043859849
0.7551626695906565
0.7551626695906565
1.1327440043859849
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
1.1327440043859849
1.1327440043859849
0.7551626695906565
0.7551626695906565
0.7551626695906565
1.1327440043859849
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.37758133479532824
1.510325339181313
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
16.99116006578977
0.7551626695906565
0.7551626695906565
0.37758133479532824
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
1.1327440043859849
0.7551626695906565
0.7551626695906565
0.7551626695906565
0.7551626695906565
-- With positional arguments
# of runs: 99
Average runtime: 1.0145114652076495
6.41888269152058
15.48083472660846
23.78762409210568
21.52213608333371
21.52213608333371
20.0118107441524
3.775813347953283
30.584088118421587
27.185856105263632
6.41888269152058
3.398232013157954
3.398232013157954
4.153394682748611
3.398232013157954
3.020650678362626
3.020650678362626
3.020650678362626
3.020650678362626
3.020650678362626
2.643069343567298
3.020650678362626
3.020650678362626
3.020650678362626
3.020650678362626
3.020650678362626
3.020650678362626
3.020650678362626
3.020650678362626
3.020650678362626
6.041301356725252
3.775813347953283
3.020650678362626
3.020650678362626
3.020650678362626
3.020650678362626
3.020650678362626
3.020650678362626
3.398232013157954
3.020650678362626
3.020650678362626
3.020650678362626
5.286138687134596
19.63422940935707
5.663720021929924
4.153394682748611
30.584088118421587
5.286138687134596
6.041301356725252
3.398232013157954
3.020650678362626
3.020650678362626
3.398232013157954
3.398232013157954
3.020650678362626
3.398232013157954
3.398232013157954
3.775813347953283
3.020650678362626
3.020650678362626
2.643069343567298
2.643069343567298
2.2654880087719698
3.020650678362626
2.643069343567298
3.020650678362626
2.643069343567298
2.643069343567298
2.643069343567298
3.020650678362626
3.020650678362626
2.643069343567298
3.020650678362626
2.643069343567298
2.643069343567298
3.020650678362626
4.908557352339267
3.020650678362626
3.020650678362626
2.643069343567298
3.020650678362626
4.908557352339267
3.398232013157954
3.020650678362626
2.643069343567298
7.1740453611112365
5.286138687134596
4.5309760175439395
4.5309760175439395
4.153394682748611
4.153394682748611
3.020650678362626
3.398232013157954
5.663720021929924
4.153394682748611
3.775813347953283
21.144554748538383
3.398232013157954
4.153394682748611
4.5309760175439395
-- With named arguments
# of runs: 99
Average runtime: 5.522603765491264
2.643069343567298
6.041301356725252
3.020650678362626
6.041301356725252
4.5309760175439395
4.908557352339267
4.5309760175439395
4.153394682748611
4.153394682748611
21.52213608333371
3.775813347953283
3.020650678362626
3.398232013157954
4.5309760175439395
4.908557352339267
3.398232013157954
4.153394682748611
3.398232013157954
4.153394682748611
21.89971741812904
3.775813347953283
7.1740453611112365
23.78762409210568
5.663720021929924
3.398232013157954
3.020650678362626
3.020650678362626
2.643069343567298
3.020650678362626
2.643069343567298
2.643069343567298
3.020650678362626
3.020650678362626
4.908557352339267
4.5309760175439395
4.908557352339267
5.663720021929924
21.52213608333371
21.52213608333371
4.5309760175439395
5.663720021929924
3.775813347953283
3.398232013157954
3.398232013157954
3.398232013157954
3.398232013157954
3.020650678362626
3.398232013157954
3.020650678362626
3.020650678362626
3.398232013157954
3.020650678362626
3.775813347953283
3.398232013157954
3.020650678362626
3.398232013157954
3.398232013157954
2.643069343567298
2.643069343567298
3.020650678362626
3.020650678362626
3.020650678362626
3.398232013157954
3.398232013157954
2.643069343567298
2.643069343567298
3.020650678362626
3.020650678362626
3.398232013157954
3.398232013157954
3.020650678362626
3.398232013157954
3.020650678362626
3.398232013157954
2.643069343567298
3.020650678362626
2.643069343567298
7.551626695906566
3.775813347953283
3.020650678362626
3.398232013157954
3.398232013157954
3.020650678362626
3.020650678362626
3.020650678362626
3.020650678362626
3.020650678362626
3.398232013157954
3.020650678362626
3.020650678362626
3.020650678362626
3.775813347953283
6.041301356725252
3.775813347953283
3.398232013157954
3.775813347953283
3.398232013157954
3.775813347953283
3.398232013157954
-- With positional and named arguments
# of runs: 99
Average runtime: 4.565301593434423
```
# Summary of results
## [Function.apply](https://api.dartlang.org/stable/2.1.1/dart-core/Function/apply.html)
| Positional arguments | Named arguments | Average runtime (μs) |
|:---:|:---:| --- |
| ✔️ | ❌ | 10,5 |
| ❌ | ✔️ | 18,9 |
| ✔️ | ✔️ | 29,8 |
## Verbose
| Positional arguments | Named arguments | Average runtime (μs) |
|:---:|:---:| --- |
| ✔️ | ❌ | 1,0 |
| ❌ | ✔️ | 5,5 |
| ✔️ | ✔️ | 4,6 |
# Conclusion
My conclusion is that the more verbose method is far superior to [Function.apply](https://api.dartlang.org/stable/2.1.1/dart-core/Function/apply.html). Thus, destructuring in the context of arguments should be considered in my opinion.