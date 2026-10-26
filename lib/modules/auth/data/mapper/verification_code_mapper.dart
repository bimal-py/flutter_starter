import 'dart:convert';

import 'package:flutter_starter/modules/auth/data/model/model.dart';
import 'package:flutter_starter/modules/auth/domain/entity/entity.dart';

class VerificationCodeMapper {
  VerificationCodeMapper._();

  static VerificationCodeEntity toEntity(VerificationCodeModel model) {
    return VerificationCodeEntity(
      alreadySent: model.alreadySent,
      expiresIn: model.expiresIn,
    );
  }

  static VerificationCodeModel toModel(VerificationCodeEntity entity) {
    return VerificationCodeModel(
      alreadySent: entity.alreadySent,
      expiresIn: entity.expiresIn,
    );
  }

  static VerificationCodeEntity fromJsonToEntity(Map<String, dynamic> json) {
    return toEntity(VerificationCodeModel.fromJson(json));
  }

  static VerificationCodeEntity fromRawJsonToEntity(String rawJson) {
    return toEntity(
      VerificationCodeModel.fromJson(
        jsonDecode(rawJson) as Map<String, dynamic>,
      ),
    );
  }

  static Map<String, dynamic> toJsonFromEntity(VerificationCodeEntity entity) {
    return toModel(entity).toJson();
  }

  static String toRawJsonFromEntity(VerificationCodeEntity entity) {
    return jsonEncode(toModel(entity).toJson());
  }

  static List<VerificationCodeEntity> fromJsonListToEntityList(
    List<dynamic> jsonList,
  ) {
    return jsonList
        .map((json) => fromJsonToEntity(json as Map<String, dynamic>))
        .toList();
  }

  static List<VerificationCodeEntity> fromRawJsonListToEntityList(
    String rawJsonList,
  ) {
    final List<dynamic> jsonList = jsonDecode(rawJsonList) as List<dynamic>;
    return fromJsonListToEntityList(jsonList);
  }

  static List<Map<String, dynamic>> toJsonListFromEntityList(
    List<VerificationCodeEntity> entities,
  ) {
    return entities.map(toJsonFromEntity).toList();
  }

  static String toRawJsonListFromEntityList(
    List<VerificationCodeEntity> entities,
  ) {
    return jsonEncode(toJsonListFromEntityList(entities));
  }
}
