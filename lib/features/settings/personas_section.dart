/// Personas settings section — list, edit, create, import/export personas.
///
/// Connects to [PersonaManagerNotifier] for persistence and state.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/persona_manager.dart';
import 'settings_shared_widgets.dart';

class PersonasSection extends ConsumerWidget {
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;
  const PersonasSection(
      {super.key,
      required this.cardColor,
      required this.borderColor,
      required this.textPrimary,
      required this.textSecondary,
      required this.accentColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(personaManagerProvider);
    final notifier = ref.read(personaManagerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
            title: 'Personas',
            subtitle: 'Customize AI personality and behavior',
            textPrimary: textPrimary,
            textSecondary: textSecondary),

        if (!state.isLoaded)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: CircularProgressIndicator(strokeWidth: 2, color: accentColor),
            ),
          )
        else ...[
          ...state.personas.map((persona) {
            final isActive = persona.id == state.activePersonaId;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isActive ? accentColor : borderColor,
                    width: isActive ? 1.5 : 0.5),
              ),
              child: Row(
                children: [
                  Text(persona.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(persona.name,
                            style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 14)),
                        Text(persona.description,
                            style: TextStyle(
                                color: textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (!isActive)
                    SmallButton(
                      label: 'Activate',
                      color: accentColor,
                      onTap: () => notifier.setActive(persona.id),
                    ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('active',
                          style: TextStyle(fontSize: 10, color: accentColor)),
                    ),
                  const SizedBox(width: 6),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded,
                        size: 18, color: textSecondary),
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onSelected: (action) {
                      switch (action) {
                        case 'edit':
                          _showEditDialog(context, ref, persona);
                        case 'export':
                          _exportPersona(context, ref, persona.id);
                        case 'delete':
                          _confirmDelete(context, ref, persona);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 16, color: textPrimary),
                            const SizedBox(width: 8),
                            Text('Edit',
                                style: TextStyle(
                                    color: textPrimary, fontSize: 13)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.file_download_outlined,
                                size: 16, color: textPrimary),
                            const SizedBox(width: 8),
                            Text('Export JSON',
                                style: TextStyle(
                                    color: textPrimary, fontSize: 13)),
                          ],
                        ),
                      ),
                      if (!persona.isBuiltIn)
                        PopupMenuItem(
                          value: 'delete',
                          child: const Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 16, color: Color(0xFFEF4444)),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 12),
          Row(
            children: [
              SmallButton(
                label: 'Create Custom Persona',
                color: accentColor,
                onTap: () => _showEditDialog(context, ref, null),
              ),
              const SizedBox(width: 8),
              SmallButton(
                label: 'Import JSON',
                color: textSecondary,
                onTap: () => _showImportDialog(context, ref),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ─── Edit / Create Persona Dialog ──────────────────

  void _showEditDialog(
      BuildContext context, WidgetRef ref, Persona? existing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF16162A) : Colors.white;
    final dialogTextPrimary =
        isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
    final dialogTextSecondary =
        isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);
    final dialogBorderColor =
        isDark ? const Color(0xFF252540) : const Color(0xFFE2E2EC);
    final dialogAccent = Theme.of(context).colorScheme.primary;

    final isNew = existing == null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final emojiCtrl = TextEditingController(text: existing?.emoji ?? '🤖');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final promptCtrl =
        TextEditingController(text: existing?.systemPrompt ?? '');

    double tone = existing?.traits.tone ?? 0.5;
    double verbosity = existing?.traits.verbosity ?? 0.5;
    double humor = existing?.traits.humor ?? 0.3;
    double empathy = existing?.traits.empathy ?? 0.6;
    double creativity = existing?.traits.creativity ?? 0.5;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: bgColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(isNew ? Icons.person_add_outlined : Icons.edit_outlined,
                  size: 20, color: dialogAccent),
              const SizedBox(width: 10),
              Text(isNew ? 'Create Persona' : 'Edit Persona',
                  style: TextStyle(
                      color: dialogTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 360,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name + Emoji row
                  Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: _dialogField(
                          controller: emojiCtrl,
                          hint: '🤖',
                          textPrimary: dialogTextPrimary,
                          textSecondary: dialogTextSecondary,
                          borderColor: dialogBorderColor,
                          accentColor: dialogAccent,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _dialogField(
                          controller: nameCtrl,
                          hint: 'Persona Name',
                          textPrimary: dialogTextPrimary,
                          textSecondary: dialogTextSecondary,
                          borderColor: dialogBorderColor,
                          accentColor: dialogAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _dialogField(
                    controller: descCtrl,
                    hint: 'Short description',
                    textPrimary: dialogTextPrimary,
                    textSecondary: dialogTextSecondary,
                    borderColor: dialogBorderColor,
                    accentColor: dialogAccent,
                  ),
                  const SizedBox(height: 10),
                  Text('System Prompt',
                      style: TextStyle(
                          color: dialogTextSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 80,
                    child: TextField(
                      controller: promptCtrl,
                      maxLines: null,
                      expands: true,
                      style:
                          TextStyle(color: dialogTextPrimary, fontSize: 12),
                      decoration: InputDecoration(
                        hintText:
                            'You are a helpful assistant that...',
                        hintStyle: TextStyle(
                            color: dialogTextSecondary
                                .withValues(alpha: 0.5),
                            fontSize: 12),
                        contentPadding: const EdgeInsets.all(10),
                        filled: true,
                        fillColor:
                            dialogBorderColor.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: dialogBorderColor, width: 0.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: dialogBorderColor, width: 0.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: dialogAccent, width: 1),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text('PERSONALITY TRAITS',
                      style: TextStyle(
                          color: dialogTextSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1)),
                  const SizedBox(height: 8),

                  _traitSlider('Tone', 'Formal ↔ Casual', tone,
                      (v) => setDialogState(() => tone = v),
                      dialogTextPrimary, dialogTextSecondary, dialogAccent),
                  _traitSlider('Verbosity', 'Brief ↔ Detailed', verbosity,
                      (v) => setDialogState(() => verbosity = v),
                      dialogTextPrimary, dialogTextSecondary, dialogAccent),
                  _traitSlider('Humor', 'Serious ↔ Playful', humor,
                      (v) => setDialogState(() => humor = v),
                      dialogTextPrimary, dialogTextSecondary, dialogAccent),
                  _traitSlider('Empathy', 'Neutral ↔ Empathetic', empathy,
                      (v) => setDialogState(() => empathy = v),
                      dialogTextPrimary, dialogTextSecondary, dialogAccent),
                  _traitSlider('Creativity', 'Conservative ↔ Creative',
                      creativity,
                      (v) => setDialogState(() => creativity = v),
                      dialogTextPrimary, dialogTextSecondary, dialogAccent),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel',
                  style:
                      TextStyle(color: dialogTextSecondary, fontSize: 13)),
            ),
            FilledButton.icon(
              style:
                  FilledButton.styleFrom(backgroundColor: dialogAccent),
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;

                final traits = PersonaTraits(
                  tone: tone,
                  verbosity: verbosity,
                  humor: humor,
                  empathy: empathy,
                  creativity: creativity,
                );

                final notifier =
                    ref.read(personaManagerProvider.notifier);

                if (isNew) {
                  final id =
                      name.toLowerCase().replaceAll(' ', '_') +
                          '_${DateTime.now().millisecondsSinceEpoch}';
                  notifier.addPersona(Persona(
                    id: id,
                    name: name,
                    emoji: emojiCtrl.text.trim().isEmpty
                        ? '🤖'
                        : emojiCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    systemPrompt: promptCtrl.text.trim(),
                    traits: traits,
                  ));
                } else {
                  notifier.updatePersona(existing.copyWith(
                    name: name,
                    emoji: emojiCtrl.text.trim().isEmpty
                        ? '🤖'
                        : emojiCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    systemPrompt: promptCtrl.text.trim(),
                    traits: traits,
                  ));
                }

                Navigator.of(ctx).pop();
              },
              icon: Icon(isNew ? Icons.add_rounded : Icons.save_rounded,
                  size: 16),
              label: Text(isNew ? 'Create' : 'Save',
                  style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Import Dialog ─────────────────────────────────

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF16162A) : Colors.white;
    final dialogTextPrimary =
        isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
    final dialogTextSecondary =
        isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);
    final dialogBorderColor =
        isDark ? const Color(0xFF252540) : const Color(0xFFE2E2EC);
    final dialogAccent = Theme.of(context).colorScheme.primary;
    final jsonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.file_upload_outlined,
                size: 20, color: dialogAccent),
            const SizedBox(width: 10),
            Text('Import Persona',
                style: TextStyle(
                    color: dialogTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Paste a persona JSON exported from Prism or another app.',
                  style: TextStyle(color: dialogTextSecondary, fontSize: 12)),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: TextField(
                  controller: jsonCtrl,
                  maxLines: null,
                  expands: true,
                  style:
                      TextStyle(color: dialogTextPrimary, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: '{ "id": "...", "name": "...", ... }',
                    hintStyle: TextStyle(
                        color:
                            dialogTextSecondary.withValues(alpha: 0.5),
                        fontSize: 12),
                    contentPadding: const EdgeInsets.all(10),
                    filled: true,
                    fillColor:
                        dialogBorderColor.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: dialogBorderColor, width: 0.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: dialogBorderColor, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: dialogAccent, width: 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SmallButton(
                label: 'Paste from clipboard',
                color: dialogTextSecondary,
                onTap: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data?.text != null) {
                    jsonCtrl.text = data!.text!;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style:
                    TextStyle(color: dialogTextSecondary, fontSize: 13)),
          ),
          FilledButton.icon(
            style:
                FilledButton.styleFrom(backgroundColor: dialogAccent),
            onPressed: () async {
              final json = jsonCtrl.text.trim();
              if (json.isEmpty) return;
              final ok = await ref
                  .read(personaManagerProvider.notifier)
                  .importPersona(json);
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Invalid persona JSON.'),
                  backgroundColor: Color(0xFFEF4444),
                ));
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Persona imported successfully!'),
                  duration: Duration(seconds: 2),
                ));
              }
            },
            icon: const Icon(Icons.file_upload_outlined, size: 16),
            label: const Text('Import', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ─── Export Persona ────────────────────────────────

  void _exportPersona(
      BuildContext context, WidgetRef ref, String personaId) {
    final json =
        ref.read(personaManagerProvider.notifier).exportPersona(personaId);
    if (json == null) return;

    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Persona JSON copied to clipboard!'),
      duration: Duration(seconds: 2),
    ));
  }

  // ─── Delete Confirmation ──────────────────────────

  void _confirmDelete(
      BuildContext context, WidgetRef ref, Persona persona) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF16162A) : Colors.white;
    final dialogTextPrimary =
        isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
    final dialogTextSecondary =
        isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline,
                size: 20, color: Color(0xFFEF4444)),
            const SizedBox(width: 10),
            Text('Delete "${persona.name}"?',
                style: TextStyle(
                    color: dialogTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(
          'This custom persona will be permanently removed.',
          style: TextStyle(color: dialogTextSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style:
                    TextStyle(color: dialogTextSecondary, fontSize: 13)),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              ref
                  .read(personaManagerProvider.notifier)
                  .removePersona(persona.id);
              Navigator.of(ctx).pop();
            },
            icon: const Icon(Icons.delete_outline, size: 16),
            label:
                const Text('Delete', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────

  static Widget _dialogField({
    required TextEditingController controller,
    required String hint,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
    required Color accentColor,
    TextAlign textAlign = TextAlign.start,
  }) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        textAlign: textAlign,
        style: TextStyle(color: textPrimary, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: textSecondary.withValues(alpha: 0.5), fontSize: 13),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
    );
  }

  static Widget _traitSlider(
    String label,
    String range,
    double value,
    ValueChanged<double> onChanged,
    Color textPrimary,
    Color textSecondary,
    Color accentColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: TextStyle(
                      color: textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              Text(range,
                  style: TextStyle(color: textSecondary, fontSize: 10)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: accentColor,
              inactiveTrackColor: accentColor.withValues(alpha: 0.15),
              thumbColor: accentColor,
              overlayColor: accentColor.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
