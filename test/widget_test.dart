import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shiftgrid/main.dart';

void main() {
  testWidgets('App renders the landing screen title', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ShiftGridApp()));
    await tester.pumpAndSettle();

    expect(find.text('ShiftGrid'), findsOneWidget);
  });
}
