import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void addContact(BuildContext context, {required String number}) {
  context.go('/addContactScreen', extra: number);
  print('Add contact $number button pressed');
}