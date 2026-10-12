import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/mock_contacts_interceptor.dart';
import '../../domain/usecases/get_contacts_usecase.dart';
import 'contacts_notifier.dart';
import 'contacts_state.dart';

final contactsProvider =
    NotifierProvider<ContactsNotifier, ContactsState>(() {
  return ContactsNotifier(
    getContactsUseCase: getIt<GetContactsUseCase>(),
    mockInterceptor: getIt<MockContactsInterceptor>(),
  );
});
