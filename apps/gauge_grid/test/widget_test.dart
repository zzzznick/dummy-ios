import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gauge_grid/app/gauge_scope.dart';
import 'package:gauge_grid/data/gauge_store.dart';
import 'package:gauge_grid/shell/main_shell.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('bottom bar exposes Grid, Boards, Convert', (WidgetTester tester) async {
    // Avoid awaiting `store.ready` here: on some test hosts `path_provider` can
    // stall; the shell only needs a store instance and a couple of frames.
    final store = GaugeStore();
    await tester.pumpWidget(
      MaterialApp(
        home: GaugeScope(
          store: store,
          child: const MainShell(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Grid'), findsOneWidget);
    expect(find.text('Boards'), findsOneWidget);
    expect(find.text('Convert'), findsOneWidget);
  });
}
