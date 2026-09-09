/// Thrown by [AuthRepository] implementations with a message that's already
/// safe to show the user. Cubits check for this type specifically so a real,
/// specific error (e.g. "that email is already registered") reaches the UI
/// instead of being flattened into a generic fallback message.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
