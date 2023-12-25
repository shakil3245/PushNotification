import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:push_notification/pushNotification/controller/massageController.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MassageControlller _massageControlller = MassageControlller();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _massageControlller.requestMassagePermission();
    _massageControlller.getToken();
    _massageControlller.initInfo();
  }

  TextEditingController _nameController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _bodyController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Notification"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                    hintText: "Name",
                    labelText: "User name",
                    border: OutlineInputBorder()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                    hintText: "Title",
                    labelText: "Ttile text",
                    border: OutlineInputBorder()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _bodyController,
                decoration: InputDecoration(
                    hintText: "Body text",
                    labelText: "Body text",
                    border: OutlineInputBorder()),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: ()async {

                      //THIS ALL CODE HELPS TO SEND NOTIFICATION TO A SPECIFIC USER
                      String name = _nameController.text.trim();
                      String tileText = _titleController.text;
                      String bodyText = _bodyController.text;
                      //WE GET USER DEVICE TOKEN FROM THIS PORSTION
                      if(name != null){
                        DocumentSnapshot snap = await FirebaseFirestore.instance.collection('UserTokens').doc(name).get();
                        //WE SAVE IS HERE
                        String token= snap['token'];
                        print(token);
                        _massageControlller.sendPushMessage(token,bodyText, tileText);
                      }
                    },
                    child: Text("Submit")))
          ],
        ),
      ),
    );
  }
}
