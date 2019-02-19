import 'dart:math';

const int maxInteger = 4294967296;

class DataPoint {
  final int x;
  final int y;

  const DataPoint(this.x, this.y);

  factory DataPoint.random(Random randomNumberGenerator, {int maxX = maxInteger, int maxY = maxInteger}) {
    return DataPoint(
      randomNumberGenerator.nextInt(maxX),
      randomNumberGenerator.nextInt(maxY)
    );
  }

  static Stream<DataPoint> generateNDataPoints(int numberOfDataPoints, Random randomNumberGenerator, {int maxX = maxInteger, int maxY = maxInteger}) async* {
    for(int i = 0; i < numberOfDataPoints; i++) {
      yield DataPoint.random(randomNumberGenerator, maxX: maxX, maxY: maxY);
    }
  }
}