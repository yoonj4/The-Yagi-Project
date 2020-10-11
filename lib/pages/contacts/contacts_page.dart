import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsPage extends StatefulWidget {

  ContactsPage({Key key, this.title}) : super(key: key) {
    print("BATMAN");
  }

  final String title;

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  var emergencyContact = await Hive.openBox<Event>('emergency')
  List<Contact> contacts = [];
  List<Contact> emergencyContact = [];
  Map<String, Color> contactsColorMap = new Map();
  TextEditingController searchController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getPermissions();
  }
  getPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      getAllContacts();
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
    setState(() {
      contacts = _contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
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
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: emergencyContact.length,
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
                  if (emergencyContact.length == 0) {
                    return null;
                  }
                  else {
                    return ListTile(
                      title: Text(emergencyContact[index].displayName),
                      subtitle: Text(
                          emergencyContact[index].phones.length > 0 ? emergencyContact[index].phones
                              .elementAt(0)
                              .value : ''
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
                  var baseColor = contactsColorMap[contact.displayName] as dynamic;

                  Color color1 = baseColor[800];
                  Color color2 = baseColor[400];

                  var alreadySaved = emergencyContact.contains(contact);
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
                            emergencyContact.remove(contact);

                            emergencyContact.delete(
                              EmergencyContact(
                                name: contact.displayName.toLowerCase(),
                                number: contact.
                              )
                            )
                          }
                          else{
                            emergencyContact.add(contact);

                            await emergencyContact.delete(
                                EmergencyContact(
                                name: contact.displayName.toLowerCase(),
                                number: contact.phn
                                )
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