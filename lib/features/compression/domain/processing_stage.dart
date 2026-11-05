import 'package:compressor/l10n/app_localizations.dart';

/// The 5 processing stages matching Screen 4 of the reference design.
enum ProcessingStage {
  preparing(0.15),
  analyzing(0.35),
  compressing(0.65),
  optimizing(0.85),
  finalizing(1.0);

  final double targetProgress;

  const ProcessingStage(this.targetProgress);

  String getLocalizedLabel(AppLocalizations l10n) {
    switch (this) {
      case ProcessingStage.preparing:
        return l10n.stagePreparing;
      case ProcessingStage.analyzing:
        return l10n.stageAnalyzing;
      case ProcessingStage.compressing:
        return l10n.stageCompressing;
      case ProcessingStage.optimizing:
        return l10n.stageOptimizing;
      case ProcessingStage.finalizing:
        return l10n.stageFinalizing;
    }
  }
}
