/// Shared across every feature that needs the summer/winter comfort split
/// (home's toggle card, route selection, a user's saved preference) so they
/// all agree on the same three states instead of each feature inventing
/// its own.
enum SeasonMode { summer, winter, auto }

extension SeasonModeX on SeasonMode {
  String get label {
    switch (this) {
      case SeasonMode.summer:
        return 'Summer';
      case SeasonMode.winter:
        return 'Winter';
      case SeasonMode.auto:
        return 'Auto';
    }
  }

  /// Firestore stores this as a plain string (`default_season_mode` in the
  /// report's Table 5); keep the two in sync through these instead of
  /// scattering `.name`/`toString()` calls around the codebase.
  String get storageValue => name;

  static SeasonMode fromStorage(String? value) {
    return SeasonMode.values.firstWhere(
      (mode) => mode.storageValue == value,
      orElse: () => SeasonMode.auto,
    );
  }
}
