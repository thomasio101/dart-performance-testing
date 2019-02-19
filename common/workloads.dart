int workloadWithPositionalArguments(int x, int y) {
  return x | y;
}

int workloadWithNamedArguments({int x, int y}) {
  return x | y;
}

int workloadWithPositionalAndNamedArguments(int x, int y, {int z, int w}) {
  return x | y | z | w;
}