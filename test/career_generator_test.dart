import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:player_simulator/services/life_simulator.dart';
import 'package:player_simulator/services/random_career_generator.dart';

void main() {
  group('RandomCareerGenerator', () {
    test('is reproducible with a fixed seed', () {
      final first = RandomCareerGenerator(random: Random(2026)).generate();
      final second = RandomCareerGenerator(random: Random(2026)).generate();

      expect(first.toJson(), second.toJson());
    });

    test('generates plausible career boundaries', () {
      for (var seed = 0; seed < 100; seed++) {
        final player = RandomCareerGenerator(random: Random(seed)).generate();

        expect(player.heightCm, inInclusiveRange(165, 200));
        expect(player.debutAge, inInclusiveRange(16, 21));
        expect(player.retirementAge, inInclusiveRange(33, 40));
        expect(player.initialRating, inInclusiveRange(51, 70));
        expect(player.peakRating, inInclusiveRange(player.initialRating, 96));
        expect(player.stats.appearances, greaterThan(0));
        expect(player.career.length, player.stats.transferCount + 1);
        expect(player.weightKg, inInclusiveRange(55, 110));
        expect(player.shirtNumber, greaterThan(0));
        expect(player.birthDate, isNot('未记录'));
        expect(player.currentClub, player.career.last.club);
        expect(player.transferHistory, hasLength(player.stats.transferCount));
        expect(player.marketValueHistory, isNotEmpty);
        expect(
          player.competitionStats.fold<int>(
            0,
            (sum, competition) => sum + competition.appearances,
          ),
          player.stats.appearances,
        );
        expect(
          player.competitionStats.fold<int>(
            0,
            (sum, competition) => sum + competition.goals,
          ),
          player.stats.goals,
        );
        expect(
          player.competitionStats.fold<int>(
            0,
            (sum, competition) => sum + competition.assists,
          ),
          player.stats.assists,
        );
        expect(
          player.transferHistory.fold<double>(
            0,
            (sum, transfer) => sum + transfer.feeMillions,
          ),
          closeTo(player.stats.totalTransferFeeMillions, 0.01),
        );
        expect(
          player.toJson(),
          containsPair('registration_and_contract', isA<Map<String, Object>>()),
        );
        expect(
          player.toJson(),
          containsPair('national_team', isA<Map<String, Object>>()),
        );
      }
    });
  });

  group('LifeSimulator', () {
    test('requires choices in chronological order', () {
      final simulator = LifeSimulator(nationality: '中国', position: '中前卫');

      expect(() => simulator.choose(1, 0), throwsStateError);
      expect(() => simulator.finish(), throwsStateError);
    });

    test('turns all choices into a complete player profile', () {
      final simulator = LifeSimulator(
        nationality: '中国',
        position: '中锋',
        random: Random(7),
      );
      for (var index = 0; index < LifeSimulator.stages.length; index++) {
        simulator.choose(index, 0);
      }

      final player = simulator.finish(name: '测试前锋');

      expect(player.name, '测试前锋');
      expect(player.career, hasLength(LifeSimulator.stages.length));
      expect(player.peakRating, greaterThan(player.initialRating));
      expect(player.stats.goals, greaterThan(0));
    });
  });
}
