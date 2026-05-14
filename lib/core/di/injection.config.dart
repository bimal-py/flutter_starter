// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:flutter_starter/core/di/service_module.dart' as _i592;
import 'package:flutter_starter/core/network/dio/config/dio_config.dart'
    as _i588;
import 'package:flutter_starter/core/network/dio/dio_client.dart' as _i438;
import 'package:flutter_starter/core/network/dio/interceptors/logout_interceptor.dart'
    as _i373;
import 'package:flutter_starter/core/network/service/remote_service.dart'
    as _i439;
import 'package:flutter_starter/core/network/service/remote_service_impl.dart'
    as _i29;
import 'package:flutter_starter/modules/auth/data/repository/local/hive_secure_session_store.dart'
    as _i347;
import 'package:flutter_starter/modules/auth/data/repository/remote/in_memory_auth_repository.dart'
    as _i824;
import 'package:flutter_starter/modules/auth/domain/repository/local/user_session_store.dart'
    as _i1046;
import 'package:flutter_starter/modules/auth/domain/repository/remote/auth_repository.dart'
    as _i446;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/forget_password_use_case.dart'
    as _i104;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/get_logged_in_user_use_case.dart'
    as _i613;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/login_with_apple_use_case.dart'
    as _i232;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/login_with_email_password_use_case.dart'
    as _i838;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/login_with_google_use_case.dart'
    as _i468;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/logout_use_case.dart'
    as _i962;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/register_email_use_case.dart'
    as _i830;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/register_user_use_case.dart'
    as _i799;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/reset_password_use_case.dart'
    as _i719;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/watch_auth_user_use_case.dart'
    as _i69;
import 'package:flutter_starter/modules/onboarding/features/splash/presentation/bloc/splash/splash_bloc.dart'
    as _i158;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final serviceModule = _$ServiceModule();
    gh.factory<_i588.DioConfig>(() => _i588.DioConfig());
    gh.factory<_i158.SplashBloc>(() => _i158.SplashBloc());
    gh.singleton<_i558.FlutterSecureStorage>(() => serviceModule.secureStorage);
    gh.singleton<_i895.Connectivity>(() => serviceModule.connectivity);
    await gh.singletonAsync<_i460.SharedPreferences>(
      () => serviceModule.sharedPreferences,
      preResolve: true,
    );
    gh.singleton<_i373.LogoutInterceptor>(() => _i373.LogoutInterceptor());
    gh.factory<_i438.DioClient>(() => _i438.DioClient(gh<_i588.DioConfig>()));
    gh.lazySingleton<_i1046.UserSessionStore>(
      () => _i347.HiveSecureSessionStore(),
    );
    gh.lazySingleton<_i446.AuthRepository>(
      () => _i824.InMemoryAuthRepository(gh<_i1046.UserSessionStore>()),
    );
    gh.factory<_i439.RemoteService>(
      () =>
          _i29.RemoteServiceImpl(gh<_i438.DioClient>(), gh<_i588.DioConfig>()),
    );
    gh.factory<_i104.ForgetPasswordUseCase>(
      () => _i104.ForgetPasswordUseCase(gh<_i446.AuthRepository>()),
    );
    gh.factory<_i613.GetLoggedInUserUseCase>(
      () => _i613.GetLoggedInUserUseCase(gh<_i446.AuthRepository>()),
    );
    gh.factory<_i232.LoginWithAppleUseCase>(
      () => _i232.LoginWithAppleUseCase(gh<_i446.AuthRepository>()),
    );
    gh.factory<_i838.LoginWithEmailPasswordUseCase>(
      () => _i838.LoginWithEmailPasswordUseCase(gh<_i446.AuthRepository>()),
    );
    gh.factory<_i468.LoginWithGoogleUseCase>(
      () => _i468.LoginWithGoogleUseCase(gh<_i446.AuthRepository>()),
    );
    gh.factory<_i962.LogoutUseCase>(
      () => _i962.LogoutUseCase(gh<_i446.AuthRepository>()),
    );
    gh.factory<_i830.RegisterEmailUseCase>(
      () => _i830.RegisterEmailUseCase(gh<_i446.AuthRepository>()),
    );
    gh.factory<_i799.RegisterUserUseCase>(
      () => _i799.RegisterUserUseCase(gh<_i446.AuthRepository>()),
    );
    gh.factory<_i719.ResetPasswordUseCase>(
      () => _i719.ResetPasswordUseCase(gh<_i446.AuthRepository>()),
    );
    gh.factory<_i69.WatchAuthUserUseCase>(
      () => _i69.WatchAuthUserUseCase(gh<_i446.AuthRepository>()),
    );
    return this;
  }
}

class _$ServiceModule extends _i592.ServiceModule {}
