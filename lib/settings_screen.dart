import 'package:flutter/material.dart';
import 'theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dark = true;
  int _darkIndex = 0;
  int _lightIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ThemeController.getCurrent();
    setState(() {
      _dark = (data['mode'] as String) != 'light';
      _darkIndex = data['darkIndex'] as int;
      _lightIndex = data['lightIndex'] as int;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Dark (AMOLED)'), icon: Icon(Icons.dark_mode)),
              ButtonSegment(value: false, label: Text('Light'), icon: Icon(Icons.light_mode)),
            ],
            selected: {_dark},
            onSelectionChanged: (s) async {
              setState(() => _dark = s.first);
              await ThemeController.setModeAndPalette(
                dark: _dark,
                index: _dark ? _darkIndex : _lightIndex,
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Color Palette', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(5, (i) => _buildSwatch(i)),
          ),
        ],
      ),
    );
  }

  Widget _buildSwatch(int index) {
    final isSelected = (_dark ? _darkIndex : _lightIndex) == index;
    final theme = Theme.of(context);
    final color = (_dark
        ? ThemeController.darkPalettes[index]
        : ThemeController.lightPalettes[index]);
    return GestureDetector(
      onTap: () async {
        setState(() {
          if (_dark) {
            _darkIndex = index;
          } else {
            _lightIndex = index;
          }
        });
        await ThemeController.setModeAndPalette(dark: _dark, index: index);
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: isSelected ? theme.colorScheme.onPrimary : Colors.white24,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, spreadRadius: 1),
          ],
        ),
      ),
    );
  }
}
