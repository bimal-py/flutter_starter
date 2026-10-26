import 'dart:convert';

import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/user/data/model/model.dart';
import 'package:flutter_starter/modules/user/domain/entity/entity.dart';

class UserMapper {
  UserMapper._();

  static UserEntity toEntity(UserModel model) {
    final avatar = model.avatarUrl;
    return UserEntity(
      id: model.id,
      fullName: model.fullName.capitalizeWords,
      username: model.username,
      email: model.email,
      phone: model.phone,
      gender: model.gender,
      joinedAt: model.joinedAt,
      avatar: avatar == null || avatar.isEmpty ? null : avatar,
      birthday: model.dob,
    );
  }

  static UserModel toModel(UserEntity entity) {
    return UserModel(
      id: entity.id,
      fullName: entity.fullName,
      username: entity.username,
      email: entity.email,
      phone: entity.phone,
      gender: entity.gender,
      joinedAt: entity.joinedAt,
      avatarUrl: entity.avatar,
      dob: entity.birthday,
    );
  }

  static UserEntity fromJsonToEntity(Map<String, dynamic> json) {
    return toEntity(UserModel.fromJson(json));
  }

  static UserEntity fromRawJsonToEntity(String rawJson) {
    return toEntity(
      UserModel.fromJson(jsonDecode(rawJson) as Map<String, dynamic>),
    );
  }

  static Map<String, dynamic> toJsonFromEntity(UserEntity entity) {
    return toModel(entity).toJson();
  }

  static String toRawJsonFromEntity(UserEntity entity) {
    return jsonEncode(toModel(entity).toJson());
  }

  static List<UserEntity> fromJsonListToEntityList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => fromJsonToEntity(json as Map<String, dynamic>))
        .toList();
  }

  static List<UserEntity> fromRawJsonListToEntityList(String rawJsonList) {
    final List<dynamic> jsonList = jsonDecode(rawJsonList) as List<dynamic>;
    return fromJsonListToEntityList(jsonList);
  }

  static List<Map<String, dynamic>> toJsonListFromEntityList(
    List<UserEntity> entities,
  ) {
    return entities.map(toJsonFromEntity).toList();
  }

  static String toRawJsonListFromEntityList(List<UserEntity> entities) {
    return jsonEncode(toJsonListFromEntityList(entities));
  }
}
