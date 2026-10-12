import 'package:equatable/equatable.dart';
import '../../domain/entities/contact_entity.dart';

enum ContactsStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

class ContactsState extends Equatable {
  final ContactsStatus status;
  final List<ContactEntity> contacts;
  final String searchQuery;
  final int currentPage;
  final bool hasMore;
  final bool isPaginating;
  final bool isRefreshing;
  final String? initialErrorMessage;
  final String? paginationErrorMessage;
  final bool simulateError;

  const ContactsState({
    this.status = ContactsStatus.initial,
    this.contacts = const [],
    this.searchQuery = '',
    this.currentPage = 1,
    this.hasMore = true,
    this.isPaginating = false,
    this.isRefreshing = false,
    this.initialErrorMessage,
    this.paginationErrorMessage,
    this.simulateError = false,
  });

  ContactsState copyWith({
    ContactsStatus? status,
    List<ContactEntity>? contacts,
    String? searchQuery,
    int? currentPage,
    bool? hasMore,
    bool? isPaginating,
    bool? isRefreshing,
    String? initialErrorMessage,
    String? paginationErrorMessage,
    bool? simulateError,
    bool clearInitialError = false,
    bool clearPaginationError = false,
  }) {
    return ContactsState(
      status: status ?? this.status,
      contacts: contacts ?? this.contacts,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isPaginating: isPaginating ?? this.isPaginating,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      initialErrorMessage: clearInitialError
          ? null
          : (initialErrorMessage ?? this.initialErrorMessage),
      paginationErrorMessage: clearPaginationError
          ? null
          : (paginationErrorMessage ?? this.paginationErrorMessage),
      simulateError: simulateError ?? this.simulateError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        contacts,
        searchQuery,
        currentPage,
        hasMore,
        isPaginating,
        isRefreshing,
        initialErrorMessage,
        paginationErrorMessage,
        simulateError,
      ];
}
