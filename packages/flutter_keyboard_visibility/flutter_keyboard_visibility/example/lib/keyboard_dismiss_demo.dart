import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class KeyboardDismissDemo extends StatelessWidget {
  const KeyboardDismissDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keyboard Dismiss Demo'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              KeyboardDismissOnTap(
                child: Container(
                  height: 80,
                  width: double.infinity,
                  color: Colors.red,
                  child: Center(child: Text('Red dismisses on tap')),
                ),
              ),
              KeyboardDismissOnTap(
                child: Container(
                  height: 80,
                  width: double.infinity,
                  color: Colors.blue,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Button does not dismiss, blue does'),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Button'),
                      ),
                    ],
                  ),
                ),
              ),
              KeyboardDismissOnTap(
                dismissOnCapturedTaps: true,
                child: Container(
                  height: 80,
                  width: double.infinity,
                  color: Colors.green,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Button and green both dismiss'),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Button'),
                      ),
                    ],
                  ),
                ),
              ),
              KeyboardDismissOnTap(
                child: Container(
                  height: 80,
                  width: double.infinity,
                  color: Colors.orange,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Orange dismisses, black does not'),
                      IgnoreKeyboardDismiss(
                        child: Container(
                          margin: EdgeInsets.only(top: 4),
                          height: 40,
                          width: 40,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Input box for keyboard test',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
