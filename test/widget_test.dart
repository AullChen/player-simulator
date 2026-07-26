import 'package:flutter_test/flutter_test.dart';
import 'package:player_simulator/app.dart';

void main() {
  testWidgets('home screen exposes all three simulation modes', (tester) async {
    await tester.pumpWidget(const PlayerSimulatorApp());

    expect(find.text('全随机'), findsOneWidget);
    expect(find.text('模拟球员'), findsOneWidget);
    expect(find.text('梦想球员'), findsOneWidget);
  });
}
