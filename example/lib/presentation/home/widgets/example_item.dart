import 'package:flutter/material.dart';

class HomeScreenExampleItem extends StatelessWidget {
  const HomeScreenExampleItem({
    required this.title,
    required this.icon,
    required this.text,
    required this.onPressed,
    super.key,
  });
  final String title;
  final Widget icon;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: GestureDetector(
            onTap: onPressed,
            child: Card(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    icon,
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        text,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
