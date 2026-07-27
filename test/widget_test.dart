import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_simulator/app.dart';
import 'package:player_simulator/screens/dream_mode_screen.dart';
import 'package:player_simulator/screens/life_setup_screen.dart';

void main() {
  testWidgets('home screen exposes all three simulation modes', (tester) async {
    await tester.pumpWidget(const PlayerSimulatorApp());

    expect(find.text('全随机'), findsOneWidget);
    expect(find.text('模拟球员'), findsOneWidget);
    expect(find.text('梦想球员'), findsOneWidget);
  });

  testWidgets('life setup lets the user select yearly decisions', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LifeSetupScreen()));

    expect(find.text('关键节点'), findsOneWidget);
    expect(find.text('逐年选择'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('逐年选择'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('逐年选择'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('开始 22 个生涯选择'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('开始 22 个生涯选择'), findsOneWidget);
  });

  testWidgets('dream mode builds a dossier from structured defaults', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DreamModeScreen()));

    await tester.scrollUntilVisible(
      find.text('生成梦想球员档案'),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('生成梦想球员档案'));
    await tester.pumpAndSettle();

    expect(find.text('球员生涯档案'), findsOneWidget);
    expect(find.text('转会记录'), findsOneWidget);
    expect(find.text('职业比赛数据'), findsOneWidget);
  });
}
