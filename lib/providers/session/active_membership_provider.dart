import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/models/Offer/user_membership.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';

/// Current user's active (or frozen) membership, if any.
/// Used to show "Member: [Plan Name]" or "Not a member" on profile, home, etc.
final activeMembershipProvider = FutureProvider<UserMembership?>((ref) async {
  final user = ref.watch(userSessionProvider).user;
  if (user == null) return null;

  final list = await ref.read(apiProvider).getMyMemberships();
  for (final m in list) {
    if (m.isActive || m.isFrozen) return m;
  }
  return null;
});

/// Helper: plan name from active membership, or null if no membership.
final activeMembershipPlanNameProvider = Provider<String?>((ref) {
  final async = ref.watch(activeMembershipProvider);
  return async.value?.plan?.name;
});
