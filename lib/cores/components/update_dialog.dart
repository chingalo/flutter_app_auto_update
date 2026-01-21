import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class UpdateDialog extends StatefulWidget {
  final String version;
  final VoidCallback onUpdate;
  final Stream<double>? progressStream;
  final String? releaseNote;

  const UpdateDialog({
    super.key,
    required this.version,
    required this.onUpdate,
    this.progressStream,
    this.releaseNote,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Version (${widget.version}) is available',
        style: const TextStyle().copyWith(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.releaseNote != null &&
                widget.releaseNote!.isNotEmpty) ...[
              const Divider(),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: MarkdownBody(
                    data: widget.releaseNote!,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(fontSize: 14),
                      h1: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      h2: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      h3: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      listBullet: const TextStyle(fontSize: 14),
                      code: TextStyle(
                        backgroundColor: Colors.grey[300],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const Divider(),
            Visibility(
              visible: !_isDownloading,
              child: Text('Would you like to update now?'),
            ),
            if (_isDownloading) ...[
              const SizedBox(height: 20),
              StreamBuilder<double>(
                stream: widget.progressStream,
                builder: (context, snapshot) {
                  final progress = snapshot.data ?? 0.0;
                  return Column(
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color?>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${(progress * 100).toStringAsFixed(0)}%'),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!_isDownloading) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isDownloading = true;
              });
              widget.onUpdate();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Update Now'),
          ),
        ] else
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Downloading...',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ),
      ],
    );
  }
}
