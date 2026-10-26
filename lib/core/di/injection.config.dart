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
import 'package:flutter_starter/core/core.dart' as _i527;
import 'package:flutter_starter/core/di/service_module.dart' as _i592;
import 'package:flutter_starter/core/network/dio/config/config.dart' as _i644;
import 'package:flutter_starter/core/network/dio/config/dio_config.dart'
    as _i588;
import 'package:flutter_starter/core/network/dio/dio.dart' as _i952;
import 'package:flutter_starter/core/network/dio/dio_client.dart' as _i438;
import 'package:flutter_starter/core/network/dio/interceptors/logout_interceptor.dart'
    as _i373;
import 'package:flutter_starter/core/network/service/remote_service_impl.dart'
    as _i29;
import 'package:flutter_starter/core/network/service/service.dart' as _i167;
import 'package:flutter_starter/modules/auth/data/repository/local/local_auth_session_repository_impl.dart'
    as _i521;
import 'package:flutter_starter/modules/auth/data/repository/remote/auth_token_handler_impl.dart'
    as _i324;
import 'package:flutter_starter/modules/auth/data/repository/remote/logout_handler_impl.dart'
    as _i245;
import 'package:flutter_starter/modules/auth/data/repository/remote/remote_auth_repository_impl.dart'
    as _i744;
import 'package:flutter_starter/modules/auth/data/repository/remote/third_party_auth_provider_stub.dart'
    as _i318;
import 'package:flutter_starter/modules/auth/domain/domain.dart' as _i648;
import 'package:flutter_starter/modules/auth/domain/repository/repository.dart'
    as _i435;
import 'package:flutter_starter/modules/auth/domain/use_case/local/get_remembered_email_use_case.dart'
    as _i390;
import 'package:flutter_starter/modules/auth/domain/use_case/local/restore_auth_session_use_case.dart'
    as _i734;
import 'package:flutter_starter/modules/auth/domain/use_case/local/watch_auth_session_use_case.dart'
    as _i429;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/change_password_use_case.dart'
    as _i352;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/confirm_password_reset_use_case.dart'
    as _i725;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/login_use_case.dart'
    as _i870;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/login_with_apple_use_case.dart'
    as _i232;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/login_with_google_use_case.dart'
    as _i468;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/logout_use_case.dart'
    as _i962;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/register_use_case.dart'
    as _i695;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/request_password_reset_use_case.dart'
    as _i97;
import 'package:flutter_starter/modules/auth/domain/use_case/remote/send_verification_code_use_case.dart'
    as _i863;
import 'package:flutter_starter/modules/device_info/data/repository/remote/remote_device_info_repository_impl.dart'
    as _i722;
import 'package:flutter_starter/modules/device_info/domain/domain.dart'
    as _i190;
import 'package:flutter_starter/modules/device_info/domain/repository/repository.dart'
    as _i123;
import 'package:flutter_starter/modules/device_info/domain/use_case/remote/get_device_info_use_case.dart'
    as _i502;
import 'package:flutter_starter/modules/fcm/data/repository/remote/remote_fcm_repository_impl.dart'
    as _i295;
import 'package:flutter_starter/modules/fcm/domain/domain.dart' as _i204;
import 'package:flutter_starter/modules/notifications/data/mapper/notification_payload_mapper.dart'
    as _i482;
import 'package:flutter_starter/modules/package_info/data/repository/remote/remote_package_info_repository_impl.dart'
    as _i729;
import 'package:flutter_starter/modules/package_info/domain/domain.dart'
    as _i609;
import 'package:flutter_starter/modules/package_info/domain/repository/repository.dart'
    as _i563;
import 'package:flutter_starter/modules/package_info/domain/use_case/remote/get_package_info_use_case.dart'
    as _i670;
import 'package:flutter_starter/modules/user/data/repository/local/local_user_repository_impl.dart'
    as _i205;
import 'package:flutter_starter/modules/user/data/repository/remote/remote_user_repository_impl.dart'
    as _i175;
import 'package:flutter_starter/modules/user/domain/domain.dart' as _i885;
import 'package:flutter_starter/modules/user/domain/repository/repository.dart'
    as _i178;
import 'package:flutter_starter/modules/user/domain/use_case/local/get_saved_user_use_case.dart'
    as _i483;
import 'package:flutter_starter/modules/user/domain/use_case/local/update_local_user_use_case.dart'
    as _i672;
import 'package:flutter_starter/modules/user/domain/use_case/local/watch_user_use_case.dart'
    as _i512;
import 'package:flutter_starter/modules/user/domain/use_case/remote/fetch_user_use_case.dart'
    as _i18;
import 'package:flutter_starter/modules/user/user.dart' as _i140;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final serviceModule = _$ServiceModule();
    gh.factory<_i588.DioConfig>(() => _i588.DioConfig());
    gh.singleton<_i558.FlutterSecureStorage>(() => serviceModule.secureStorage);
    gh.singleton<_i895.Connectivity>(() => serviceModule.connectivity);
    gh.singleton<_i373.LogoutInterceptor>(() => _i373.LogoutInterceptor());
    gh.lazySingleton<_i482.NotificationPayloadMapper>(
      () => const _i482.NotificationPayloadMapper(),
    );
    gh.factory<_i438.DioClient>(() => _i438.DioClient(gh<_i644.DioConfig>()));
    gh.lazySingleton<_i648.ThirdPartyAuthProvider>(
      () => _i318.ThirdPartyAuthProviderStub(),
    );
    gh.lazySingleton<_i204.RemoteFcmRepository>(
      () => _i295.RemoteFcmRepositoryImpl(),
    );
    gh.lazySingleton<_i190.RemoteDeviceInfoRepository>(
      () => _i722.RemoteDeviceInfoRepositoryImpl(),
    );
    gh.lazySingleton<_i885.LocalUserRepository>(
      () => _i205.LocalUserRepositoryImpl(),
    );
    gh.lazySingleton<_i609.RemotePackageInfoRepository>(
      () => _i729.RemotePackageInfoRepositoryImpl(),
    );
    gh.lazySingleton<_i648.LocalAuthSessionRepository>(
      () => _i521.LocalAuthSessionRepositoryImpl(),
    );
    gh.factory<_i734.RestoreAuthSessionUseCase>(
      () => _i734.RestoreAuthSessionUseCase(
        gh<_i435.LocalAuthSessionRepository>(),
        gh<_i140.LocalUserRepository>(),
      ),
    );
    gh.factory<_i483.GetSavedUserUseCase>(
      () => _i483.GetSavedUserUseCase(gh<_i178.LocalUserRepository>()),
    );
    gh.factory<_i672.UpdateLocalUserUseCase>(
      () => _i672.UpdateLocalUserUseCase(gh<_i178.LocalUserRepository>()),
    );
    gh.factory<_i512.WatchUserUseCase>(
      () => _i512.WatchUserUseCase(gh<_i178.LocalUserRepository>()),
    );
    gh.factory<_i670.GetPackageInfoUseCase>(
      () =>
          _i670.GetPackageInfoUseCase(gh<_i563.RemotePackageInfoRepository>()),
    );
    gh.factory<_i502.GetDeviceInfoUseCase>(
      () => _i502.GetDeviceInfoUseCase(gh<_i123.RemoteDeviceInfoRepository>()),
    );
    gh.factory<_i167.RemoteService>(
      () =>
          _i29.RemoteServiceImpl(gh<_i952.DioClient>(), gh<_i952.DioConfig>()),
    );
    gh.factory<_i390.GetRememberedEmailUseCase>(
      () => _i390.GetRememberedEmailUseCase(
        gh<_i435.LocalAuthSessionRepository>(),
      ),
    );
    gh.factory<_i429.WatchAuthSessionUseCase>(
      () =>
          _i429.WatchAuthSessionUseCase(gh<_i435.LocalAuthSessionRepository>()),
    );
    gh.lazySingleton<_i648.LogoutHandler>(
      () => _i245.LogoutHandlerImpl(
        gh<_i648.LocalAuthSessionRepository>(),
        gh<_i140.LocalUserRepository>(),
        gh<_i527.DioConfig>(),
        gh<_i527.LogoutInterceptor>(),
        gh<_i648.ThirdPartyAuthProvider>(),
      ),
    );
    gh.factory<_i962.LogoutUseCase>(
      () => _i962.LogoutUseCase(gh<_i435.LogoutHandler>()),
    );
    gh.factory<_i885.RemoteUserRepository>(
      () => _i175.RemoteUserRepositoryImpl(gh<_i527.RemoteService>()),
    );
    gh.lazySingleton<_i527.AuthTokenHandler>(
      () => _i324.AuthTokenHandlerImpl(
        gh<_i648.LocalAuthSessionRepository>(),
        gh<_i648.LogoutHandler>(),
        gh<_i527.DioConfig>(),
      ),
    );
    gh.lazySingleton<_i648.RemoteAuthRepository>(
      () => _i744.RemoteAuthRepositoryImpl(
        gh<_i527.RemoteService>(),
        gh<_i648.LocalAuthSessionRepository>(),
        gh<_i527.LogoutInterceptor>(),
        gh<_i648.ThirdPartyAuthProvider>(),
        gh<_i140.RemoteUserRepository>(),
        gh<_i140.LocalUserRepository>(),
      ),
    );
    gh.factory<_i352.ChangePasswordUseCase>(
      () => _i352.ChangePasswordUseCase(gh<_i435.RemoteAuthRepository>()),
    );
    gh.factory<_i725.ConfirmPasswordResetUseCase>(
      () => _i725.ConfirmPasswordResetUseCase(gh<_i435.RemoteAuthRepository>()),
    );
    gh.factory<_i870.LoginUseCase>(
      () => _i870.LoginUseCase(gh<_i435.RemoteAuthRepository>()),
    );
    gh.factory<_i232.LoginWithAppleUseCase>(
      () => _i232.LoginWithAppleUseCase(gh<_i435.RemoteAuthRepository>()),
    );
    gh.factory<_i468.LoginWithGoogleUseCase>(
      () => _i468.LoginWithGoogleUseCase(gh<_i435.RemoteAuthRepository>()),
    );
    gh.factory<_i695.RegisterUseCase>(
      () => _i695.RegisterUseCase(gh<_i435.RemoteAuthRepository>()),
    );
    gh.factory<_i97.RequestPasswordResetUseCase>(
      () => _i97.RequestPasswordResetUseCase(gh<_i435.RemoteAuthRepository>()),
    );
    gh.factory<_i863.SendVerificationCodeUseCase>(
      () => _i863.SendVerificationCodeUseCase(gh<_i435.RemoteAuthRepository>()),
    );
    gh.factory<_i18.FetchUserUseCase>(
      () => _i18.FetchUserUseCase(
        gh<_i178.RemoteUserRepository>(),
        gh<_i178.LocalUserRepository>(),
      ),
    );
    return this;
  }
}

class _$ServiceModule extends _i592.ServiceModule {}
