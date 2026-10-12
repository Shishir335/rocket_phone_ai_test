import 'package:dio/dio.dart';
import '../entities/contacts_page_entity.dart';

abstract class ContactsRepository {
  Future<ContactsPageEntity> getContacts({
    required int page,
    required int limit,
    String? search,
    CancelToken? cancelToken,
  });
}
