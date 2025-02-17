import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class ProviderDemo extends StatelessWidget {
  ProviderDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityProvider(
      child: MyDemoPage(),
    );
  }
}

class MyDemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keyboard Visibility Provider'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('This demo uses KeyboardVisibilityProvider.'),
              Container(height: 60.0),
              TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Input box for keyboard test',
                ),
              ),
              Container(height: 60.0),
              Text(
                'The keyboard is: ${KeyboardVisibilityProvider.isKeyboardVisible(context) ? 'VISIBLE' : 'NOT VISIBLE'}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
