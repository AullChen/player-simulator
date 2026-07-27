import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:player_simulator/data/football_catalog.dart';
import 'package:player_simulator/domain/random_draw_step.dart';
import 'package:player_simulator/services/random_career_generator.dart';
import 'package:player_simulator/services/random_draw_plan.dart';

void main() {
  test('association wheel uses the exact FIFA global total', () {
    final total = FootballCatalog.professionalAssociationPopulations.fold<int>(
      0,
      (sum, item) => sum + item.weight,
    );
    final england = FootballCatalog.professionalAssociationPopulations
        .singleWhere((item) => item.value == '英格兰');

    expect(total, 128694);
    expect(england.weight, 5582);
    expect(england.weight / total * 100, closeTo(4.34, 0.01));
  });

  test('draw plan covers all three tracks with proportionate selections', () {
    for (var seed = 0; seed < 30; seed++) {
      final profile = RandomCareerGenerator(random: Random(seed)).generate();
      final plan = RandomDrawPlan.build(profile);

      expect(plan.length, greaterThanOrEqualTo(40));
      expect(
        plan.map((step) => step.track).toSet(),
        RandomDrawTrack.values.toSet(),
      );
      expect(
        plan.every(
          (step) =>
              step.segments.any(
                (segment) => segment.value == step.selectedSegment,
              ) &&
              step.selectedWeight > 0 &&
              step.totalWeight > 0,
        ),
        isTrue,
      );
      expect(plan.map((step) => step.id).toSet(), hasLength(plan.length));
    }
  });

  test('generated careers only use real catalogued clubs', () {
    final clubNames = FootballCatalog.clubs.map((club) => club.name).toSet();

    expect(clubNames, hasLength(32));
    for (var seed = 0; seed < 50; seed++) {
      final profile = RandomCareerGenerator(random: Random(seed)).generate();
      expect(profile.developmentAssociation, isNot('未记录'));
      expect(
        profile.career.every((chapter) => clubNames.contains(chapter.club)),
        isTrue,
      );
    }
  });
}
