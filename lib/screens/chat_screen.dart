import 'package:chatting/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var controller = TextEditingController();
  final auth = FirebaseAuth.instance;
  late User loggedinuser;
  final cloud = FirebaseFirestore.instance;
  late String text;

  void getdatabyget() async {
    var data = await cloud.collection('messages').get();
    print(data.docs.map((doc) => doc.data()).toList());
  }

  void getdatabysnapshotdemo() async {
    await for (var data in cloud.collection('messages').snapshots()) {
      for (var message in data.docs) print(message.data());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      getuser();
    });
  }

  void getuser() async {
    try {
      final user = await auth.currentUser;
      if (user != null) {
        loggedinuser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: cloud.collection('messages').snapshots(),
              builder: (context, snapshot) {
                List<Widget> list = [];
                if (snapshot.hasData) {
                  final msg = snapshot.data!.docs.reversed;
                  for (var msgs in msg) {
                    var sender = msgs['sender'];
                    var text = msgs['text'];
                    list.add(msgBubble(
                        sender: sender,
                        msg: text,
                        sameuser: sender == loggedinuser.email ? true : false));
                  }
                  return Expanded(
                    child: ListView(
                      reverse: true,
                      children: list,
                    ),
                  );
                } else {
                  CircularProgressIndicator(
                    color: Colors.red,
                  );
                }
                return Container();
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: (value) {
                        setState(() {
                          text = value;
                        });
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.clear();
                      cloud.collection('messages').add({
                        'text': text,
                        'sender': loggedinuser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class msgBubble extends StatelessWidget {
  msgBubble({required this.sender, required this.msg, required this.sameuser});

  String sender, msg;
  bool sameuser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            sameuser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
            ),
          ),
          Material(
            borderRadius: sameuser
                ? BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0))
                : BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0)),
            color: sameuser ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                msg,
                style: TextStyle(
                  fontSize: 20,
                  color: sameuser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
