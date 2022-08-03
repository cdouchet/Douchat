import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> setProviders(BuildContext context,
    {required User user, required List<User> users}) async {
  Provider.of<ClientProvider>(context, listen: false).setClient(user);
  Provider.of<UserProvider>(context, listen: false).setUsers(users);
}
