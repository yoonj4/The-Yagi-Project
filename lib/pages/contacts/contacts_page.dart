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
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
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
      searchController.addListener(() {
        filterContacts();
      });
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

  filterContacts() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = contact.displayName.toLowerCase();
        bool nameMatches = contactName.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        var phone = contact.phones.firstWhere((phn) {
          String phnFlattened = flattenPhoneNumber(phn.value);
          return phnFlattened.contains(searchTermFlatten);
        }, orElse: () => null);

        return phone != null;
      });
    }
    setState(() {
      contactsFiltered = _contacts;
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
            Container(
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
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: isSearching == true ? contactsFiltered.length : contacts.length,
                itemBuilder: (context, index) {
                  Contact contact = isSearching == true ? contactsFiltered[index] : contacts[index];

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
                          }
                          else{
                            emergencyContact.add(contact);
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