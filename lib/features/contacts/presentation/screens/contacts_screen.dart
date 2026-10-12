import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/contact_list_item.dart';
import '../components/contact_search_bar.dart';
import '../components/contacts_empty_view.dart';
import '../components/contacts_error_view.dart';
import '../components/pagination_error_view.dart';
import '../components/pagination_loading_indicator.dart';
import '../components/responsive_layout_container.dart';
import '../components/simulated_error_switch.dart';
import '../providers/contacts_providers.dart';
import '../providers/contacts_state.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => ContactsScreenState();
}

class ContactsScreenState extends ConsumerState<ContactsScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    setupScrollListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactsProvider.notifier).fetchInitialContacts();
    });
  }

  void setupScrollListener() {
    scrollController.addListener(handleScroll);
  }

  void handleScroll() {
    if (!scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    const threshold = 180.0;

    if (maxScroll - currentScroll <= threshold) {
      ref.read(contactsProvider.notifier).fetchNextPage();
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(handleScroll);
    scrollController.dispose();
    super.dispose();
  }

  Widget buildBody(BuildContext context, ContactsState state) {
    final notifier = ref.read(contactsProvider.notifier);

    if (state.status == ContactsStatus.loading && !state.isRefreshing) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
        ),
      );
    }

    if (state.status == ContactsStatus.error && state.contacts.isEmpty) {
      return ContactsErrorView(
        errorMessage: state.initialErrorMessage ?? 'Unknown error occurred',
        onRetry: notifier.retryInitialFetch,
      );
    }

    if (state.status == ContactsStatus.empty) {
      return ContactsEmptyView(
        searchQuery: state.searchQuery,
        onClearSearch: () => notifier.onSearchQueryChanged(''),
      );
    }

    final itemCount = state.contacts.length +
        (state.isPaginating ? 1 : 0) +
        (state.paginationErrorMessage != null ? 1 : 0);

    return RefreshIndicator(
      color: const Color(0xFF2563EB),
      onRefresh: notifier.refreshContacts,
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index < state.contacts.length) {
            return ContactListItem(contact: state.contacts[index]);
          }

          if (state.isPaginating && index == state.contacts.length) {
            return const PaginationLoadingIndicator();
          }

          if (state.paginationErrorMessage != null) {
            return PaginationErrorView(
              errorMessage: state.paginationErrorMessage!,
              onRetry: notifier.retryPagination,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contactsProvider);
    final notifier = ref.read(contactsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          SimulatedErrorSwitch(
            isSimulatingError: state.simulateError,
            onToggle: notifier.toggleSimulatedError,
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayoutContainer(
          child: Column(
            children: [
              const SizedBox(height: 12),
              ContactSearchBar(
                initialQuery: state.searchQuery,
                onSearch: notifier.onSearchQueryChanged,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: buildBody(context, state),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
