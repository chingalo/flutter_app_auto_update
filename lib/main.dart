import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'cores/services/update_service.dart';
import 'cores/components/update_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Update Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Auto Update Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final UpdateService _updateService = UpdateService();

  @override
  void initState() {
    super.initState();
    // Check for updates after the first frame is rendered (Android only)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.isAndroid) {
        _checkForUpdates();
      }
    });
  }

  Future<void> _checkForUpdates() async {
    final updateInfo = await _updateService.checkUpdate();
    if (updateInfo != null && mounted) {
      final String version = updateInfo['version'];
      final String apkUrl = updateInfo['apk_url'];

      final progressController = StreamController<double>();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => UpdateDialog(
          version: version,
          progressStream: progressController.stream,
          onUpdate: () async {
            final filePath = await _updateService.downloadAPK(apkUrl, (
              received,
              total,
            ) {
              if (total != -1) {
                progressController.add(received / total);
              }
            });

            if (filePath != null) {
              await _updateService.installAPK(filePath);
              if (mounted) Navigator.of(context).pop();
            } else {
              // Handle error (e.g., show a toast or another dialog)
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to download update')),
                );
                Navigator.of(context).pop();
              }
            }
            progressController.close();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 64,
              color: Colors.deepPurple,
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to Auto Update Demo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Checking for updates automatically...'),
          ],
        ),
      ),
    );
  }
}
