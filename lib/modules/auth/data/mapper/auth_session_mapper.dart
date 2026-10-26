import 'dart:convert';

import 'package:flutter_starter/modules/auth/data/model/model.dart';
import 'package:flutter_starter/modules/auth/domain/entity/entity.dart';

class AuthSessionMapper {
  AuthSessionMapper._();

  static AuthSessionEntity toEntity(AuthSessionModel model) {
    return AuthSessionEntity(
      userId: model.userId,
      email: model.email,
      remember: model.remember,
    );
  }

  static AuthSessionModel toModel(AuthSessionEntity entity) {
    return AuthSessionModel(
      userId: entity.userId,
      email: entity.email,
      remember: entity.remember,
    );
  }

  static AuthSessionEntity fromJsonToEntity(Map<String, dynamic> json) {
    return toEntity(AuthSessionModel.fromJson(json));
  }

  static AuthSessionEntity fromRawJsonToEntity(String rawJson) {
    return toEntity(
      AuthSessionModel.fromJson(jsonDecode(rawJson) as Map<String, dynamic>),
    );
  }

  static Map<String, dynamic> toJsonFromEntity(AuthSessionEntity entity) {
    return toModel(entity).toJson();
  }

  static String toRawJsonFromEntity(AuthSessionEntity entity) {
    return jsonEncode(toModel(entity).toJson());
  }

  static List<AuthSessionEntity> fromJsonListToEntityList(
    List<dynamic> jsonList,
  ) {
    return jsonList
        .map((json) => fromJsonToEntity(json as Map<String, dynamic>))
        .toList();
  }

  static List<AuthSessionEntity> fromRawJsonListToEntityList(
    String rawJsonList,
  ) {
    final List<dynamic> jsonList = jsonDecode(rawJsonList) as List<dynamic>;
    return fromJsonListToEntityList(jsonList);
  }

  static List<Map<String, dynamic>> toJsonListFromEntityList(
    List<AuthSessionEntity> entities,
  ) {
    return entities.map(toJsonFromEntity).toList();
  }

  static String toRawJsonListFromEntityList(List<AuthSessionEntity> entities) {
    return jsonEncode(toJsonListFromEntityList(entities));
  }
}
