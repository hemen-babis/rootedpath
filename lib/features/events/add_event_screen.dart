import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _startDate;

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate() || _startDate == null) return;

    try {
      await FirebaseFirestore.instance.collection('events').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'location': _locationController.text.trim(),
        'start': _startDate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving event: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Event")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (value) =>
                value!.isEmpty ? "Please enter a title" : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Location"),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    _startDate == null
                        ? "Select Date"
                        : "${_startDate!.toLocal()}".split(' ')[0],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _startDate = picked);
                      }
                    },
                    child: const Text("Pick Date"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEvent,
                child: const Text("Save Event"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
