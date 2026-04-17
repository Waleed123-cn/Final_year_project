// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_services_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseAuthServiceHash() =>
    r'00f3f9b8514de042aefcf6f6fca77f40e6fc206e';

/// See also [FirebaseAuthService].
@ProviderFor(FirebaseAuthService)
final firebaseAuthServiceProvider =
    AutoDisposeAsyncNotifierProvider<FirebaseAuthService, User?>.internal(
  FirebaseAuthService.new,
  name: r'firebaseAuthServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseAuthServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FirebaseAuthService = AutoDisposeAsyncNotifier<User?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
