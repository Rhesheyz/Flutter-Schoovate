import 'package:flutter/material.dart';
import 'package:test_123/repository/user.dart';
import 'package:test_123/models/user.dart';
import 'userCreate.dart';
import 'userEdit.dart'; // Pastikan ini mengarah ke layar edit pengguna yang tepat

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UserScreen> {
  late Future<List<User>> futureUsers;
  final UserRepository userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() {
    setState(() {
      futureUsers = userRepository.fetchUsers();
    });
  }

  // Fungsi untuk menghapus pengguna berdasarkan ID
  Future<void> _deleteUser(String userId) async {
    try {
      await userRepository.deleteUser(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
      _fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user: $e')),
      );
    }
  }

  // Fungsi untuk navigasi ke layar tambah pengguna
  Future<void> _navigateToAddUserScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddUserScreen()),
    );

    if (result == true) {
      _fetchUsers();
    }
  }

  // Fungsi untuk navigasi ke layar edit pengguna
  Future<void> _navigateToEditUserScreen(String userId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserScreen(userId: userId),
      ),
    );

    if (result == true) {
      _fetchUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: FutureBuilder<List<User>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol Edit
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navigateToEditUserScreen(user.id),
                      ),
                      // Tombol Delete
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(user.id),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddUserScreen,
        tooltip: 'Add User',
        child: const Icon(Icons.add),
      ),
    );
  }
}
