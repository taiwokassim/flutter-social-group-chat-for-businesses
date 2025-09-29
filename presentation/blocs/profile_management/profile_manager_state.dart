import 'package:equatable/equatable.dart';

class ProfileManagerState extends Equatable {
  const ProfileManagerState({
    this.isUserNameValid = false,
    this.isInProgress = false,
    this.userProfilePhotoUrl = '',
  });

  final bool isUserNameValid;
  final bool isInProgress;
  final String userProfilePhotoUrl;

  @override
  List<Object?> get props => [
        isUserNameValid,
        isInProgress,
        userProfilePhotoUrl,
      ];

  ProfileManagerState copyWith({
    bool? isUserNameValid,
    bool? isInProgress,
    String? userProfilePhotoUrl,
  }) {
    return ProfileManagerState(
      isUserNameValid: isUserNameValid ?? this.isUserNameValid,
      isInProgress: isInProgress ?? this.isInProgress,
      userProfilePhotoUrl: userProfilePhotoUrl ?? this.userProfilePhotoUrl,
    );
  }

  factory ProfileManagerState.empty() => const ProfileManagerState();
}
