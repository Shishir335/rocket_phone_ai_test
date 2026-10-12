import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rocket_phone_ai_test/core/errors/failures.dart';
import 'package:rocket_phone_ai_test/features/contacts/data/datasources/contacts_remote_datasource.dart';
import 'package:rocket_phone_ai_test/features/contacts/data/models/contact_model.dart';
import 'package:rocket_phone_ai_test/features/contacts/data/models/contacts_response_model.dart';
import 'package:rocket_phone_ai_test/features/contacts/data/repositories/contacts_repository_impl.dart';

class MockContactsRemoteDataSource extends Mock
    implements ContactsRemoteDataSource {}

void main() {
  late MockContactsRemoteDataSource mockRemoteDataSource;
  late ContactsRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockContactsRemoteDataSource();
    repository = ContactsRepositoryImpl(mockRemoteDataSource);
  });

  group('ContactsRepositoryImpl Tests', () {
    const testContacts = [
      ContactModel(id: '1', name: 'Alexander Smith', phone: '+421901234567'),
      ContactModel(id: '2', name: 'Anna Petrova', phone: '+421903456789'),
    ];

    const testResponse = ContactsResponseModel(
      contacts: testContacts,
      page: 1,
      limit: 10,
      total: 2,
      hasMore: false,
    );

    test('should return ContactsPageEntity when remote data source succeeds',
        () async {
      when(
        () => mockRemoteDataSource.getContacts(
          page: 1,
          limit: 10,
          search: null,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => testResponse);

      final result = await repository.getContacts(page: 1, limit: 10);

      expect(result.contacts.length, 2);
      expect(result.contacts.first.name, 'Alexander Smith');
      expect(result.hasMore, false);
      verify(() => mockRemoteDataSource.getContacts(page: 1, limit: 10)).called(1);
    });

    test('should throw ServerFailure when remote data source throws DioException',
        () async {
      when(
        () => mockRemoteDataSource.getContacts(
          page: 1,
          limit: 10,
          search: any(named: 'search'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/contacts'),
          response: Response(
            requestOptions: RequestOptions(path: '/contacts'),
            statusCode: 500,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => repository.getContacts(page: 1, limit: 10),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('should throw NetworkFailure when connection fails', () async {
      when(
        () => mockRemoteDataSource.getContacts(
          page: 1,
          limit: 10,
          search: any(named: 'search'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/contacts'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(
        () => repository.getContacts(page: 1, limit: 10),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}
