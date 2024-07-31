import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../main.dart';
import 'SignIn.dart';

class HomePage extends StatefulWidget {
  final String lastName;

  const HomePage({Key? key, required this.lastName}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Contact> _contacts = [];
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  Future<void> _getContacts() async {
    if (await Permission.contacts.request().isGranted) {
      final contacts = await ContactsService.getContacts();
      setState(() {
        _contacts = contacts;
      });
    }
  }

  Future<void> _addContact() async {
    final newContact = Contact(
      givenName: _nameController.text,
      phones: [Item(value: _phoneController.text)],
    );

    await ContactsService.addContact(newContact);
    _nameController.clear();
    _phoneController.clear();
    _getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.lastName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MyApp()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
          ),
          ElevatedButton(
            onPressed: _addContact,
            child: Text('Add Contact'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return ListTile(
                  title: Text(contact.displayName ?? ''),
                  subtitle: Text(contact.phones?.first.value ?? ''),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}