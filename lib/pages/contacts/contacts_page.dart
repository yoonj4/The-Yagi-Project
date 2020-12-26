import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:the_yagi_project/models/contacts.dart';
import 'dart:typed_data';

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
  final  ScrollController _scrollEmergency = ScrollController();
  final  ScrollController _scrollContacts = ScrollController();

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
              'Emergency Contacts',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Expanded( // Emergency Contacts only
              child: Scrollbar(
                isAlwaysShown: true,
                controller: _scrollEmergency,
                child: ListView.builder(
                  controller: _scrollEmergency,
                  shrinkWrap: true,
                  itemCount: emergencyContacts.length,
                  itemBuilder: (context, index) {
                    if (emergencyContacts.length == 0) {
                      return null;
                    }
                    else {
                      var emergencyContact = emergencyContacts.getAt(index);

                      return ListTile(
                          title: Text(emergencyContact.name),
                          subtitle: Text(emergencyContact.number),
                          leading: _createLeadingAvatarEmergency(emergencyContact, contactsColorMap),
                          trailing: IconButton(
                            icon:Icon(Icons.backspace),
                            onPressed: () {
                              setState(() {
                                emergencyContacts.delete(emergencyContacts.getAt(index).name);
                              });
                            },
                          ),
                      );
                    }
                  },
                ),
              )
            ),
            Divider(
                color: Colors.grey
            ),
            Text(
                'Contacts',
                style: (TextStyle(fontWeight: FontWeight.bold, fontSize:20))
            ),
            Expanded( // Full Contacts List
              child: Scrollbar(
                isAlwaysShown: true,
                controller: _scrollContacts,
                child: ListView.builder(
                  controller: _scrollContacts,
                  shrinkWrap: true,
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    Contact contact = contacts[index];
                    bool alreadySaved = emergencyContacts.get(contact.displayName) != null;

                    return ListTile(
                        title: Text(contact.displayName),
                        subtitle: Text(
                            contact.phones.length > 0 ? contact.phones.elementAt(0).value : ''
                        ),
                        leading: _createLeadingAvatar(contact, contactsColorMap),
                        trailing: IconButton(
                          icon:Icon(alreadySaved ? Icons.favorite : Icons.favorite_border,
                                      color: alreadySaved ? Colors.red : null),
                          onPressed: () {
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
                                        number: contact.phones.elementAt(0).value,
                                        avatar: contact.avatar,
                                        initials: contact.initials()
                                    )
                                );
                              }
                            });
                          },
                        ),
                        onTap: () { print('THIS COULD BE SOME EXTRA BEHAVIOR'); }
                    );
                  },
                ),
              )

            )
          ],
        ),
      ),
    );
  }
}

Widget _createLeadingAvatar(Contact contact, Map<String, Color> contactsColorMap) {
  return _createLeadingAvatarHelper(contact.displayName, contactsColorMap, contact.avatar, contact.initials());
}

Widget _createLeadingAvatarEmergency(EmergencyContact contact, Map<String, Color> contactsColorMap) {
  return _createLeadingAvatarHelper(contact.name, contactsColorMap, contact.avatar, contact.initials);
}

Widget _createLeadingAvatarHelper(String name, Map<String, Color> contactsColorMap, Uint8List avatar, String initials) {
  var baseColor = contactsColorMap[name] as dynamic;

  Color color1 = baseColor[800];
  Color color2 = baseColor[400];

  var avatarProfile = avatar != null && avatar.length > 0;

  if (avatarProfile) {
    return CircleAvatar(backgroundImage: MemoryImage(avatar));
  }
  else {
    return Container(
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
                initials,
                style: TextStyle(
                    color: Colors.white
                )
            ),
            backgroundColor: Colors.transparent
        )
    );
  }
}