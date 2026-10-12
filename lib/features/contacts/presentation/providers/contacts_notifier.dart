import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/mock_contacts_interceptor.dart';
import '../../domain/usecases/get_contacts_usecase.dart';
import 'contacts_state.dart';

class ContactsNotifier extends Notifier<ContactsState> {
  final GetContactsUseCase getContactsUseCase;
  final MockContactsInterceptor mockInterceptor;
  CancelToken? currentCancelToken;

  ContactsNotifier({
    required this.getContactsUseCase,
    required this.mockInterceptor,
  });

  @override
  ContactsState build() {
    ref.onDispose(() {
      cancelActiveRequest();
    });

    return const ContactsState();
  }

  Future<void> fetchInitialContacts({bool isRefresh = false}) async {
    cancelActiveRequest();

    currentCancelToken = CancelToken();
    final activeToken = currentCancelToken;

    if (isRefresh) {
      state = state.copyWith(
        isRefreshing: true,
        clearInitialError: true,
        clearPaginationError: true,
      );
    } else {
      state = state.copyWith(
        status: ContactsStatus.loading,
        contacts: [],
        clearInitialError: true,
        clearPaginationError: true,
      );
    }

    try {
      final result = await getContactsUseCase.execute(
        GetContactsParams(
          page: 1,
          limit: ApiConstants.defaultPageSize,
          search: state.searchQuery.isEmpty ? null : state.searchQuery,
          cancelToken: activeToken,
        ),
      );

      if (activeToken?.isCancelled ?? false) {
        return;
      }

      if (result.contacts.isEmpty) {
        state = state.copyWith(
          status: ContactsStatus.empty,
          contacts: [],
          currentPage: 1,
          hasMore: false,
          isRefreshing: false,
        );
      } else {
        state = state.copyWith(
          status: ContactsStatus.loaded,
          contacts: result.contacts,
          currentPage: 1,
          hasMore: result.hasMore,
          isRefreshing: false,
        );
      }
    } on CancelledFailure {
      // Ignored since request was superseded by a newer query
    } on Failure catch (failure) {
      if (activeToken?.isCancelled ?? false) return;
      state = state.copyWith(
        status: ContactsStatus.error,
        initialErrorMessage: failure.message,
        isRefreshing: false,
      );
    } catch (e) {
      if (activeToken?.isCancelled ?? false) return;
      state = state.copyWith(
        status: ContactsStatus.error,
        initialErrorMessage: e.toString(),
        isRefreshing: false,
      );
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isPaginating ||
        !state.hasMore ||
        state.status == ContactsStatus.loading ||
        state.isRefreshing) {
      return;
    }

    state = state.copyWith(
      isPaginating: true,
      clearPaginationError: true,
    );

    final nextPage = state.currentPage + 1;

    try {
      final result = await getContactsUseCase.execute(
        GetContactsParams(
          page: nextPage,
          limit: ApiConstants.defaultPageSize,
          search: state.searchQuery.isEmpty ? null : state.searchQuery,
        ),
      );

      final combinedContacts = [...state.contacts, ...result.contacts];

      state = state.copyWith(
        status: ContactsStatus.loaded,
        contacts: combinedContacts,
        currentPage: nextPage,
        hasMore: result.hasMore,
        isPaginating: false,
      );
    } on Failure catch (failure) {
      state = state.copyWith(
        isPaginating: false,
        paginationErrorMessage: failure.message,
      );
    } catch (e) {
      state = state.copyWith(
        isPaginating: false,
        paginationErrorMessage: 'Failed to load more contacts. Please retry.',
      );
    }
  }

  void onSearchQueryChanged(String query) {
    final sanitizedQuery = query.trim();
    if (sanitizedQuery == state.searchQuery) {
      return;
    }

    cancelActiveRequest();

    state = state.copyWith(
      searchQuery: sanitizedQuery,
      currentPage: 1,
      hasMore: true,
      contacts: [],
      status: ContactsStatus.loading,
      clearInitialError: true,
      clearPaginationError: true,
    );

    fetchInitialContacts();
  }

  Future<void> refreshContacts() async {
    await fetchInitialContacts(isRefresh: true);
  }

  void retryInitialFetch() {
    fetchInitialContacts();
  }

  void retryPagination() {
    fetchNextPage();
  }

  void toggleSimulatedError() {
    final updated = !state.simulateError;
    mockInterceptor.setSimulateError(updated);
    state = state.copyWith(simulateError: updated);
  }

  void cancelActiveRequest() {
    if (currentCancelToken != null && !currentCancelToken!.isCancelled) {
      currentCancelToken!.cancel('Cancelled due to new request');
      currentCancelToken = null;
    }
  }
}
