import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_social_chat/data/repository/auth/auth_repository.dart';
import 'package:flutter_social_chat/data/repository/chat/chat_repository.dart';
import 'package:flutter_social_chat/data/repository/connectivity/connectivity_repository.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_session/chat_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/connectivity/connectivity_cubit.dart';
import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:flutter_social_chat/core/interfaces/i_chat_repository.dart';
import 'package:flutter_social_chat/core/interfaces/i_connectivity_repository.dart';
import 'package:flutter_social_chat/core/init/router/app_router.dart';
import 'package:flutter_social_chat/core/config/env_config.dart';
import 'package:get_it/get_it.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

final getIt = GetIt.instance;

void injectionSetup() {
  // Core utilities
  getIt.registerSingleton<AppRouter>(AppRouter());

  // External services
  getIt.registerSingleton<Connectivity>(Connectivity());
  getIt.registerSingleton<StreamChatClient>(
    StreamChatClient(
      EnvConfig.instance.streamChatApiKey,
      logLevel: Level.INFO,
    ),
  );

  // Firebase services
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Domain repositories
  getIt.registerLazySingleton<IConnectivityRepository>(() => ConnectivityRepository(getIt<Connectivity>()));
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(getIt<FirebaseAuth>(), getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<IChatRepository>(
    () => ChatRepository(getIt<IAuthRepository>(), getIt<StreamChatClient>()),
  );

  // Blocs and Cubits
  getIt.registerLazySingleton<ConnectivityCubit>(() => ConnectivityCubit());

  // Auth Cubits
  getIt.registerLazySingleton<AuthSessionCubit>(
    () => AuthSessionCubit(
      authRepository: getIt<IAuthRepository>(),
      chatRepository: getIt<IChatRepository>(),
    ),
  );
  getIt.registerLazySingleton<ProfileManagerCubit>(
    () => ProfileManagerCubit(
      authRepository: getIt<IAuthRepository>(),
      firebaseFirestore: getIt<FirebaseFirestore>(),
      authSessionCubit: getIt<AuthSessionCubit>(),
      chatRepository: getIt<IChatRepository>(),
    ),
  );
  getIt.registerFactory<PhoneNumberSignInCubit>(() => PhoneNumberSignInCubit(getIt<IAuthRepository>()));

  // Chat Cubits
  getIt.registerFactory<ChatManagementCubit>(
    () => ChatManagementCubit(
      getIt<IChatRepository>(),
      getIt<FirebaseFirestore>(),
      getIt<AuthSessionCubit>(),
    ),
  );
  getIt.registerLazySingleton<ChatSessionCubit>(() => ChatSessionCubit(getIt<IChatRepository>()));
}
