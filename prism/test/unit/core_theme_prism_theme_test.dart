import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prism/core/theme/prism_theme.dart';

void main() {
  test('accent preset updates accent color', () {
    const state = PrismThemeState(preset: AccentPreset.rose);
    expect(state.accent, AccentPreset.rose.color);
  });

  test('amoled toggles background', () {
    const state = PrismThemeState(amoled: true);
    expect(state.bgDeep, const Color(0xFF000000));
  });
}
