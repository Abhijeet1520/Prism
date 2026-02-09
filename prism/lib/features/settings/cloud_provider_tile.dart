/// Cloud provider configuration tile and download confirmation dialog.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/cloud_provider_service.dart';
import '../../core/ai/model_manager.dart';
import 'settings_shared_widgets.dart';

// ─── Cloud Provider Configuration Tile ───────────────

class CloudProviderTile extends ConsumerStatefulWidget {
  final CloudProviderConfig provider;
  final bool isConfigured;
  final String maskedKey;
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;

  const CloudProviderTile({
    super.key,
    required this.provider,
    required this.isConfigured,
    required this.maskedKey,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
  });

  @override
  ConsumerState<CloudProviderTile> createState() => _CloudProviderTileState();
}

class _CloudProviderTileState extends ConsumerState<CloudProviderTile> {
  bool _expanded = false;
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  String? _testResult;
  bool _testing = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      setState(() => _testResult = 'Please enter an API key first.');
      return;
    }
    setState(() {
      _testing = true;
      _testResult = null;
    });
    final url = _baseUrlController.text.trim().isEmpty
        ? null
        : _baseUrlController.text.trim();
    final (ok, msg) = await ref
        .read(cloudProviderProvider.notifier)
        .validateApiKey(widget.provider.id, key, customBaseUrl: url);
    if (mounted) {
      setState(() {
        _testing = false;
        _testResult = ok ? '✓ $msg' : '✗ $msg';
      });
    }
  }

  Future<void> _saveProvider() async {
    final key = _apiKeyController.text.trim();
    final url = _baseUrlController.text.trim().isEmpty
        ? null
        : _baseUrlController.text.trim();
    await ref
        .read(cloudProviderProvider.notifier)
        .configureProvider(widget.provider.id, apiKey: key, customBaseUrl: url);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.provider.name} configured!'),
        duration: const Duration(seconds: 2),
      ));
      setState(() => _expanded = false);
    }
  }

  Future<void> _removeProvider() async {
    await ref
        .read(cloudProviderProvider.notifier)
        .removeProvider(widget.provider.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.provider.name} removed.'),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: widget.isConfigured
                ? widget.accentColor
                : widget.borderColor,
            width: widget.isConfigured ? 1.5 : 0.5),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.cloud_outlined,
                      size: 18, color: widget.accentColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.provider.name,
                            style: TextStyle(
                                color: widget.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13)),
                        if (widget.provider.description.isNotEmpty)
                          Text(widget.provider.description,
                              style: TextStyle(
                                  color: widget.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                  if (widget.isConfigured)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('connected',
                          style: TextStyle(
                              fontSize: 10, color: Color(0xFF10B981))),
                    ),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 20,
                    color: widget.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          // Expanded config form
          if (_expanded) _buildConfigForm(),
        ],
      ),
    );
  }

  Widget _buildConfigForm() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: widget.borderColor, height: 1),
          const SizedBox(height: 12),
          _buildTextField('Base URL', _baseUrlController,
              hint: widget.provider.baseUrl.isNotEmpty
                  ? widget.provider.baseUrl
                  : 'https://api.example.com/v1'),
          const SizedBox(height: 10),
          _buildTextField('API Key', _apiKeyController,
              hint: widget.isConfigured ? widget.maskedKey : 'sk-xxxxxxxxxx',
              obscure: true),
          const SizedBox(height: 12),
          if (_testResult != null) _buildTestResult(),
          Row(
            children: [
              SmallButton(
                label: _testing ? 'Testing…' : 'Test Connection',
                color: widget.textSecondary,
                onTap: _testing ? () {} : _testConnection,
              ),
              const SizedBox(width: 8),
              SmallButton(
                label: 'Save',
                color: widget.accentColor,
                onTap: _saveProvider,
              ),
              if (widget.isConfigured) ...[
                const SizedBox(width: 8),
                SmallButton(
                  label: 'Remove',
                  color: const Color(0xFFEF4444),
                  onTap: _removeProvider,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {String hint = '', bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: widget.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        SizedBox(
          height: 34,
          child: TextField(
            controller: controller,
            style: TextStyle(color: widget.textPrimary, fontSize: 12),
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  color: widget.textSecondary.withValues(alpha: 0.5),
                  fontSize: 12),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              filled: true,
              fillColor: widget.borderColor.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: widget.borderColor, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: widget.borderColor, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: widget.accentColor, width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestResult() {
    final isOk = _testResult!.startsWith('✓');
    final color = isOk ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(_testResult!, style: TextStyle(color: color, fontSize: 11)),
    );
  }
}

// ─── Download Confirmation Dialog ────────────────────

void showDownloadConfirmation(
    BuildContext context, WidgetRef ref, ModelCatalogEntry entry) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgColor = isDark ? const Color(0xFF16162A) : Colors.white;
  final textPrimary =
      isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
  final textSecondary =
      isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);
  final borderColor =
      isDark ? const Color(0xFF252540) : const Color(0xFFE2E2EC);
  final accentColor = Theme.of(context).colorScheme.primary;
  final hasToken = ref.read(modelManagerProvider).hasToken;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.download_rounded, size: 22, color: accentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Download Model',
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModelInfoCard(
              entry: entry,
              accentColor: accentColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 12),
            _SourceInfo(
              entry: entry,
              borderColor: borderColor,
              textSecondary: textSecondary,
              parentContext: context,
            ),
            const SizedBox(height: 12),
            if (entry.requiresAuth && !hasToken)
              _AuthWarning(),
            Row(
              children: [
                Icon(Icons.storage_rounded, size: 14, color: textSecondary),
                const SizedBox(width: 6),
                Text('Requires ${entry.sizeLabel} free storage',
                    style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text('Cancel',
              style: TextStyle(color: textSecondary, fontSize: 13)),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: accentColor),
          onPressed: () {
            Navigator.of(ctx).pop();
            ref.read(modelManagerProvider.notifier).downloadModel(entry);
          },
          icon: const Icon(Icons.download_rounded, size: 16),
          label: Text('Download ${entry.sizeLabel}',
              style: const TextStyle(fontSize: 13)),
        ),
      ],
    ),
  );
}

// ─── Small helper widgets ────────────────────────────

class _ModelInfoCard extends StatelessWidget {
  final ModelCatalogEntry entry;
  final Color accentColor, textPrimary, textSecondary;
  const _ModelInfoCard(
      {required this.entry,
      required this.accentColor,
      required this.textPrimary,
      required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: accentColor.withValues(alpha: 0.15), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.name,
              style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
          const SizedBox(height: 6),
          Text(entry.description,
              style: TextStyle(color: textSecondary, fontSize: 12)),
          const SizedBox(height: 10),
          DetailRow(label: 'Size', value: entry.sizeLabel, color: textSecondary),
          DetailRow(
              label: 'Context',
              value: '${entry.contextWindow ~/ 1024}K tokens',
              color: textSecondary),
          DetailRow(
              label: 'Category', value: entry.category, color: textSecondary),
          DetailRow(
              label: 'Format', value: 'GGUF Q4_K_M', color: textSecondary),
          if (entry.supportsVision)
            DetailRow(label: 'Vision', value: 'Yes', color: textSecondary),
        ],
      ),
    );
  }
}

class _SourceInfo extends StatelessWidget {
  final ModelCatalogEntry entry;
  final Color borderColor, textSecondary;
  final BuildContext parentContext;
  const _SourceInfo(
      {required this.entry,
      required this.borderColor,
      required this.textSecondary,
      required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: borderColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.link_rounded, size: 14, color: textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(entry.repo,
                style: TextStyle(color: textSecondary, fontSize: 11),
                overflow: TextOverflow.ellipsis),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: entry.repoUrl));
              ScaffoldMessenger.of(parentContext).showSnackBar(
                const SnackBar(
                  content: Text('URL copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child:
                Icon(Icons.copy_rounded, size: 14, color: textSecondary),
          ),
        ],
      ),
    );
  }
}

class _AuthWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
            width: 0.5),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 16, color: Color(0xFFF59E0B)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'This model may require a HuggingFace token. Set your token first if download fails.',
              style: TextStyle(color: Color(0xFFF59E0B), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const DetailRow(
      {super.key,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w500)),
          ),
          Text(value, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
