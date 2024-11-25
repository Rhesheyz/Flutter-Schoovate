import 'package:flutter/material.dart';
import 'package:test_123/repository/user.dart';

class EditUserScreen extends StatefulWidget {
  final String userId;

  const EditUserScreen({super.key, required this.userId});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final UserRepository userRepository = UserRepository();

  bool isLoading = true;
  bool isSaving = false;
  String selectedRole = 'user'; // Default role
  String selectedIsRoot = '0'; // Default is_root value as a string

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await userRepository.getById(widget.userId);
      setState(() {
        nameController.text = user.name;
        emailController.text = user.email;
        selectedRole = user.role; // Assign role
        selectedIsRoot = user.isRoot; // Assign is_root value as a string
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveUser() async {
    final updatedName = nameController.text.trim();
    final updatedEmail = emailController.text.trim();
    final updatedPassword = passwordController.text.trim();

    if (updatedName.isEmpty || updatedEmail.isEmpty || selectedRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, email, and role are required')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await userRepository.updateUser(
        widget.userId,
        updatedName,
        updatedEmail,
        selectedRole,
        password: updatedPassword.isNotEmpty ? updatedPassword : null,
        isRoot: selectedIsRoot, // Pass the selected is_root value as a string
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user: $e')),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Admin'),
                      ),
                      DropdownMenuItem(
                        value: 'user',
                        child: Text('User'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Role',
                    ),
                  ),
                  // Updated Dropdown for is_root field as string
                  DropdownButtonFormField<String>(
                    value: selectedIsRoot,
                    items: const [
                      DropdownMenuItem(
                        value: '0',
                        child: Text('No (0)'),
                      ),
                      DropdownMenuItem(
                        value: '1',
                        child: Text('Yes (1)'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedIsRoot = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Is Root',
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password (Optional)',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isSaving ? null : _saveUser,
                    child: isSaving
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ),
    );
  }
}
