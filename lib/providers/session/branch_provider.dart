import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:recoverylab_front/models/Branch/branch/branch.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';

class BranchesNotifier extends StateNotifier<List<Branch>> {
  final Ref ref;
  BranchesNotifier(this.ref) : super([]);

  bool _isFetching = false;

  /// Fetch branches from API and store them in state
  Future<void> fetchBranches() async {
    try {
      final api = ref.read(apiProvider);
      final branches = await api.getBranches();
      state = branches;
    } catch (e) {
      rethrow;
    }
  }

  /// If branches were not loaded yet (e.g. splash skipped), fetch them when a screen needs them.
  Future<void> ensureBranchesFetched() async {
    if (state.isNotEmpty || _isFetching) return;
    _isFetching = true;
    try {
      await fetchBranches();
    } finally {
      _isFetching = false;
    }
  }

  void addBranch(Branch branch) {
    state = [...state, branch];
  }

  void removeBranch(Branch branch) {
    state = state.where((b) => b.id != branch.id).toList();
  }
}

// Provider
final branchesProvider = StateNotifierProvider<BranchesNotifier, List<Branch>>((
  ref,
) {
  return BranchesNotifier(ref);
});
