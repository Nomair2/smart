import '../../domain/entities/campus_node.dart';
import '../../domain/entities/path_segment.dart';
import '../../domain/repositories/campus_repository.dart';
import '../campus_map_data.dart';

/// Serves the campus graph that is hand-entered in [CampusMapData].
///
/// The class keeps its old name so `main.dart` needs no change; the data
/// itself now lives in `campus_map_data.dart`, which is the only file you
/// edit while surveying. When admin tools (B3/B4) exist, a
/// `FirestoreCampusRepository` replaces this in `main.dart` — the seed
/// numbers in [CampusMapData] are what you'd upload.
class FakeCampusRepository implements CampusRepository {
  @override
  Future<List<CampusNode>> fetchNodes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return CampusMapData.nodes;
  }

  @override
  Future<List<PathSegment>> fetchSegments() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return CampusMapData.segments;
  }
}
