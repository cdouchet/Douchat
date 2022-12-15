import 'package:douchat3/main.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/group_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class GroupService {
  final Socket socket;

  GroupService({required this.socket});

  void sendNewGroup(dynamic data) {
    socket.emit('new-group', data);
  }

  void sendMessage(dynamic data) {
    socket.emit('group-message', data);
  }

  void sendTypingEvent(dynamic data) {
    socket.emit('group-typing', data);
  }

  void removeMessage(dynamic data) {
    socket.emit('remove-group-message', data);
  }

  void addReaction(dynamic data) {
    socket.emit('add-group-reaction', data);
  }

  void removeReaction(dynamic data) {
    socket.emit('remove-group-reaction', data);
  }

  void sendAllReceipts(
      {required List<String> messages,
      required String groupId,
      required String userId}) {
    socket.emit('group-receipts',
        {'messages': messages, 'group': groupId, 'userId': userId});
  }

  void updateMessageReceipt(dynamic data) {
    final BuildContext context = globalKey.currentContext!;
    final client = Provider.of<ClientProvider>(context, listen: false).client;
    if (client.id != data['from']) {
      Provider.of<GroupProvider>(context, listen: false).updateReadState(
          messagesToUpdate: [data['id']],
          groupId: data['group'],
          readBy: client.id,
          notify: true);
      sendAllReceipts(
          messages: [data['id']], groupId: data['group'], userId: client.id);
    }
  }

  void subscribeToReceipts() {
    socket.on('group-message', updateMessageReceipt);
  }

  void cancelSubscriptionToReceipts() {
    socket.off('group-message', updateMessageReceipt);
  }

  void changeGroupName({required String name, required String id}) {
    socket.emit('group-name-update', {
      'name': name,
      'group': id,
      'timestamp': DateFormat().format(DateTime.now())
    });
  }

  void changeGroupPhoto({required String url, required String id}) {
    socket.emit('group-photo-update', {
      'url': url,
      'group': id,
      'timestamp': DateFormat().format(DateTime.now())
    });
  }

  void changeGroupAdmin({required String admin, required String id}) {
    socket.emit('group-admin-update', {
      'admin': admin,
      'group': id,
      'timestamp': DateFormat().format(DateTime.now())
    });
  }

  void removeGroupUser({required String userId, required String id}) {
    socket.emit('group-user-removal', {
      'userId': userId,
      'group': id,
      'timestamp': DateFormat().format(DateTime.now())
    });
  }

  void addGroupUser({required String userId, required String id}) {
    socket.emit('group-user-addition', {
      'userId': userId,
      'group': id,
      'timestamp': DateFormat().format(DateTime.now())
    });
  }

  void leaveGroup({required String clientId, required String id}) {
    socket.emit('leave-group', {
      'clientId': clientId,
      'group': id,
      'timestamp': DateFormat().format(DateTime.now())
    });
  }
}
