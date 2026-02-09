/// Soul Document settings section — user-editable memory & context for AI.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/soul_document.dart';
import 'settings_shared_widgets.dart';

class SoulDocumentSection extends ConsumerStatefulWidget {
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;
  const SoulDocumentSection({
    super.key,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
  });

  @override
  ConsumerState<SoulDocumentSection> createState() => _SoulDocumentSectionState();
}

class _SoulDocumentSectionState extends ConsumerState<SoulDocumentSection> {
  String? _editingSectionId;
  final _editController = TextEditingController();
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _editController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final soulState = ref.watch(soulDocumentProvider);
    final notifier = ref.read(soulDocumentProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Soul Document',
          subtitle: 'Your AI\'s memory about you',
          textPrimary: widget.textPrimary,
          textSecondary: widget.textSecondary,
        ),

        // Description card
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.accentColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: widget.accentColor.withValues(alpha: 0.15),
                width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded,
                      size: 16, color: widget.accentColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tell Prism about yourself so it can personalize every conversation.',
                      style: TextStyle(
                          color: widget.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'This stays on your device and is never uploaded. '
                'Fill in the sections below — the more context you give, '
                'the better Prism understands you.',
                style: TextStyle(color: widget.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),

        // Enable/disable toggle
        ToggleRow(
          title: 'Include in conversations',
          subtitle: 'Inject soul context into AI prompts',
          value: soulState.isEnabled,
          onChanged: (v) => notifier.setEnabled(v),
          cardColor: widget.cardColor,
          borderColor: widget.borderColor,
          textPrimary: widget.textPrimary,
          textSecondary: widget.textSecondary,
          accentColor: widget.accentColor,
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '${soulState.totalWords} words across ${soulState.sections.length} sections',
            style: TextStyle(color: widget.textSecondary, fontSize: 11),
          ),
        ),

        // Sections
        ...soulState.sections.map((section) {
          final isEditing = _editingSectionId == section.id;
          return _buildSectionCard(section, isEditing, notifier);
        }),

        // Add section button
        const SizedBox(height: 8),
        Row(
          children: [
            SmallButton(
              label: '+ Add Section',
              color: widget.accentColor,
              onTap: () => _showAddSectionDialog(notifier),
            ),
            const Spacer(),
            SmallButton(
              label: 'Export',
              color: widget.textSecondary,
              onTap: () {
                final json = notifier.export();
                Clipboard.setData(ClipboardData(text: json));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Soul Document copied to clipboard'),
                  duration: Duration(seconds: 2),
                ));
              },
            ),
            const SizedBox(width: 8),
            SmallButton(
              label: 'Import',
              color: widget.textSecondary,
              onTap: () => _showImportDialog(notifier),
            ),
          ],
        ),
        SettingsDivider(color: widget.borderColor),
      ],
    );
  }

  Widget _buildSectionCard(
      SoulSection section, bool isEditing, SoulDocumentNotifier notifier) {
    final hasContent = section.content.trim().isNotEmpty;
    final preview = hasContent
        ? (section.content.length > 120
            ? '${section.content.substring(0, 120)}…'
            : section.content)
        : 'Tap to add...';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isEditing ? widget.accentColor : widget.borderColor,
            width: isEditing ? 1.5 : 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          GestureDetector(
            onTap: () {
              if (isEditing) {
                // Save and close
                notifier.updateSection(section.id, _editController.text);
                setState(() => _editingSectionId = null);
              } else {
                // Open for editing
                _editController.text = section.content;
                setState(() => _editingSectionId = section.id);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(section.icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(section.title,
                            style: TextStyle(
                                color: widget.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13)),
                        if (!isEditing)
                          Text(preview,
                              style: TextStyle(
                                  color: hasContent
                                      ? widget.textSecondary
                                      : widget.textSecondary
                                          .withValues(alpha: 0.5),
                                  fontSize: 11),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  if (!section.isDefault && !isEditing)
                    GestureDetector(
                      onTap: () => _confirmRemoveSection(section, notifier),
                      child: Icon(Icons.close_rounded,
                          size: 16, color: widget.textSecondary),
                    ),
                  const SizedBox(width: 4),
                  Icon(
                    isEditing
                        ? Icons.check_circle_rounded
                        : Icons.edit_outlined,
                    size: 16,
                    color: isEditing
                        ? const Color(0xFF10B981)
                        : widget.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Edit area
          if (isEditing) ...[
            Divider(
                color: widget.borderColor, height: 1, indent: 12, endIndent: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_hintForSection(section.id),
                      style: TextStyle(
                          color: widget.textSecondary.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontStyle: FontStyle.italic)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _editController,
                    maxLines: 6,
                    minLines: 3,
                    style: TextStyle(
                        color: widget.textPrimary, fontSize: 12, height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Write anything...',
                      hintStyle: TextStyle(
                          color: widget.textSecondary.withValues(alpha: 0.4),
                          fontSize: 12),
                      contentPadding: const EdgeInsets.all(10),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SmallButton(
                        label: 'Save',
                        color: widget.accentColor,
                        onTap: () {
                          notifier.updateSection(
                              section.id, _editController.text);
                          setState(() => _editingSectionId = null);
                        },
                      ),
                      const SizedBox(width: 8),
                      SmallButton(
                        label: 'Cancel',
                        color: widget.textSecondary,
                        onTap: () =>
                            setState(() => _editingSectionId = null),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _hintForSection(String sectionId) {
    switch (sectionId) {
      case 'about_me':
        return 'e.g., Name, age, location, languages spoken, occupation...';
      case 'preferences':
        return 'e.g., Preferred language, communication style, units (metric/imperial)...';
      case 'goals':
        return 'e.g., Learn Flutter, save ₹50k this year, read 24 books...';
      case 'work':
        return 'e.g., Current company, tech stack, ongoing projects, team size...';
      case 'routines':
        return 'e.g., Wake up at 7am, gym MWF, weekly review on Sundays...';
      case 'important_notes':
        return 'e.g., Allergies, important dates, things to remember...';
      default:
        return 'Add any context that helps Prism assist you better...';
    }
  }

  void _showAddSectionDialog(SoulDocumentNotifier notifier) {
    _titleController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Add Section',
            style: TextStyle(
                color: widget.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        content: TextField(
          controller: _titleController,
          autofocus: true,
          style: TextStyle(color: widget.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Section name',
            hintStyle: TextStyle(
                color: widget.textSecondary.withValues(alpha: 0.5),
                fontSize: 13),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: widget.borderColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(color: widget.textSecondary, fontSize: 13)),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: widget.accentColor),
            onPressed: () {
              final title = _titleController.text.trim();
              if (title.isNotEmpty) {
                notifier.addSection(title: title);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Add', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(SoulDocumentNotifier notifier) {
    final importController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Import Soul Document',
            style: TextStyle(
                color: widget.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paste exported JSON below:',
                style: TextStyle(color: widget.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: TextField(
                controller: importController,
                maxLines: null,
                expands: true,
                style: TextStyle(color: widget.textPrimary, fontSize: 11),
                decoration: InputDecoration(
                  hintText: '{"version": 1, "sections": [...]}',
                  hintStyle: TextStyle(
                      color: widget.textSecondary.withValues(alpha: 0.4),
                      fontSize: 11),
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: widget.borderColor),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(color: widget.textSecondary, fontSize: 13)),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: widget.accentColor),
            onPressed: () async {
              final ok =
                  await notifier.importDocument(importController.text);
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      ok ? 'Soul Document imported!' : 'Invalid format'),
                  duration: const Duration(seconds: 2),
                ));
              }
              importController.dispose();
            },
            child: const Text('Import', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveSection(
      SoulSection section, SoulDocumentNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Remove "${section.title}"?',
            style: TextStyle(
                color: widget.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        content: Text('This will delete this section and its content.',
            style: TextStyle(color: widget.textSecondary, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(color: widget.textSecondary, fontSize: 13)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              notifier.removeSection(section.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Remove', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
