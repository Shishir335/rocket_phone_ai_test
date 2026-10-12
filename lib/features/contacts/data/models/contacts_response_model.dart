import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/contacts_page_entity.dart';
import 'contact_model.dart';

part 'contacts_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ContactsResponseModel {
  @JsonKey(name: 'contacts')
  final List<ContactModel> contacts;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  const ContactsResponseModel({
    required this.contacts,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  factory ContactsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ContactsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContactsResponseModelToJson(this);

  ContactsPageEntity toEntity() {
    return ContactsPageEntity(
      contacts: contacts,
      page: page,
      limit: limit,
      total: total,
      hasMore: hasMore,
    );
  }
}
