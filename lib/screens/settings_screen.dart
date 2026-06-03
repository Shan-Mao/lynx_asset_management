import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:intl/intl.dart';
import '../providers/asset_provider.dart';
import '../providers/layout_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/save_format_provider.dart';
import '../utils/strings.dart';
import 'personalization_screen.dart';
import 'theme_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  // ---------------------------------------------------------------------------
  // Export / Import
  // ---------------------------------------------------------------------------

  Future<void> _exportData() async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<AssetProvider>();
    if (provider.assets.isEmpty) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(S.homeExportEmpty), duration: const Duration(seconds: 2)));
      return;
    }

    final sfp = context.read<SaveFormatProvider>();
    final pp = context.read<ProfileProvider>();
    final userName = pp.displayName.isNotEmpty ? pp.displayName : S.saveFormatDefaultUser;
    final dateStr = DateFormat('yyyy_MM_dd').format(DateTime.now());
    final fileName = sfp.fileNameTemplate
        .replaceAll('{export_date}', dateStr)
        .replaceAll('{user_name}', userName)
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

    final txt = provider.exportToTxt(separator: sfp.separator, selectedFields: sfp.selectedFields);
    final bytes = utf8.encode(txt);

    if (kIsWeb) {
      try {
        await Share.shareXFiles([XFile.fromData(bytes, name: '$fileName.txt')]);
      } catch (_) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(S.homeExportFailed), duration: const Duration(seconds: 2)));
      }
    } else {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: S.homeExportDialogTitle,
        fileName: '$fileName.txt',
        bytes: bytes,
      );
      if (result != null) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(S.homeExportedTo(result)), duration: const Duration(seconds: 2)));
      }
    }
  }

  Future<void> _importData() async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<AssetProvider>();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('无法读取文件。'), duration: Duration(seconds: 2)));
      return;
    }

    try {
      final content = utf8.decode(file.bytes!);
      final count = provider.importFromTxt(content);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('已导入 $count 个资产。'), duration: const Duration(seconds: 2)));
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('文件解析失败，请确认是有效的导出文件。'), duration: Duration(seconds: 2)));
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Personalization ----
          ListTile(
            leading: Icon(kIsWeb ? Icons.language : Icons.phone_android),
            title: Text(S.settingsPersonalization),
            subtitle: Text(kIsWeb ? S.personalizationWeb : S.personalizationAndroid, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalizationScreen())),
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // ---- Data Management ----
          ListTile(
            leading: const Icon(Icons.file_upload_outlined),
            title: Text(S.settingsExport),
            trailing: const Icon(Icons.chevron_right),
            onTap: _exportData,
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: Text(S.settingsImport),
            trailing: const Icon(Icons.chevron_right),
            onTap: _importData,
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // ---- Theme ----
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(S.settingsTheme),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThemeScreen()),
              );
            },
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // ---- Language ----
          Consumer<LocaleProvider>(
            builder: (context, lp, _) {
              return ListTile(
                leading: const Icon(Icons.language),
                title: Text(S.settingsLanguage),
                trailing: DropdownButton<String>(
                  value: lp.languageCode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'zh', child: Text('简体中文 (zh-CN)')),
                    DropdownMenuItem(value: 'en', child: Text('English (en-US)')),
                  ],
                  onChanged: (v) {
                    lp.setLocale(v!);
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // ---- Layout ----
          Consumer<LayoutProvider>(
            builder: (context, lp, _) {
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.grid_view_outlined),
                    title: Text(S.settingsLayout),
                    trailing: SegmentedButton<LayoutMode>(
                      segments: [
                        ButtonSegment(value: LayoutMode.list, label: Text(S.layoutList), icon: const Icon(Icons.view_list)),
                        ButtonSegment(value: LayoutMode.grid, label: Text(S.layoutGrid), icon: const Icon(Icons.grid_view)),
                      ],
                      selected: {lp.mode},
                      onSelectionChanged: (v) => lp.mode = v.first,
                      style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact),
                    ),
                  ),
                  if (lp.isGrid) ...[
                    const SizedBox(height: 8),
                    // Aspect ratio
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(children: [
                        SizedBox(width: 120, child: Padding(padding: const EdgeInsets.only(left: 28), child: Text(S.layoutAspect, style: Theme.of(context).textTheme.bodyMedium))),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SegmentedButton<GridAspect>(
                            segments: GridAspect.values.map((a) => ButtonSegment(value: a, label: Text(a.label))).toList(),
                            selected: {lp.gridAspect},
                            onSelectionChanged: (v) => lp.gridAspect = v.first,
                            style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    // Portrait columns
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(children: [
                        SizedBox(width: 120, child: Row(children: [const Icon(Icons.stay_current_portrait, size: 20), const SizedBox(width: 8), Text(S.layoutColumnsPortrait, style: Theme.of(context).textTheme.bodyMedium)])),
                        const SizedBox(width: 8),
                        IconButton(icon: const Icon(Icons.remove_circle_outline), visualDensity: VisualDensity.compact, onPressed: () => lp.columnsPortrait = lp.columnsPortrait - 1),
                        SizedBox(width: 32, child: Text('${lp.columnsPortrait}', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall)),
                        IconButton(icon: const Icon(Icons.add_circle_outline), visualDensity: VisualDensity.compact, onPressed: () => lp.columnsPortrait = lp.columnsPortrait + 1),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    // Landscape columns
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(children: [
                        SizedBox(width: 120, child: Row(children: [const Icon(Icons.stay_current_landscape, size: 20), const SizedBox(width: 8), Text(S.layoutColumnsLandscape, style: Theme.of(context).textTheme.bodyMedium)])),
                        const SizedBox(width: 8),
                        IconButton(icon: const Icon(Icons.remove_circle_outline), visualDensity: VisualDensity.compact, onPressed: () => lp.columnsLandscape = lp.columnsLandscape - 1),
                        SizedBox(width: 32, child: Text('${lp.columnsLandscape}', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall)),
                        IconButton(icon: const Icon(Icons.add_circle_outline), visualDensity: VisualDensity.compact, onPressed: () => lp.columnsLandscape = lp.columnsLandscape + 1),
                      ]),
                    ),
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // ---- Display ----
          SwitchListTile(
            title: Text(S.settingsHideRetired),
            value: false,
            onChanged: (_) {},
          ),
          SwitchListTile(
            title: Text(S.settingsHideSold),
            value: false,
            onChanged: (_) {},
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
