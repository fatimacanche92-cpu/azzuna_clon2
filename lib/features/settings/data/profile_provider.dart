import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_repository.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

final profileFutureProvider = FutureProvider((ref) {
  return ref.watch(profileRepositoryProvider).getProfile();
});