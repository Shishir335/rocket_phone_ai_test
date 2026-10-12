// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactsResponseModel _$ContactsResponseModelFromJson(
  Map<String, dynamic> json,
) => ContactsResponseModel(
  contacts: (json['contacts'] as List<dynamic>)
      .map((e) => ContactModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  total: (json['total'] as num).toInt(),
  hasMore: json['hasMore'] as bool,
);

Map<String, dynamic> _$ContactsResponseModelToJson(
  ContactsResponseModel instance,
) => <String, dynamic>{
  'contacts': instance.contacts.map((e) => e.toJson()).toList(),
  'page': instance.page,
  'limit': instance.limit,
  'total': instance.total,
  'hasMore': instance.hasMore,
};
