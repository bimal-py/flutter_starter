import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/user/data/mapper/mapper.dart';
import 'package:flutter_starter/modules/user/domain/domain.dart';
import 'package:flutter_starter/modules/user/utils/constants/constants.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: RemoteUserRepository)
class RemoteUserRepositoryImpl implements RemoteUserRepository {
  RemoteUserRepositoryImpl(this._remote);

  final RemoteService _remote;

  @override
  Future<UserEntity> fetchUser() async {
    final response = await _remote.getResponse(
      endPoint: UserApiRoute.me,
      isTokenRequired: true,
    );
    final data = ApiResponseEnvelope.asObject(response);
    // `{user: {...}}` when the reply carries more than the user, else the
    // user itself.
    final user = data?['user'] is Map<String, dynamic>
        ? data!['user'] as Map<String, dynamic>
        : data;
    if (user == null || user['id'] == null) {
      throw const ServerException(message: UserError.invalidReply);
    }
    return UserMapper.fromJsonToEntity(user);
  }
}
