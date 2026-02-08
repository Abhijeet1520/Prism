import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

import 'feature_registry.dart';

/// A widget that shows a feature availability message.
/// Use this in screens where a feature is not yet available.
class FeatureGate extends StatelessWidget {
  final String featureId;
  final Widget child;
  final bool showBannerOnly; // If true, shows banner above child instead of replacing

  const FeatureGate({
    super.key,
    required this.featureId,
    required this.child,
    this.showBannerOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final registry = FeatureRegistry();
    final feature = registry.getFeature(featureId);

    if (feature == null || feature.status == FeatureStatus.available) {
      return child;
    }

    final colors = context.moonColors!;

    if (showBannerOnly || feature.status == FeatureStatus.preview || feature.status == FeatureStatus.partial) {
      return Column(
        children: [
          _banner(colors, feature),
          Expanded(child: child),
        ],
      );
    }

    // Fully unavailable — show placeholder
    return _placeholder(colors, feature);
  }

  Widget _banner(MoonColors colors, Feature feature) {
    final (icon, color) = switch (feature.status) {
      FeatureStatus.preview => (Icons.science_outlined, colors.krillin),
      FeatureStatus.partial => (Icons.construction_outlined, colors.krillin),
      FeatureStatus.planned => (Icons.schedule_outlined, colors.trunks),
      _ => (Icons.info_outline, colors.trunks),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.2))),
      ),
      child: Row(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            feature.userMessage,
            style: TextStyle(color: color, fontSize: 12, height: 1.3),
          ),
        ),
        if (feature.version != null)
          MoonTag(
            tagSize: MoonTagSize.x2s,
            backgroundColor: color.withValues(alpha: 0.15),
            label: Text(feature.version!, style: TextStyle(fontSize: 9, color: color)),
          ),
      ]),
    );
  }

  Widget _placeholder(MoonColors colors, Feature feature) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: colors.piccolo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.rocket_launch_outlined, size: 32, color: colors.piccolo),
            ),
            const SizedBox(height: 20),
            Text(
              feature.name,
              style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              feature.userMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.trunks, fontSize: 14, height: 1.5),
            ),
            if (feature.version != null) ...[
              const SizedBox(height: 16),
              MoonTag(
                tagSize: MoonTagSize.sm,
                backgroundColor: colors.piccolo.withValues(alpha: 0.15),
                label: Text('Expected: ${feature.version}', style: TextStyle(fontSize: 12, color: colors.piccolo)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
