import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../utils/strings.dart';

class SeedColorScreen extends StatefulWidget {
  const SeedColorScreen({super.key});

  @override
  State<SeedColorScreen> createState() => _SeedColorScreenState();
}

class _SeedColorScreenState extends State<SeedColorScreen> {
  late Color _draft;

  static const _presetColors = <Color>[
    Colors.teal, Colors.blue, Colors.indigo, Colors.purple, Colors.pink,
    Colors.red, Colors.deepOrange, Colors.orange, Colors.amber, Colors.yellow,
    Colors.lime, Colors.green, Colors.cyan, Colors.brown, Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _draft = context.read<ThemeProvider>().seedColor;
  }

  void _setRgb(double r, double g, double b) {
    setState(() => _draft = Color.fromARGB(255, r.round(), g.round(), b.round()));
  }

  void _setHsv(double h, double s, double v) {
    setState(() => _draft = HSVColor.fromAHSV(1, h, s, v).toColor());
  }

  void _setHsl(double h, double s, double l) {
    setState(() => _draft = HSLColor.fromAHSL(1, h, s, l).toColor());
  }

  void _save() {
    context.read<ThemeProvider>().seedColor = _draft;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: S.themeSave,
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: _draft,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            S.seedPresets,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _presetColors.map((color) {
              final isSelected = _draft.toARGB32() == color.toARGB32();
              return GestureDetector(
                onTap: () => setState(() => _draft = color),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(color: theme.colorScheme.onSurface, width: 3) : null,
                    boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)] : null,
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          const Divider(),

          _ColorSliderGroup(title: 'RGB', children: [
            _ColorSlider(label: 'R', value: _draft.r * 255, max: 255, color: Colors.red,
              onChanged: (v) => _setRgb(v, _draft.g * 255, _draft.b * 255)),
            _ColorSlider(label: 'G', value: _draft.g * 255, max: 255, color: Colors.green,
              onChanged: (v) => _setRgb(_draft.r * 255, v, _draft.b * 255)),
            _ColorSlider(label: 'B', value: _draft.b * 255, max: 255, color: Colors.blue,
              onChanged: (v) => _setRgb(_draft.r * 255, _draft.g * 255, v)),
          ]),
          _ColorSliderGroup(title: 'HSV', children: [
            _ColorSlider(label: 'H', value: HSVColor.fromColor(_draft).hue, max: 360, color: _draft,
              onChanged: (v) { final hsv = HSVColor.fromColor(_draft); _setHsv(v, hsv.saturation, hsv.value); }),
            _ColorSlider(label: 'S', value: HSVColor.fromColor(_draft).saturation, max: 1, color: _draft,
              onChanged: (v) { final hsv = HSVColor.fromColor(_draft); _setHsv(hsv.hue, v, hsv.value); }),
            _ColorSlider(label: 'V', value: HSVColor.fromColor(_draft).value, max: 1, color: _draft,
              onChanged: (v) { final hsv = HSVColor.fromColor(_draft); _setHsv(hsv.hue, hsv.saturation, v); }),
          ]),
          _ColorSliderGroup(title: 'HSL', children: [
            _ColorSlider(label: 'H', value: HSLColor.fromColor(_draft).hue, max: 360, color: _draft,
              onChanged: (v) { final hsl = HSLColor.fromColor(_draft); _setHsl(v, hsl.saturation, hsl.lightness); }),
            _ColorSlider(label: 'S', value: HSLColor.fromColor(_draft).saturation, max: 1, color: _draft,
              onChanged: (v) { final hsl = HSLColor.fromColor(_draft); _setHsl(hsl.hue, v, hsl.lightness); }),
            _ColorSlider(label: 'L', value: HSLColor.fromColor(_draft).lightness, max: 1, color: _draft,
              onChanged: (v) { final hsl = HSLColor.fromColor(_draft); _setHsl(hsl.hue, hsl.saturation, v); }),
          ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ColorSliderGroup extends StatefulWidget {
  const _ColorSliderGroup({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  State<_ColorSliderGroup> createState() => _ColorSliderGroupState();
}

class _ColorSliderGroupState extends State<_ColorSliderGroup> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) => Column(children: [
    ListTile(
      title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
      onTap: () => setState(() => _expanded = !_expanded),
      dense: true, contentPadding: EdgeInsets.zero,
    ),
    if (_expanded) ...widget.children,
    const Divider(),
  ]);
}

class _ColorSlider extends StatelessWidget {
  const _ColorSlider({required this.label, required this.value, required this.max, required this.color, required this.onChanged});
  final String label;
  final double value;
  final double max;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final isInt = max == 255;
    final display = isInt ? value.round().toString() : value.toStringAsFixed(2);
    return Row(children: [
      SizedBox(width: 24, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
      Expanded(child: SliderTheme(
        data: SliderThemeData(trackHeight: 4, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8), activeTrackColor: color, thumbColor: color),
        child: Slider(value: value, min: 0, max: max, onChanged: onChanged),
      )),
      SizedBox(width: 40, child: Text(display, textAlign: TextAlign.end, style: const TextStyle(fontSize: 13))),
    ]);
  }
}
