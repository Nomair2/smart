/// The three "Optimize For" pills on Select Route.
enum RouteOptimizationGoal { comfort, shortest, balanced }

extension RouteOptimizationGoalX on RouteOptimizationGoal {
  String get label {
    switch (this) {
      case RouteOptimizationGoal.comfort:
        return 'Comfort';
      case RouteOptimizationGoal.shortest:
        return 'Shortest';
      case RouteOptimizationGoal.balanced:
        return 'Balanced';
    }
  }
}
