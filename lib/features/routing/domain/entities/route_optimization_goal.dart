import '../../../../core/localization/app_localizations.dart';

/// The three "Optimize For" pills on Select Route.
enum RouteOptimizationGoal { comfort, shortest, balanced }

extension RouteOptimizationGoalX on RouteOptimizationGoal {
  // Only one call site (optimization_goal_pill.dart) — same reasoning as
  // PasswordStrength.label for taking l10n directly.
  String label(AppLocalizations l10n) {
    switch (this) {
      case RouteOptimizationGoal.comfort:
        return l10n.goalComfort;
      case RouteOptimizationGoal.shortest:
        return l10n.goalShortest;
      case RouteOptimizationGoal.balanced:
        return l10n.goalBalanced;
    }
  }
}
