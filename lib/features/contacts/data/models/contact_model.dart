import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/contact_entity.dart';

part 'contact_model.g.dart';

@JsonSerializable()
class ContactModel extends ContactEntity {
  const ContactModel({
    required super.id,
    required super.name,
    required super.phone,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) =>
      _$ContactModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContactModelToJson(this);

  factory ContactModel.fromEntity(ContactEntity entity) {
    return ContactModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
    );
  }
}
