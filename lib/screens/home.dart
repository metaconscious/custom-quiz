import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Body'),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.go('/topics'),
              icon: const Icon(Icons.list),
            ),
            IconButton(
              onPressed: () => context.go('/history'),
              icon: const Icon(Icons.history),
              tooltip: 'History',
            ),
            const Spacer(),
            IconButton(
              onPressed: () => context.go('/user-info'),
              icon: const Icon(Icons.person),
              tooltip: 'Statistics',
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/new-topic'),
        tooltip: 'Create',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
