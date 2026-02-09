/// Cloud provider configuration tile and download confirmation dialog.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
          // Portal links
          if (widget.provider.signupUrl.isNotEmpty || widget.provider.docsUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  if (widget.provider.signupUrl.isNotEmpty)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => launchUrl(Uri.parse(widget.provider.signupUrl)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: widget.accentColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: widget.accentColor.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.key_rounded, size: 14, color: widget.accentColor),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text('Get API Key',
                                    style: TextStyle(
                                        color: widget.accentColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.open_in_new, size: 11, color: widget.accentColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (widget.provider.signupUrl.isNotEmpty && widget.provider.docsUrl.isNotEmpty)
                    const SizedBox(width: 8),
                  if (widget.provider.docsUrl.isNotEmpty)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => launchUrl(Uri.parse(widget.provider.docsUrl)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: widget.textSecondary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: widget.borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.menu_book_rounded, size: 14, color: widget.textSecondary),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text('API Docs',
                                    style: TextStyle(
                                        color: widget.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.open_in_new, size: 11, color: widget.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // Available models list
          if (widget.provider.models.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available Models',
                      style: TextStyle(
                          color: widget.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: widget.provider.models.map((m) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.borderColor.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(m.name,
                            style: TextStyle(
                                color: widget.textPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          // Browse & Select Models button (for providers with model API)
          if (widget.isConfigured &&
              widget.provider.id == 'openrouter')
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BrowseModelsButton(
                provider: widget.provider,
                accentColor: widget.accentColor,
                textSecondary: widget.textSecondary,
                borderColor: widget.borderColor,
              ),
            ),
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

// ─── Browse & Select Models Button ───────────────────

class _BrowseModelsButton extends ConsumerWidget {
  final CloudProviderConfig provider;
  final Color accentColor;
  final Color textSecondary;
  final Color borderColor;

  const _BrowseModelsButton({
    required this.provider,
    required this.accentColor,
    required this.textSecondary,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudState = ref.watch(cloudProviderProvider);
    final isFetching = cloudState.fetchingModels[provider.id] ?? false;

    return GestureDetector(
      onTap: isFetching
          ? null
          : () => _showModelSelectionDialog(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isFetching)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: accentColor),
              )
            else
              Icon(Icons.model_training_rounded,
                  size: 16, color: accentColor),
            const SizedBox(width: 8),
            Text(
              isFetching ? 'Loading models…' : 'Browse & Select Models',
              style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showModelSelectionDialog(
      BuildContext context, WidgetRef ref) async {
    // Fetch models first
    final models = await ref
        .read(cloudProviderProvider.notifier)
        .fetchProviderModels(provider.id);

    if (models.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No models found or fetch failed.')),
        );
      }
      return;
    }

    if (!context.mounted) return;

    // Get currently selected model IDs
    final saved =
        ref.read(cloudProviderProvider).savedConfigs[provider.id];
    final selectedIds =
        saved?.selectedModelIds.toSet() ?? <String>{};

    // If no selections yet, pre-select the catalog defaults
    if (selectedIds.isEmpty) {
      for (final m in provider.models) {
        selectedIds.add(m.id);
      }
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => _ModelSelectionDialog(
        providerName: provider.name,
        providerId: provider.id,
        models: models,
        initialSelectedIds: selectedIds,
      ),
    );
  }
}

// ─── Model Selection Dialog ──────────────────────────

class _ModelSelectionDialog extends ConsumerStatefulWidget {
  final String providerName;
  final String providerId;
  final List<CloudModelInfo> models;
  final Set<String> initialSelectedIds;

  const _ModelSelectionDialog({
    required this.providerName,
    required this.providerId,
    required this.models,
    required this.initialSelectedIds,
  });

  @override
  ConsumerState<_ModelSelectionDialog> createState() =>
      _ModelSelectionDialogState();
}

class _ModelSelectionDialogState
    extends ConsumerState<_ModelSelectionDialog> {
  late Set<String> _selectedIds;
  String _search = '';
  bool _showFreeOnly = false;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set<String>.from(widget.initialSelectedIds);
  }

  List<CloudModelInfo> get _filteredModels {
    var filtered = widget.models;
    if (_showFreeOnly) {
      filtered = filtered.where((m) => m.isFree).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      filtered = filtered
          .where((m) =>
              m.name.toLowerCase().contains(q) ||
              m.id.toLowerCase().contains(q))
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF16162A) : Colors.white;
    final textPrimary =
        isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
    final textSecondary =
        isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);
    final borderColor =
        isDark ? const Color(0xFF252540) : const Color(0xFFE2E2EC);
    final accentColor = Theme.of(context).colorScheme.primary;
    final filtered = _filteredModels;

    return AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.model_training_rounded,
              size: 20, color: accentColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text('${widget.providerName} Models',
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ),
          Text('${_selectedIds.length} selected',
              style: TextStyle(color: textSecondary, fontSize: 12)),
        ],
      ),
      content: SizedBox(
        width: 480,
        height: 420,
        child: Column(
          children: [
            // Search bar
            SizedBox(
              height: 36,
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: TextStyle(color: textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search models…',
                  hintStyle: TextStyle(
                      color: textSecondary.withValues(alpha: 0.5),
                      fontSize: 13),
                  prefixIcon: Icon(Icons.search, size: 18, color: textSecondary),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  filled: true,
                  fillColor: borderColor.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor, width: 0.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor, width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: accentColor, width: 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Filter bar
            Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      setState(() => _showFreeOnly = !_showFreeOnly),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _showFreeOnly
                          ? const Color(0xFF10B981).withValues(alpha: 0.12)
                          : borderColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: _showFreeOnly
                              ? const Color(0xFF10B981)
                              : borderColor),
                    ),
                    child: Text('Free only',
                        style: TextStyle(
                          color: _showFreeOnly
                              ? const Color(0xFF10B981)
                              : textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(
                      () => _selectedIds = filtered.map((m) => m.id).toSet()),
                  child: Text('Select All',
                      style: TextStyle(
                          color: accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => setState(() => _selectedIds.clear()),
                  child: Text('Clear',
                      style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Model list
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final model = filtered[i];
                  final isSelected = _selectedIds.contains(model.id);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedIds.remove(model.id);
                        } else {
                          _selectedIds.add(model.id);
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentColor.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? accentColor.withValues(alpha: 0.3)
                              : borderColor.withValues(alpha: 0.5),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            size: 18,
                            color: isSelected ? accentColor : textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(model.name,
                                    style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                Text(model.id,
                                    style: TextStyle(
                                        color: textSecondary, fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (model.isFree)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Free',
                                  style: TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600)),
                            )
                          else if (model.pricing != null)
                            Text(model.pricing!,
                                style: TextStyle(
                                    color: textSecondary, fontSize: 9)),
                          const SizedBox(width: 6),
                          Text('${(model.contextWindow / 1024).round()}K',
                              style: TextStyle(
                                  color: textSecondary, fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: textSecondary)),
        ),
        FilledButton(
          onPressed: () {
            ref
                .read(cloudProviderProvider.notifier)
                .updateSelectedModels(
                    widget.providerId, _selectedIds.toList());
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('${_selectedIds.length} models selected.'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: const Text('Save Selection'),
        ),
      ],
    );
  }
}
