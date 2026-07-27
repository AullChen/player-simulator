import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_simulator/app.dart';
import 'package:player_simulator/domain/app_settings.dart';
import 'package:player_simulator/screens/dream_mode_screen.dart';
import 'package:player_simulator/screens/life_mode_screen.dart';
import 'package:player_simulator/screens/life_setup_screen.dart';
import 'package:player_simulator/screens/random_mode_screen.dart';
import 'package:player_simulator/services/app_storage.dart';

void main() {
  testWidgets('home screen exposes all three simulation modes', (tester) async {
    await tester.pumpWidget(PlayerSimulatorApp(storage: MemoryAppStorage()));
    await tester.pumpAndSettle();

    expect(find.text('全随机'), findsOneWidget);
    expect(find.text('模拟球员'), findsOneWidget);
    expect(find.text('梦想球员'), findsOneWidget);
  });

  testWidgets('settings page changes the interface language', (tester) async {
    await tester.pumpWidget(PlayerSimulatorApp(storage: MemoryAppStorage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<AppLanguage>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('保存设置'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('保存设置'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Settings saved'), findsOneWidget);
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

  testWidgets('wheel holds the selected result for about two seconds', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RandomModeScreen()));

    await tester.scrollUntilVisible(
      find.text('转动当前轮盘'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('转动当前轮盘'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pump();

    expect(find.text('结果锁定中…'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1900));
    expect(find.text('结果锁定中…'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump();
    expect(find.text('结果锁定中…'), findsNothing);
    expect(find.text('最近抽取'), findsOneWidget);
  });

  testWidgets('revealed wheel rows open a prefilled correction editor', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RandomModeScreen()));

    await tester.scrollUntilVisible(
      find.text('转动当前轮盘'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('转动当前轮盘'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 3700));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byIcon(Icons.edit_outlined),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('校正抽取档案'), findsOneWidget);
    expect(find.text('保存并返回抽取结果'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('保存并返回抽取结果'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('保存并返回抽取结果'));
    await tester.pumpAndSettle();

    expect(find.text('修改已保存，依赖字段和时间线已重新校验。'), findsOneWidget);
  });

  testWidgets('life mode explains context without exposing hidden scores', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LifeModeScreen(nationality: '中国', position: '中前卫'),
      ),
    );

    expect(find.text('人物模型'), findsNothing);
    expect(find.textContaining('训练负荷'), findsNothing);
    expect(find.textContaining('伤病风险'), findsNothing);
    expect(find.textContaining('青训体系里度过了数年'), findsOneWidget);
    expect(find.textContaining('你的选择：'), findsWidgets);
  });
}
