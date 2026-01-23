import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:recoverylab_front/models/Branch/branch/branch.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';

class BranchesNotifier extends StateNotifier<List<Branch>> {
  final Ref ref;
  BranchesNotifier(this.ref) : super([]);

  // Fetch branches from API and store them in state
  Future<void> fetchBranches() async {
    try {
      final api = ref.read(apiProvider);
      final branches = await api.getBranches();
      state = branches; // store in-memory
    } catch (e) {
      // Handle errors here if you want, or rethrow
      rethrow;
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
