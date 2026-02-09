import 'package:flutter_test/flutter_test.dart';

import 'package:prism/core/data/demo_data_service.dart';
import 'package:prism/core/database/database.dart';
import '../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('load and remove demo data', () async {
    final db = createTestDatabase();
    addTearDown(db.close);

    final counts = await DemoDataService.loadDemoData(db);
    expect(counts['tasks'], greaterThan(0));
    expect(counts['notes'], greaterThan(0));

    final hasDemo = await DemoDataService.hasDemoData(db);
    expect(hasDemo, isTrue);

    final removed = await DemoDataService.removeDemoData(db);
    expect(removed['tasks'], greaterThanOrEqualTo(0));
  });
}
