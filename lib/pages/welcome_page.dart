import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _surname;
  int? _age;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Here you can process the data, e.g., send it to a server or save locally
      print('Name: $_name, Surname: $_surname, Age: $_age');
      // Navigate to the next screen or show a confirmation dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("We're almost there!"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Surname'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your surname';
                  }
                  return null;
                },
                onSaved: (value) => _surname = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
                onSaved: (value) => _age = int.parse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Submit'),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
