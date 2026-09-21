import '../entities/campus_node.dart';
import '../entities/path_segment.dart';

/// The campus graph's data source. Backed by [FakeCampusRepository] for
/// now (no admin CRUD to populate `campus_nodes`/`path_segments` through
/// yet — that's B3/B4, still ahead of us); swapping in a
/// `FirestoreCampusRepository` later is a one-line change in main.dart,
/// same as every other repository so far.
abstract class CampusRepository {
  Future<List<CampusNode>> fetchNodes();

  Future<List<PathSegment>> fetchSegments();
}
