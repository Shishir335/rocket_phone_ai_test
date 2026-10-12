import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rocket_phone_ai_test/core/errors/failures.dart';
import 'package:rocket_phone_ai_test/core/network/mock_contacts_interceptor.dart';
import 'package:rocket_phone_ai_test/features/contacts/domain/entities/contact_entity.dart';
import 'package:rocket_phone_ai_test/features/contacts/domain/entities/contacts_page_entity.dart';
import 'package:rocket_phone_ai_test/features/contacts/domain/usecases/get_contacts_usecase.dart';
import 'package:rocket_phone_ai_test/features/contacts/presentation/providers/contacts_notifier.dart';
import 'package:rocket_phone_ai_test/features/contacts/presentation/providers/contacts_providers.dart';
import 'package:rocket_phone_ai_test/features/contacts/presentation/providers/contacts_state.dart';

class MockGetContactsUseCase extends Mock implements GetContactsUseCase {}

class MockMockContactsInterceptor extends Mock
    implements MockContactsInterceptor {}

class FakeGetContactsParams extends Fake implements GetContactsParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGetContactsParams());
  });

  late MockGetContactsUseCase mockUseCase;
  late MockMockContactsInterceptor mockInterceptor;

  setUp(() {
    mockUseCase = MockGetContactsUseCase();
    mockInterceptor = MockMockContactsInterceptor();
  });

  group('ContactsNotifier Tests', () {
    const sampleContacts = [
      ContactEntity(id: '1', name: 'Alexander Smith', phone: '+421901234567'),
      ContactEntity(id: '2', name: 'Anna Petrova', phone: '+421903456789'),
    ];

    const samplePage = ContactsPageEntity(
      contacts: sampleContacts,
      page: 1,
      limit: 10,
      total: 2,
      hasMore: true,
    );

    test('fetches initial contacts and updates state to loaded', () async {
      when(() => mockUseCase.execute(any())).thenAnswer((_) async => samplePage);

      final container = ProviderContainer(
        overrides: [
          contactsProvider.overrideWith(
            () => ContactsNotifier(
              getContactsUseCase: mockUseCase,
              mockInterceptor: mockInterceptor,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(contactsProvider.notifier);
      await notifier.fetchInitialContacts();

      final state = container.read(contactsProvider);
      expect(state.status, ContactsStatus.loaded);
      expect(state.contacts.length, 2);
      expect(state.currentPage, 1);
      expect(state.hasMore, true);
    });

    test('sets state to empty when 0 contacts are returned', () async {
      when(() => mockUseCase.execute(any())).thenAnswer(
        (_) async => const ContactsPageEntity(
          contacts: [],
          page: 1,
          limit: 10,
          total: 0,
          hasMore: false,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          contactsProvider.overrideWith(
            () => ContactsNotifier(
              getContactsUseCase: mockUseCase,
              mockInterceptor: mockInterceptor,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(contactsProvider.notifier);
      await notifier.fetchInitialContacts();

      final state = container.read(contactsProvider);
      expect(state.status, ContactsStatus.empty);
      expect(state.contacts, isEmpty);
      expect(state.hasMore, false);
    });

    test('sets state to error when initial fetch throws Failure', () async {
      when(() => mockUseCase.execute(any()))
          .thenThrow(const ServerFailure('Server unavailable'));

      final container = ProviderContainer(
        overrides: [
          contactsProvider.overrideWith(
            () => ContactsNotifier(
              getContactsUseCase: mockUseCase,
              mockInterceptor: mockInterceptor,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(contactsProvider.notifier);
      await notifier.fetchInitialContacts();

      final state = container.read(contactsProvider);
      expect(state.status, ContactsStatus.error);
      expect(state.initialErrorMessage, 'Server unavailable');
    });

    test('handles pagination and appends new contacts', () async {
      when(() => mockUseCase.execute(any())).thenAnswer((_) async => samplePage);

      final container = ProviderContainer(
        overrides: [
          contactsProvider.overrideWith(
            () => ContactsNotifier(
              getContactsUseCase: mockUseCase,
              mockInterceptor: mockInterceptor,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(contactsProvider.notifier);
      await notifier.fetchInitialContacts();

      const pageTwoContacts = [
        ContactEntity(id: '3', name: 'John Johnson', phone: '+421902345678'),
      ];
      when(() => mockUseCase.execute(any())).thenAnswer(
        (_) async => const ContactsPageEntity(
          contacts: pageTwoContacts,
          page: 2,
          limit: 10,
          total: 3,
          hasMore: false,
        ),
      );

      await notifier.fetchNextPage();

      final state = container.read(contactsProvider);
      expect(state.contacts.length, 3);
      expect(state.currentPage, 2);
      expect(state.hasMore, false);
      expect(state.isPaginating, false);
    });

    test('onSearchQueryChanged resets pagination and updates query', () async {
      when(() => mockUseCase.execute(any())).thenAnswer((_) async => samplePage);

      final container = ProviderContainer(
        overrides: [
          contactsProvider.overrideWith(
            () => ContactsNotifier(
              getContactsUseCase: mockUseCase,
              mockInterceptor: mockInterceptor,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(contactsProvider.notifier);
      await notifier.fetchInitialContacts();

      notifier.onSearchQueryChanged('Alex');
      final state = container.read(contactsProvider);
      expect(state.searchQuery, 'Alex');
      expect(state.currentPage, 1);
    });
  });
}
