import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crazy_todo/app_login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.user}) : super(key: key);
  final User? user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  TextEditingController _controller = TextEditingController(text: "New task");

  void setData(String note) {
    final notes = db.collection("notes");
    final data = <String, dynamic>{
      "value": note,
      "done": false,
      "savedAt": Timestamp.now()
    };
    notes.add(data);
    FocusScope.of(context).unfocus();
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ToDo"),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
            icon: Icon(Icons.settings),
          )
        ],
      ),
      body: Column(children: [
        Expanded(child: MyReads()),
        Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => setData(_controller.text),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 0.0),
              ),
            ),
          ),
        )
      ]),
    );
  }
}

class MyReads extends StatefulWidget {
  const MyReads({Key? key}) : super(key: key);

  @override
  State<MyReads> createState() => _MyReadsState();
}

class _MyReadsState extends State<MyReads> {
  final Stream<QuerySnapshot> _stream =
      FirebaseFirestore.instance.collection("notes").snapshots();

  FirebaseFirestore db = FirebaseFirestore.instance;

  void updateData(docId, done) {
    final note = db.collection("notes").doc(docId);
    note.update({'done': done});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong!!!");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return ListView(
              children: snapshot.data!.docs
                  .map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    DateTime dt = (data['savedAt'] as Timestamp).toDate();
                    var output = DateFormat('dd/MMM, HH:mm').format(dt);
                    var nana = ListTile(
                      title: Text(data["value"]),
                      // subtitle: Text(data['done'].toString()),
                      subtitle: Text(output.toString()),
                      leading: Checkbox(
                        value: data['done'],
                        onChanged: (value) {
                          updateData(document.id, value);
                        },
                      ),
                    );

                    return nana;
                  })
                  .toList()
                  .cast());
        });
  }
}
