import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:the_yagi_project/models/contacts.dart';

class ContactsPage extends StatefulWidget {

  ContactsPage({Key key, this.title}) : super(key: key) {
    print("BATMAN");
  }

  final String title;

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  Box<EmergencyContact> emergencyContacts;
  List<Contact> contacts = [];
  Map<String, Color> contactsColorMap = new Map();


  @override
  void initState() {
    super.initState();
    getContacts();
  }
  getContacts() async {
    if (await Permission.contacts.request().isGranted) {
      await getAllContacts();
    }
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  getAllContacts() async {
    List colors = [
      Colors.green,
      Colors.indigo,
      Colors.yellow,
      Colors.orange
    ];
    int colorIndex = 0;
    List<Contact> _contacts = (await ContactsService.getContacts()).toList();
    _contacts.forEach((contact) {
      Color baseColor = colors[colorIndex];
      contactsColorMap[contact.displayName] = baseColor;
      colorIndex++;
      if (colorIndex == colors.length) {
        colorIndex = 0;
      }
    });
    _contacts.removeWhere((contact) => contact.phones.length == 0);
    setState(() {
      contacts = _contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    emergencyContacts = Hive.box<EmergencyContact>('emergency');
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Text(
              'Emergency Contact',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Container( // This container for Emergency Contacts
              height: (MediaQuery.of(context).size.height) / 2,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: emergencyContacts.length,
                itemBuilder: (context, index) {
/*
 Will be used when avatars are added to emergency list
                Contact contact = isSearching == true
                    ? emergencyContact[index]
                    : contacts[index];

                var baseColor = contactsColorMap[contact
                    .displayName] as dynamic;

                Color color1 = baseColor[800];
                Color color2 = baseColor[400];

 */
                  if (emergencyContacts.length == 0) {
                    return null;
                  }
                  else {
                    return ListTile(
                      title: Text(emergencyContacts.getAt(index).name),
                      subtitle: Text(
                          emergencyContacts.getAt(index).number
                      ),
                    );
                  }
                },
              ),
            ),
            Divider(
                color: Colors.grey
            ),
            Text(
                'Contacts',
                style: (TextStyle(fontWeight: FontWeight.bold, fontSize:20))
            ),
            Expanded( // This container for full contacts list.
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  Contact contact = contacts[index];
                  var baseColor = contactsColorMap[contact.displayName] as dynamic;

                  Color color1 = baseColor[800];
                  Color color2 = baseColor[400];

                  bool alreadySaved = emergencyContacts.get(contact.displayName) != null;
                  var avatarProfile = contact.avatar != null && contact.avatar.length > 0;
                  return ListTile(
                      title: Text(contact.displayName),
                      subtitle: Text(
                          contact.phones.length > 0 ? contact.phones.elementAt(0).value : ''
                      ),
                      trailing: (
                          Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                    alreadySaved ? Icons.favorite : Icons.favorite_border,
                                    color: alreadySaved ? Colors.red : null
                                ),
                                avatarProfile?
                                CircleAvatar(
                                  backgroundImage: MemoryImage(contact.avatar),
                                ) :
                                Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        gradient: LinearGradient(
                                            colors: [
                                              color1,
                                              color2,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight
                                        )
                                    ),
                                    child: CircleAvatar(
                                        child: Text(
                                            contact.initials(),
                                            style: TextStyle(
                                                color: Colors.white
                                            )
                                        ),
                                        backgroundColor: Colors.transparent
                                    )
                                )
                              ])
                      ),
                      onTap: () {
                        setState(() {
                          if(alreadySaved) {
                            emergencyContacts.delete(
                              contact.displayName);
                          }
                          else{
                            emergencyContacts.put(
                              contact.displayName,
                              EmergencyContact(
                                  name: contact.displayName,
                                  number: contact.phones.elementAt(0).value
                              )
                            );
                          }
                        });
                      }
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}