import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../constants/api_constants.dart';
import '../network/dio_factory.dart';
import '../network/mock_contacts_interceptor.dart';
import '../utils/debouncer.dart';
import '../../features/contacts/data/datasources/contacts_api_client.dart';
import '../../features/contacts/data/datasources/contacts_remote_datasource.dart';
import '../../features/contacts/data/repositories/contacts_repository_impl.dart';
import '../../features/contacts/domain/repositories/contacts_repository.dart';
import '../../features/contacts/domain/usecases/get_contacts_usecase.dart';

final GetIt getIt = GetIt.instance;

void initializeDependencies() {
  // Core Network & Interceptors
  getIt.registerLazySingleton<MockContactsInterceptor>(
    () => MockContactsInterceptor(),
  );

  getIt.registerLazySingleton<Dio>(
    () => DioFactory.createDio(getIt<MockContactsInterceptor>()),
  );

  // Data Sources (Retrofit)
  getIt.registerLazySingleton<ContactsApiClient>(
    () => ContactsApiClient(getIt<Dio>()),
  );

  getIt.registerLazySingleton<ContactsRemoteDataSource>(
    () => ContactsRemoteDataSourceImpl(getIt<ContactsApiClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<ContactsRepository>(
    () => ContactsRepositoryImpl(getIt<ContactsRemoteDataSource>()),
  );

  // Use Cases
  getIt.registerLazySingleton<GetContactsUseCase>(
    () => GetContactsUseCase(getIt<ContactsRepository>()),
  );

  // Utilities
  getIt.registerFactory<Debouncer>(
    () => Debouncer(milliseconds: ApiConstants.debounceDurationMs),
  );
}
