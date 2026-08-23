import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimate/state/app_state.dart';

void main() {
  test('initial academic data is available', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final data = container.read(dataProvider);
    expect(data.subjects, isNotEmpty);
    expect(data.events, isNotEmpty);
    expect(data.tasks, isNotEmpty);
  });
}
