import 'package:equatable/equatable.dart';
import 'contact_entity.dart';

class ContactsPageEntity extends Equatable {
  final List<ContactEntity> contacts;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  const ContactsPageEntity({
    required this.contacts,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [contacts, page, limit, total, hasMore];
}
