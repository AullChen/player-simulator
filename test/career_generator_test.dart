import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:player_simulator/data/football_catalog.dart';
import 'package:player_simulator/data/life_event_pool.dart';
import 'package:player_simulator/domain/player_attributes.dart';
import 'package:player_simulator/domain/player_profile.dart';
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
      for (var index = 0; index < simulator.totalStages; index++) {
        simulator.choose(index, 0);
      }

      final player = simulator.finish(name: '测试前锋');

      expect(player.name, '测试前锋');
      expect(player.career, hasLength(simulator.totalStages));
      expect(player.peakRating, greaterThan(player.initialRating));
      expect(player.stats.goals, greaterThan(0));
      expect(player.characterAttributes, isNotNull);
      expect(player.toJson(), contains('character_model'));
      final restored = PlayerProfile.fromJson(player.toJson());
      expect(
        restored.characterAttributes![PlayerAttribute.stamina],
        player.characterAttributes![PlayerAttribute.stamina],
      );
    });

    test('offers 5, 8, 11 and 22-node career densities', () {
      final expectedCounts = {
        CareerDecisionDensity.milestones: 5,
        CareerDecisionDensity.everyThreeYears: 8,
        CareerDecisionDensity.everyTwoYears: 11,
        CareerDecisionDensity.everyYear: 22,
      };

      for (final entry in expectedCounts.entries) {
        final simulator = LifeSimulator(
          nationality: '中国',
          position: '中前卫',
          density: entry.key,
        );

        expect(simulator.totalStages, entry.value);
        expect(simulator.currentStage.age, 15);
        for (var index = 0; index < simulator.totalStages; index++) {
          simulator.choose(index, 0);
        }
        expect(simulator.decisions.last.stage.age, lessThanOrEqualTo(36));
      }
    });

    test('provides at least 100 raw candidates in every career phase', () {
      for (final phase in CareerPhase.values) {
        final options = LifeEventPool.rawOptionsFor(phase);
        expect(options.length, greaterThanOrEqualTo(100));
        expect(
          options.map((item) => item.id).toSet(),
          hasLength(options.length),
        );
      }
    });

    test('turns detailed choices into structured career records', () {
      final simulator = LifeSimulator(
        nationality: '中国',
        position: '中锋',
        density: CareerDecisionDensity.everyYear,
        random: Random(9),
      );
      for (var index = 0; index < simulator.totalStages; index++) {
        expect(
          simulator.currentStage.candidatePoolSize,
          greaterThanOrEqualTo(100),
        );
        expect(simulator.currentStage.choices.length, inInclusiveRange(3, 5));
        simulator.choose(index, index % simulator.currentStage.choices.length);
      }

      final player = simulator.finish();

      expect(player.career, hasLength(22));
      expect(player.marketValueHistory, isNotEmpty);
      expect(player.stats.transferCount, player.transferHistory.length);
      expect(
        player.competitionStats.fold<int>(
          0,
          (sum, competition) => sum + competition.appearances,
        ),
        player.stats.appearances,
      );
      final realClubs = FootballCatalog.clubs.map((club) => club.name).toSet();
      expect(
        player.career.every((chapter) => realClubs.contains(chapter.club)),
        isTrue,
      );
    });

    test('character values change eligible options', () {
      final lowModel = PlayerAttributes({
        for (final attribute in PlayerAttribute.values) attribute: 30,
      });
      final highModel = PlayerAttributes({
        for (final attribute in PlayerAttribute.values) attribute: 80,
      });
      final low = LifeSimulator(
        nationality: '中国',
        position: '中前卫',
        random: Random(11),
        initialAttributes: lowModel,
      );
      final high = LifeSimulator(
        nationality: '中国',
        position: '中前卫',
        random: Random(11),
        initialAttributes: highModel,
      );

      expect(
        low.currentStage.eligiblePoolSize,
        isNot(high.currentStage.eligiblePoolSize),
      );
    });

    test('intensive training raises later health-event weight', () {
      LifeSimulator? simulator;
      var choiceIndex = -1;
      for (var seed = 0; seed < 500 && choiceIndex < 0; seed++) {
        final candidate = LifeSimulator(
          nationality: '中国',
          position: '中锋',
          random: Random(seed),
        );
        choiceIndex = candidate.currentStage.choices.indexWhere(
          (choice) => choice.actionId == 'intensive',
        );
        if (choiceIndex >= 0) simulator = candidate;
      }

      expect(simulator, isNotNull);
      final before = simulator!.themeWeight(LifeEventTheme.health);
      final previousLoad = simulator.trainingLoad;
      simulator.choose(0, choiceIndex);

      expect(simulator.trainingLoad, greaterThan(previousLoad));
      expect(simulator.themeWeight(LifeEventTheme.health), greaterThan(before));
    });
  });
}
