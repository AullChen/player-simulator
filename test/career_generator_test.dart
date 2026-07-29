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

    test('uses the game-balanced peak-rating bands', () {
      const sampleSize = 4000;
      var atLeast70 = 0;
      var atLeast80 = 0;
      final generator = RandomCareerGenerator(random: Random(8128));

      for (var index = 0; index < sampleSize; index++) {
        final academyTier = 1 + index % 4;
        final rating = generator.sampleRatings(academyTier).peak;
        if (rating >= 70) atLeast70 += 1;
        if (rating >= 80) atLeast80 += 1;
      }

      expect(atLeast70 / sampleSize, closeTo(0.90, 0.025));
      expect(atLeast80 / sampleSize, closeTo(0.50, 0.025));
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
      expect(
        player.careerYearSnapshots,
        hasLength(player.retirementAge - player.debutAge + 1),
      );
      final restored = PlayerProfile.fromJson(player.toJson());
      expect(
        restored.characterAttributes![PlayerAttribute.stamina],
        player.characterAttributes![PlayerAttribute.stamina],
      );
      expect(
        restored.careerYearSnapshots.length,
        player.careerYearSnapshots.length,
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

    test('open-ended careers grow one decision at a time up to age 60', () {
      for (var seed = 0; seed < 80; seed++) {
        final simulator = LifeSimulator(
          nationality: '中国',
          position: '中前卫',
          density: CareerDecisionDensity.random,
          random: Random(seed),
        );
        expect(simulator.totalStages, 1);
        var safetyCounter = 0;
        while (!simulator.isComplete) {
          safetyCounter += 1;
          expect(safetyCounter, lessThan(60));
          final stage = simulator.currentStage;
          for (final choice in stage.choices) {
            expect(choice.retirementProbability, inExclusiveRange(0, 1));
            expect(choice.accidentProbability, inExclusiveRange(0, 1));
          }
          final stagesBefore = simulator.totalStages;
          simulator.choose(
            simulator.decisions.length,
            simulator.currentStage.choices.length - 1,
          );
          if (!simulator.isComplete) {
            expect(simulator.totalStages, stagesBefore + 1);
            expect(simulator.currentStage.age, greaterThan(stage.age));
          }
        }
        expect(simulator.retirementOutcome, isNotNull);
        expect(simulator.retirementOutcome!.age, inInclusiveRange(17, 60));
        final player = simulator.finish(name: '开放生涯测试');
        expect(player.retirementAge, inInclusiveRange(17, 60));
        expect(player.retirementReason, isNot('未记录'));
      }
    });

    test('the first open-ended choice can trigger an off-pitch accident', () {
      final simulator = LifeSimulator(
        nationality: '中国',
        position: '中前卫',
        density: CareerDecisionDensity.random,
        random: _AlwaysZeroRandom(),
      );

      simulator.choose(0, 0);

      expect(simulator.isComplete, isTrue);
      expect(simulator.retirementOutcome!.cause, LifeRetirementCause.accident);
      expect(simulator.retirementOutcome!.age, 17);
      final player = simulator.finish(name: '首轮意外测试');
      expect(player.stats.appearances, inInclusiveRange(5, 50));
      expect(player.stats.nationalCaps, lessThanOrEqualTo(12));
    });

    test('an exceptionally lucky open-ended career can reach age 60', () {
      final simulator = LifeSimulator(
        nationality: '日本',
        position: '中锋',
        density: CareerDecisionDensity.random,
        random: _AlwaysHighRandom(),
      );

      while (!simulator.isComplete) {
        simulator.choose(simulator.decisions.length, 0);
      }

      expect(simulator.retirementOutcome!.age, 60);
      expect(simulator.retirementOutcome!.cause, LifeRetirementCause.age);
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
        for (final choice in simulator.currentStage.choices) {
          expect(choice.titleZh, contains('：'));
          expect(choice.backgroundZh, contains('你当时效力于'));
          expect(choice.decisionZh, startsWith('你'));
          expect(choice.decisionZh, isNot(contains('确认后')));
          if (choice.causesTransfer) {
            expect(choice.decisionZh, anyOf(contains('转会'), contains('租借')));
          }
        }
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

class _AlwaysZeroRandom implements Random {
  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => 0;
}

class _AlwaysHighRandom implements Random {
  @override
  bool nextBool() => true;

  @override
  double nextDouble() => 0.999999;

  @override
  int nextInt(int max) => max - 1;
}
