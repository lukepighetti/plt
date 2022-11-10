import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'plt',
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final _nameController = TextEditingController();

  var _name = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitName() {
    setState(() {
      _name = _nameController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Game view
          Placeholder(color: Colors.blue),

          /// Enter your name
          if (_name.isEmpty)
            Center(
              child: SizedBox(
                height: 300,
                width: 400,
                child: Card(
                  elevation: 20,
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(color: Colors.pink, width: 2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Call to action
                        Text(
                          "Choose your name",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),

                        /// Name text field
                        Padding(
                          padding: EdgeInsets.all(25),
                          child: TextField(
                            controller: _nameController,
                            autofocus: true,
                            decoration:
                                InputDecoration(hintText: "Ligma Johnson"),
                          ),
                        ),

                        SizedBox(height: 25),

                        /// Proceed button
                        AnimatedBuilder(
                          animation: _nameController,
                          builder: (context, _) {
                            return ElevatedButton(
                              onPressed: _nameController.text.trim().isEmpty
                                  ? null
                                  : _submitName,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(25),
                                textStyle:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              child: Text("Let's goooo!"),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
