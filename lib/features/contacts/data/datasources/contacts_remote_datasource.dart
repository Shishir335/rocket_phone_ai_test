import 'package:dio/dio.dart';
import '../models/contacts_response_model.dart';
import 'contacts_api_client.dart';

abstract class ContactsRemoteDataSource {
  Future<ContactsResponseModel> getContacts({
    required int page,
    required int limit,
    String? search,
    CancelToken? cancelToken,
  });
}

class ContactsRemoteDataSourceImpl implements ContactsRemoteDataSource {
  final ContactsApiClient apiClient;

  ContactsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ContactsResponseModel> getContacts({
    required int page,
    required int limit,
    String? search,
    CancelToken? cancelToken,
  }) {
    return apiClient.getContacts(
      page: page,
      limit: limit,
      search: search,
      cancelToken: cancelToken,
    );
  }
}
