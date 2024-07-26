import 'package:flutter/material.dart';
import 'package:agriclink/widgets/profile_content.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const ProfileContent(),
    );
  }
}
