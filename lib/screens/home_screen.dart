import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../providers/asset_provider.dart';
import '../providers/layout_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/save_format_provider.dart';
import '../utils/strings.dart';
import '../widgets/asset_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/grid_asset_card.dart';
import '../widgets/summary_header.dart';
import 'add_edit_asset_screen.dart';
import 'asset_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AssetProvider>().loadAssets());
  }

  Future<void> _exportData() async {
    final provider = context.read<AssetProvider>();
    if (provider.assets.isEmpty) { _showSnackBar(S.homeExportEmpty); return; }

    final sfp = context.read<SaveFormatProvider>();
    final pp = context.read<ProfileProvider>();
    final userName = pp.displayName.isNotEmpty ? pp.displayName : S.saveFormatDefaultUser;
    final dateStr = DateFormat('yyyy_MM_dd').format(DateTime.now());
    final fileName = sfp.fileNameTemplate
        .replaceAll('{export_date}', dateStr)
        .replaceAll('{user_name}', userName)
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_'); // sanitise

    final txt = provider.exportToTxt(separator: sfp.separator, selectedFields: sfp.selectedFields);
    final bytes = utf8.encode(txt);
    if (kIsWeb) {
      try { await Share.shareXFiles([XFile.fromData(bytes, name: '$fileName.txt')]); }
      catch (_) { _showSnackBar(S.homeExportFailed); }
    } else {
      final result = await FilePicker.platform.saveFile(dialogTitle: S.homeExportDialogTitle, fileName: '$fileName.txt', bytes: bytes);
      if (result != null) _showSnackBar(S.homeExportedTo(result));
    }
  }

  Future<void> _importData() async {
    final provider = context.read<AssetProvider>();
    final result = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) { _showSnackBar(S.homeImportReadError); return; }
    try {
      final content = utf8.decode(file.bytes!);
      final count = provider.importFromTxt(content);
      if (!mounted) return;
      _showSnackBar(S.homeImportCount(count));
    } catch (_) { _showSnackBar(S.homeImportParseError); }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(''), centerTitle: true, actions: [
        IconButton(icon: const Icon(Icons.file_download_outlined), tooltip: S.homeImport, onPressed: _importData),
        IconButton(icon: const Icon(Icons.file_upload_outlined), tooltip: S.homeExport, onPressed: _exportData),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditAssetScreen())),
        icon: const Icon(Icons.add), label: Text(S.homeAddAsset),
      ),
      body: Consumer2<AssetProvider, LayoutProvider>(builder: (context, provider, lp, _) {
        if (!provider.isLoaded) return const Center(child: CircularProgressIndicator());
        if (provider.assets.isEmpty) return const EmptyState();

        final isGrid = lp.isGrid;
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        final crossAxisCount = isLandscape ? lp.columnsLandscape : lp.columnsPortrait;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SummaryHeader(assetCount: provider.assetCount, totalValue: provider.totalValue, totalDailyCost: provider.totalDailyCost)),
            const SliverToBoxAdapter(child: SizedBox(height: 4)),
            if (isGrid)
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: lp.gridAspect.ratio,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GridAssetCard(
                      asset: provider.assets[index],
                      aspectRatio: lp.gridAspect.ratio,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AssetDetailScreen(assetId: provider.assets[index].id))),
                    ),
                  ),
                  childCount: provider.assets.length,
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => AssetCard(
                    asset: provider.assets[index],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AssetDetailScreen(assetId: provider.assets[index].id))),
                  ),
                  childCount: provider.assets.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        );
      }),
    );
  }
}
