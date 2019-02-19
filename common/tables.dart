class Table {
  final List<Column> columns;

  const Table(this.columns);

  String generate(Iterable<List<dynamic>> values) {
    String result = headers;

    for(List<dynamic> row in values) {
      result += '\n|';

      for(int i = 0; i < columns.length; i++) {
        String value = columns[i].process(row[i]);

        result += ' $value |';
      }
    }

    return result;
  }

  String get headers {
    String row1 = '|';
    String row2 = '|';

    for(Column column in columns) {
      row1 += ' ${column.title} |';

      switch(column.alignment) {
        case Alignment.LEFT:
        row2 += ' --- |';
        break;
        case Alignment.CENTER:
        row2 += ':---:|';
        break;
        case Alignment.RIGHT:
        row2 += ' ---:|';
        break;
      }
    }

    return '$row1\n$row2';
  }
}

typedef String Processor<T>(T value);

String defaultProcessor(dynamic value) => value as String;
String defaultNumericProcessor(dynamic value) {
  String withComma = value.toString().replaceAll('.', ',');
  String withDotSeperation = '';

  int commaIndex = -1;

  for(int i = withComma.length - 1; i >= 0; i--) {
    if(commaIndex != -1) {
      if(i - commaIndex != -1 && ((i - commaIndex + 1) % 3 == 0) && withComma[i] != '-') {
        withDotSeperation = '.$withDotSeperation';
      }
      withDotSeperation = '${withComma[i]}$withDotSeperation';
    } else {
      withDotSeperation = '${withComma[i]}$withDotSeperation';
      if(withComma[i] == ',') commaIndex = i;
    }
  }

  return withDotSeperation;
}
String defaultBooleanProcessor(dynamic value) => value as bool ? ':heavy_check_mark:' : ':x:';

enum Alignment {
  LEFT, CENTER, RIGHT
}

class Column<T> {
  String title;
  Alignment alignment;
  Processor process;

  Column(this.title, {this.alignment = Alignment.LEFT, this.process = defaultProcessor});
}

class NumericColumn extends Column<num> {
  NumericColumn(
    String title,
    {
      Alignment alignment = Alignment.LEFT,
      Processor<num> process = defaultNumericProcessor
    }) : super(title, alignment: alignment, process: process);
}

class BooleanColumn extends Column<bool> {
  BooleanColumn(
    String title,
    {
      Alignment alignment = Alignment.LEFT,
      Processor<num> process = defaultBooleanProcessor
    }) : super(title, alignment: alignment, process: process);
}