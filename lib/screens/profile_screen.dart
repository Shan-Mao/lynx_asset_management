import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../utils/strings.dart';
import 'about_screen.dart';
import 'image_editor_screen.dart';
import 'settings_screen.dart';
import 'theme_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context, String current) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.profileTitle),
        content: TextField(controller: ctrl, autofocus: true, decoration: InputDecoration(hintText: S.profileTitle)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(S.detailCancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: Text(S.formSave)),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && context.mounted) {
      context.read<ProfileProvider>().displayName = result;
    }
  }

  Future<void> _startImageFlow(BuildContext context) async {
    // Context must be valid (not from a now-closed bottom sheet).
    if (!context.mounted) return;
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.first.bytes;
    if (bytes == null || !context.mounted) return;
    final edited = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ImageEditorScreen(imageBytes: bytes)),
    );
    if (edited != null && context.mounted) {
      context.read<ProfileProvider>().avatarImageBytes = edited;
    }
  }

  void _pickIcon(BuildContext context) {
    final pp = context.read<ProfileProvider>();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('选择图标', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('从相册选择图片'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(ctx); // dismiss sheet first
              _startImageFlow(context);
            },
          ),
          const Divider(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(avatarIcons.length, (i) => ChoiceChip(
              label: Icon(avatarIcons[i]),
              selected: !pp.hasCustomImage && pp.avatarIconIndex == i,
              onSelected: (_) {
                pp.avatarIconIndex = i;
                Navigator.pop(ctx);
              },
            )),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(''), centerTitle: true, actions: [
        IconButton(icon: const Icon(Icons.brightness_6_outlined), tooltip: S.profileThemeTooltip, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeScreen()))),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Consumer<ProfileProvider>(
          builder: (context, pp, _) {
            final name = pp.displayName.isNotEmpty ? pp.displayName : S.profileTitle;
            return Center(child: Column(children: [
              GestureDetector(
                onTap: () => _pickIcon(context),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: pp.hasCustomImage ? null : pp.avatarColor,
                  backgroundImage: pp.hasCustomImage ? MemoryImage(pp.avatarImageBytes!) : null,
                  child: pp.hasCustomImage ? null : Icon(pp.avatarIcon, size: 36, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _editName(context, name),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(name, textAlign: TextAlign.center, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const Positioned(right: 0, child: Icon(Icons.edit, size: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ]));
          },
        ),
        const SizedBox(height: 32), const Divider(),
        ListTile(leading: const Icon(Icons.settings_outlined), title: Text(S.profileSettings), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
        const Divider(),
        ListTile(leading: const Icon(Icons.info_outline), title: Text(S.profileAbout), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()))),
        const Divider(), const SizedBox(height: 32),
      ]),
    );
  }
}
