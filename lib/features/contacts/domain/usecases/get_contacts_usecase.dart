import 'package:dio/dio.dart';
import '../entities/contacts_page_entity.dart';
import '../repositories/contacts_repository.dart';

class GetContactsParams {
  final int page;
  final int limit;
  final String? search;
  final CancelToken? cancelToken;

  const GetContactsParams({
    required this.page,
    required this.limit,
    this.search,
    this.cancelToken,
  });
}

class GetContactsUseCase {
  final ContactsRepository repository;

  GetContactsUseCase(this.repository);

  Future<ContactsPageEntity> execute(GetContactsParams params) {
    return repository.getContacts(
      page: params.page,
      limit: params.limit,
      search: params.search,
      cancelToken: params.cancelToken,
    );
  }
}
