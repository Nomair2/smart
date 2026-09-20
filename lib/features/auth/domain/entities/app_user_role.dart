/// Which side of the app a signed-in account lands on. Backed by two
/// separate Firestore collections (`admins`, `users`) rather than a role
/// field on one collection — an admin flag a student could write to their
/// own profile document would be a privilege-escalation bug, not a feature.
enum AppUserRole { admin, student }
