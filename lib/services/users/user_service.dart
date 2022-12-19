import 'dart:convert';

import 'package:douchat3/api/api.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class UserService {
  final Socket socket;

  UserService(this.socket);

  void sendCreatedUser(User user) {
    socket.emit('user-created', {'user': user.toJson()});
  }

  void sendAddedUser({required User user, required String userId}) {
    socket.emit('user-added', {'to': userId, 'user': user.toJson()});
  }

  void changeUsername(
      {required BuildContext context, required String username}) {
    Api.doUsernameExists(username).then((response) {
      final usernameAlreadyExists = jsonDecode(response.body)['payload'];
      if (usernameAlreadyExists) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$username est déjà utilisé')));
      } else {
        socket.emit('change-username',
            {'id': _getClientId(context), 'username': username});
        Provider.of<ClientProvider>(context, listen: false)
            .changeUsername(username);
      }
    });
  }

  

  void changePhotoUrl(
      {required BuildContext context, required String photoUrl}) {
    socket.emit(
        'change-photoUrl', {'id': _getClientId(context), 'photoUrl': photoUrl});
    Provider.of<ClientProvider>(context, listen: false)
        .changePhotoUrl(photoUrl);
  }

  _getClientId(BuildContext context) =>
      Provider.of<ClientProvider>(context, listen: false).client.id;

  void sendFriendRequest({required dynamic data}) {
    socket.emit('friend-request', data);
  }

  void respondToFriendRequest({required dynamic data}) {
    socket.emit('friend-request-response', data);
  }

  void removeContact({required dynamic data}) {
    socket.emit("remove-contact", data);
  }
}
