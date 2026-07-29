import 'package:flutter_test/flutter_test.dart';
import 'package:player_simulator/data/football_catalog.dart';
import 'package:player_simulator/data/probability_sources.dart';

void main() {
  test('public probability sources are versioned and uniquely identified', () {
    expect(ProbabilitySources.dataVersion, isNotEmpty);
    expect(ProbabilitySources.professionalPlayers2023, greaterThan(100000));
    expect(ProbabilitySources.professionalClubs2023, greaterThan(3000));
    expect(ProbabilitySources.professionalCountries2023, 135);

    final ids = ProbabilitySources.sources.map((source) => source.id).toSet();
    final urls = ProbabilitySources.sources.map((source) => source.url).toSet();
    expect(ids, hasLength(ProbabilitySources.sources.length));
    expect(urls, hasLength(ProbabilitySources.sources.length));
    expect(
      ProbabilitySources.sources.every(
        (source) => Uri.parse(source.url).hasScheme,
      ),
      isTrue,
    );
    expect(
      ProbabilitySources.severeOffPitchAccidentProxyPerYear,
      closeTo(0.0001175, 0.0000001),
    );
  });

  test('FIFA-calibrated transfer weights preserve the published ordering', () {
    final weights = {
      for (final item in FootballCatalog.transferTypes) item.value: item.weight,
    };

    expect(weights['自由转会'], greaterThan(weights['租借']!));
    expect(weights['永久转会'], lessThan(20));
    expect(
      FootballCatalog.transferTypes.fold<int>(
        0,
        (sum, item) => sum + item.weight,
      ),
      100,
    );
    expect(ProbabilitySources.januaryInternationalTransfers2025, 5863);
    expect(ProbabilitySources.transfersWithFeePercent2025, 17.7);
    expect(ProbabilitySources.averageInternationalTransferAge2025, 24.9);
  });
}
