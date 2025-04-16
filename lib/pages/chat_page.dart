import 'package:chatty/commponents/chat_bubble.dart';
import 'package:chatty/commponents/my_textfiels.dart';
import 'package:chatty/services/auth/auth_services.dart';
import 'package:chatty/services/chat/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  ChatPage({super.key, required this.recrveEmail, required this.receiverId});

  final String recrveEmail;
  final String receiverId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controllerMessage = TextEditingController();

  final ChatService _chatService = ChatService();

  final AuthServices _authServices = AuthServices();

  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(Duration(milliseconds: 500), () => scrollDown());
      }
    });
    Future.delayed(Duration(milliseconds: 500), () => scrollDown());
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    controllerMessage.clear();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  void sendMessage() async {
    if (controllerMessage.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverId, controllerMessage.text);
      controllerMessage.clear();
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: Text(widget.recrveEmail)),
      body: Column(
        children: [Expanded(child: _buildMessageList()), buildUserInput()],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authServices.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverId, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser =
        data['senderID'] == _authServices.getCurrentUser()!.uid;

    var aligment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return Container(
      alignment: aligment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: data["message"],
            isCurrentUser: isCurrentUser,
            messageId: doc.id,
            userId: data['senderID'],
          ),
        ],
      ),
    );
  }

  Widget buildUserInput() {
    return Padding(
      padding: EdgeInsets.only(bottom: 50),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              focusode: myFocusNode,
              hinText: 'send something ...',
              controller: controllerMessage,
              obscureText: false,
            ),
          ),
          IconButton(onPressed: sendMessage, icon: Icon(Icons.send)),
        ],
      ),
    );
  }
}
