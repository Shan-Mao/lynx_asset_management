import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/save_format_provider.dart';
import '../utils/strings.dart';

/// Configure export file format: naming, encoding, separator, included fields.
class SaveFormatScreen extends StatefulWidget {
  const SaveFormatScreen({super.key});

  @override
  State<SaveFormatScreen> createState() => _SaveFormatScreenState();
}

class _SaveFormatScreenState extends State<SaveFormatScreen> {
  late final TextEditingController _nameCtrl;
  final FocusNode _nameFocus = FocusNode();

  static const _encodings = ['UTF-8', 'UTF-16', 'GBK'];
  static const _separators = [': ', ' = ', '\t', ' | '];
  static const _presetTokens = ['{export_date}', '{user_name}'];

  @override
  void initState() {
    super.initState();
    final sfp = context.read<SaveFormatProvider>();
    _nameCtrl = TextEditingController(text: sfp.fileNameTemplate);
    _nameCtrl.addListener(_onTemplateChanged);
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_onTemplateChanged);
    _nameCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _onTemplateChanged() {
    context.read<SaveFormatProvider>().fileNameTemplate = _nameCtrl.text;
    setState(() {}); // rebuild preview
  }

  void _insertToken(String token) {
    final text = _nameCtrl.text;
    final sel = _nameCtrl.selection;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final newText = text.replaceRange(start, end, token);
    _nameCtrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + token.length),
    );
  }

  String _resolveTemplate() {
    final pp = context.read<ProfileProvider>();
    final userName = pp.displayName.isNotEmpty ? pp.displayName : S.saveFormatDefaultUser;
    final dateStr = DateFormat('yyyy_MM_dd').format(DateTime.now());
    return _nameCtrl.text
        .replaceAll('{export_date}', dateStr)
        .replaceAll('{user_name}', userName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolved = _resolveTemplate();
    final hasTemplate = _nameCtrl.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text(''), centerTitle: true),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // ===== File Naming Rule =====
        Text(S.saveFormatNaming, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _nameCtrl,
          focusNode: _nameFocus,
          decoration: InputDecoration(
            hintText: S.saveFormatNamingHint,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        // Preset token chips
        Wrap(spacing: 8, children: _presetTokens.map((t) => ActionChip(
              label: Text(t),
              onPressed: () => _insertToken(t),
            )).toList()),
        const SizedBox(height: 8),
        // Live preview
        Row(children: [
          Icon(Icons.remove_red_eye_outlined, size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: 6),
          Text(S.saveFormatNamingPreview, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline)),
        ]),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            hasTemplate ? '$resolved.txt' : S.saveFormatNamingPreviewHint,
            style: hasTemplate
                ? theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')
                : theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace', color: theme.colorScheme.outline, fontStyle: FontStyle.italic),
          ),
        ),

        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),

        // ===== Content Rules (expandable, collapsed by default) =====
        ExpansionTile(
          initiallyExpanded: false,
          leading: const Icon(Icons.rule),
          title: Text(S.saveFormatContentRules),
          children: [
            Consumer<SaveFormatProvider>(
              builder: (context, sfp, _) {
                return Column(children: [
                  // Encoding
                  ListTile(
                    leading: const Icon(Icons.code),
                    title: Text(S.saveFormatEncoding),
                    trailing: DropdownButton<String>(
                      value: sfp.encoding,
                      underline: const SizedBox(),
                      items: _encodings.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => sfp.encoding = v!,
                    ),
                  ),
                  const Divider(indent: 72),
                  // Separator
                  ListTile(
                    leading: const Icon(Icons.space_bar),
                    title: Text(S.saveFormatSeparator),
                    trailing: DropdownButton<String>(
                      value: sfp.separator,
                      underline: const SizedBox(),
                      items: _separators.map((s) => DropdownMenuItem(value: s, child: Text(s == '\t' ? 'Tab' : s))).toList(),
                      onChanged: (v) => sfp.separator = v!,
                    ),
                  ),
                  const Divider(indent: 72),
                  // Fields
                  Padding(
                    padding: const EdgeInsets.only(left: 72, top: 8, bottom: 4),
                    child: Text(S.saveFormatFields, style: theme.textTheme.titleSmall),
                  ),
                  const SizedBox(height: 4),
                  ...SaveFormatProvider.allFieldKeys.map((f) => Padding(
                        padding: const EdgeInsets.only(left: 56),
                        child: CheckboxListTile(
                          title: Text(S.fieldName(f)),
                          value: sfp.isFieldSelected(f),
                          onChanged: (_) => sfp.toggleField(f),
                          dense: true,
                        ),
                      )),
                  const SizedBox(height: 8),
                ]);
              },
            ),
          ],
        ),

        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),

        // ===== Content Preview =====
        Row(children: [
          Icon(Icons.remove_red_eye_outlined, size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: 6),
          Text(S.saveFormatContentPreview, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline)),
        ]),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            S.saveFormatPreviewSample,
            style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace', color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }
}
