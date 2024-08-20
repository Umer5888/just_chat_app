import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> contacts = [];
  bool isLoading = true;
  GlobalKey<FormState> key = GlobalKey();

  @override
  void initState() {
    super.initState();
    contactPermission();
  }

  void contactPermission() async {

    if (await Permission.contacts.isGranted) {
      fetchContacts();
    } else {
      PermissionStatus status = await Permission.contacts.request();
      if (status.isGranted) {
        fetchContacts();
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacts permission is required to display contacts.')),
        );
      }
    }
  }

  void fetchContacts() async {
    contacts = await ContactsService.getContacts(orderByGivenName: false);
    setState(() {
      // Reversing the list to show the latest added contact at the top
      contacts = contacts.reversed.toList();
      isLoading = false;
    });
  }

  void addContact(Contact contact) async {
    await ContactsService.addContact(contact);
    setState(() {
      // Add the new contact to the top of the list
      contacts.insert(0, contact);
    });
  }

  void deleteContact(Contact contact) async {
    await ContactsService.deleteContact(contact);
    setState(() {
      // Remove the contact from the list
      contacts.remove(contact);
    });
  }

  void showAddContactDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('Add New Contact',
          style: TextStyle(
            fontSize: 26
          ),)),
          content: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green)),
                    errorMaxLines: 1,
                    errorStyle: TextStyle(
                      height: 0.5,
                    ),
                  ),
                  validator: ValidationBuilder().build(),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    // constraints: BoxConstraints(
                    //   maxHeight: 45,
                    // ),
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: ValidationBuilder().phone().minLength(11).maxLength(11).build(),
                ),

              ],
            ),
          ),
          actions: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    )
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel',
                  style: TextStyle(
                    color: Colors.white,
                  ),),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    )
                ),
                onPressed: () {
                  if (key.currentState?.validate() ?? false) {
                  if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                    Contact newContact = Contact(
                      givenName: nameController.text,
                      displayName: nameController.text,
                      phones: [Item(label: 'mobile',
                          value: phoneController.text)
                      ],
                    );

                    addContact(newContact);
                    Navigator.of(context).pop();
                  }
                  }
                },
                child: const Text('Add    ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Your Contacts',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
              onPressed: showAddContactDialog,
              icon: const Icon(Icons.add, color: Colors.white,),
            ),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: contacts.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  textAlign: TextAlign.center,
                  contacts[index].givenName?.substring(0, 1) ?? 'X',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            title: Text(
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              contacts[index].displayName ?? 'No Name',
            ),
            subtitle: Text(
              contacts[index].phones?.isNotEmpty == true
                  ? contacts[index].phones!.first.value ?? ''
                  : 'No Number',
            ),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Invite'),
                Icon(Icons.keyboard_arrow_right),
              ],
            ),
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Delete Contact'),
                    content: const Text('Are you sure you want to delete this contact?'),
                    actions: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)
                              )
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel',
                            style: TextStyle(
                              color: Colors.white,
                            ),),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)
                              )
                          ),
                          onPressed: () {
                            deleteContact(contacts[index]);
                            Navigator.of(context).pop();
                          },
                          child: const Text('Delete',
                            style: TextStyle(
                              color: Colors.white,
                            ),),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
