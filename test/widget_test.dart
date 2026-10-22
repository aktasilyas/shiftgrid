import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiftgrid/core/di/providers.dart';
import 'package:shiftgrid/features/game/data/datasources/progress_store.dart';
import 'package:shiftgrid/main.dart';

void main() {
  testWidgets('Menu renders the app title', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          progressStoreProvider.overrideWithValue(InMemoryProgressStore()),
        ],
        child: const ShiftGridApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Snake Shift'), findsOneWidget);
  });
}
