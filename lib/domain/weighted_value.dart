import 'dart:math';

class WeightedValue<T> {
  const WeightedValue(this.value, this.weight) : assert(weight > 0);

  final T value;
  final int weight;
}

extension WeightedRandom<T> on List<WeightedValue<T>> {
  T pick(Random random) {
    if (isEmpty) {
      throw StateError('Cannot pick from an empty weighted list.');
    }

    final totalWeight = fold<int>(0, (sum, item) => sum + item.weight);
    var cursor = random.nextInt(totalWeight);
    for (final item in this) {
      if (cursor < item.weight) {
        return item.value;
      }
      cursor -= item.weight;
    }

    return last.value;
  }
}
