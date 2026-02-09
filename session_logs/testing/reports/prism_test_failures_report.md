# Prism Test Failures Report

Run summary:
- Passed: 21
- Failed: 17

## Failures by category

### Pending timers / timeouts
- Brain screen test: pending timers and test timeout.
  - [Gemmie/prism/test/widget/brain_screen_test.dart](Gemmie/prism/test/widget/brain_screen_test.dart)
- Finance sub-screen test: pending timers from Drift stream cleanup and test timeout.
  - [Gemmie/prism/test/widget/finance_sub_screen_test.dart](Gemmie/prism/test/widget/finance_sub_screen_test.dart)

### Missing Material ancestor
- Tools sub-screen: InkWell without Material ancestor.
  - [Gemmie/prism/test/widget/tools_sub_screen_test.dart](Gemmie/prism/test/widget/tools_sub_screen_test.dart)
- Tasks sub-screen: TextField without Material ancestor.
  - [Gemmie/prism/test/widget/tasks_sub_screen_test.dart](Gemmie/prism/test/widget/tasks_sub_screen_test.dart)
- Gateway sub-screen: Switch without Material ancestor.
  - [Gemmie/prism/test/widget/gateway_sub_screen_test.dart](Gemmie/prism/test/widget/gateway_sub_screen_test.dart)
- Appearance section: Switch without Material ancestor.
  - [Gemmie/prism/test/widget/appearance_section_test.dart](Gemmie/prism/test/widget/appearance_section_test.dart)
- Providers section: TextField/Switch without Material ancestor.
  - [Gemmie/prism/test/widget/providers_section_test.dart](Gemmie/prism/test/widget/providers_section_test.dart)
- Cloud provider tile: TextField without Material ancestor.
  - [Gemmie/prism/test/widget/cloud_provider_tile_test.dart](Gemmie/prism/test/widget/cloud_provider_tile_test.dart)
- Soul document section: Switch without Material ancestor.
  - [Gemmie/prism/test/widget/soul_section_test.dart](Gemmie/prism/test/widget/soul_section_test.dart)
- Voice section: Switch without Material ancestor.
  - [Gemmie/prism/test/widget/voice_section_test.dart](Gemmie/prism/test/widget/voice_section_test.dart)

### Layout overflow in constrained test surface
- Appearance section: Row/Column overflow.
  - [Gemmie/prism/test/widget/appearance_section_test.dart](Gemmie/prism/test/widget/appearance_section_test.dart)
- Providers section: Row/Column overflow.
  - [Gemmie/prism/test/widget/providers_section_test.dart](Gemmie/prism/test/widget/providers_section_test.dart)
- Personas section: Column overflow.
  - [Gemmie/prism/test/widget/personas_section_test.dart](Gemmie/prism/test/widget/personas_section_test.dart)
- Soul document section: Row/Column overflow.
  - [Gemmie/prism/test/widget/soul_section_test.dart](Gemmie/prism/test/widget/soul_section_test.dart)
- Data section: Column overflow.
  - [Gemmie/prism/test/widget/data_section_test.dart](Gemmie/prism/test/widget/data_section_test.dart)
- Gateway sub-screen: Row overflow.
  - [Gemmie/prism/test/widget/gateway_sub_screen_test.dart](Gemmie/prism/test/widget/gateway_sub_screen_test.dart)

### Expectation mismatch
- Settings screen: duplicate "AI Providers" text causes `findsOneWidget` to fail.
  - [Gemmie/prism/test/widget/settings_screen_test.dart](Gemmie/prism/test/widget/settings_screen_test.dart)
