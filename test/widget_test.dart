import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rocket_phone_ai_test/core/network/mock_contacts_interceptor.dart';
import 'package:rocket_phone_ai_test/features/contacts/domain/entities/contact_entity.dart';
import 'package:rocket_phone_ai_test/features/contacts/domain/entities/contacts_page_entity.dart';
import 'package:rocket_phone_ai_test/features/contacts/domain/usecases/get_contacts_usecase.dart';
import 'package:rocket_phone_ai_test/features/contacts/presentation/components/contact_list_item.dart';
import 'package:rocket_phone_ai_test/features/contacts/presentation/components/contact_search_bar.dart';
import 'package:rocket_phone_ai_test/features/contacts/presentation/providers/contacts_notifier.dart';
import 'package:rocket_phone_ai_test/features/contacts/presentation/providers/contacts_providers.dart';
import 'package:rocket_phone_ai_test/features/contacts/presentation/screens/contacts_screen.dart';

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

  const testContacts = [
    ContactEntity(id: '1', name: 'Alexander Smith', phone: '+421901234567'),
    ContactEntity(id: '2', name: 'Anna Petrova', phone: '+421903456789'),
  ];

  const testPage = ContactsPageEntity(
    contacts: testContacts,
    page: 1,
    limit: 10,
    total: 2,
    hasMore: false,
  );

  testWidgets(
      'Renders ContactsScreen, search bar, and displays contacts once loaded',
      (tester) async {
    when(() => mockUseCase.execute(any())).thenAnswer((_) async => testPage);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contactsProvider.overrideWith(
            () => ContactsNotifier(
              getContactsUseCase: mockUseCase,
              mockInterceptor: mockInterceptor,
            ),
          ),
        ],
        child: const MaterialApp(
          home: ContactsScreen(),
        ),
      ),
    );

    // Initial frame
    expect(find.text('Contacts'), findsOneWidget);
    expect(find.byType(ContactSearchBar), findsOneWidget);

    // Process asynchronous post-frame and Future resolution
    await tester.pumpAndSettle();

    // Verify contact items are rendered
    expect(find.byType(ContactListItem), findsNWidgets(2));
    expect(find.text('Alexander Smith'), findsOneWidget);
    expect(find.text('+421901234567'), findsOneWidget);
    expect(find.text('Anna Petrova'), findsOneWidget);
  });
}
