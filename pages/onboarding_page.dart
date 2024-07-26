import 'package:agriclink/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/agriculture.jpg', // Path to your background image
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Image.asset('assets/onboarding.png'),
                  ),
                  const Spacer(),
                  Text(
                    'Welcome to AgricLink',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 30),
                    child: Text(
                      "Get your agriculture products from the comfort of your chair. You're just a few clicks away from your favorite products.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(CupertinoPageRoute(
                          builder: (context) => const HomePage()));
                    },
                    icon: const Icon(IconlyLight.login),
                    label: const Text("Continue"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
