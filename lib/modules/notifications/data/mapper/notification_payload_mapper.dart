import 'package:flutter_starter/modules/notifications/data/model/model.dart';
import 'package:flutter_starter/modules/notifications/domain/domain.dart';
import 'package:injectable/injectable.dart';

/// Bridges [NotificationPayloadModel] (data-layer JSON envelope) and
/// [NotificationPayloadEntity] (domain shape). Used at the underlying plugin's
/// `payload` string boundary so the entity never sees raw JSON.
///
/// `toEntity` defaults the non-serialized fields (sound, priority, actions,
/// largeIconUrl) because the JSON envelope only carries identification + data;
/// display-time settings come from the original `show` / `schedule` call.
@lazySingleton
class NotificationPayloadMapper {
  const NotificationPayloadMapper();

  NotificationPayloadEntity toEntity(NotificationPayloadModel model) =>
      NotificationPayloadEntity(
        id: model.id,
        title: model.title,
        body: model.body,
        data: model.data,
        channel: model.channel,
      );

  NotificationPayloadModel toModel(NotificationPayloadEntity entity) =>
      NotificationPayloadModel(
        id: entity.id,
        title: entity.title,
        body: entity.body,
        data: entity.data,
        channel: entity.channel,
      );
}
