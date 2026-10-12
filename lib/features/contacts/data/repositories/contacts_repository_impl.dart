import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/contacts_page_entity.dart';
import '../../domain/repositories/contacts_repository.dart';
import '../datasources/contacts_remote_datasource.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  final ContactsRemoteDataSource remoteDataSource;

  ContactsRepositoryImpl(this.remoteDataSource);

  @override
  Future<ContactsPageEntity> getContacts({
    required int page,
    required int limit,
    String? search,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await remoteDataSource.getContacts(
        page: page,
        limit: limit,
        search: search,
        cancelToken: cancelToken,
      );
      return response.toEntity();
    } on DioException catch (dioException) {
      if (dioException.type == DioExceptionType.cancel) {
        throw const CancelledFailure();
      }
      if (dioException.type == DioExceptionType.connectionError ||
          dioException.type == DioExceptionType.connectionTimeout) {
        throw const NetworkFailure();
      }
      final message = dioException.message ?? 'Server error occurred.';
      throw ServerFailure(message);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw UnknownFailure(e.toString());
    }
  }
}
