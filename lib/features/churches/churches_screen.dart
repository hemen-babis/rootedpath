import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../data/repositories/churches_repo.dart';
import '../../data/models/church.dart';

class ChurchesScreen extends StatefulWidget {
  final Locale contentLocale;
  const ChurchesScreen({super.key, required this.contentLocale});

  @override
  State<ChurchesScreen> createState() => _ChurchesScreenState();
}

class _ChurchesScreenState extends State<ChurchesScreen> {
  final _repo = LocalChurchesRepo();
  String _filterLang = 'all'; // 'all' | 'en' | 'am' | 'ti' | 'om'

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppLocalizations>(
      future: AppLocalizations.delegate.load(widget.contentLocale),
      builder: (context, snap) {
        final t = snap.data;
        return Scaffold(
          appBar: AppBar(title: Text(t?.nearestChurch ?? 'Nearest Church')),
          body: !snap.hasData
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<Church>>(
            future: _repo.listAll(),
            builder: (context, cSnap) {
              if (!cSnap.hasData) return const Center(child: CircularProgressIndicator());
              var list = cSnap.data!;
              if (_filterLang != 'all') {
                list = list.where((c) => c.languages.contains(_filterLang)).toList();
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        Text(t!.filterByLanguage),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _filterLang,
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All')),
                            DropdownMenuItem(value: 'en', child: Text('English')),
                            DropdownMenuItem(value: 'am', child: Text('አማርኛ')),
                            DropdownMenuItem(value: 'ti', child: Text('ትግርኛ')),
                            DropdownMenuItem(value: 'om', child: Text('Afaan Oromo')),
                          ],
                          onChanged: (v) => setState(() => _filterLang = v ?? 'all'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 0),
                  Expanded(
                    child: ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, i) {
                        final c = list[i];
                        return Card(
                          child: ListTile(
                            title: Text(c.name),
                            subtitle: Text('${c.address}\n${t.languages}: ${c.languages.join(', ')}'),
                            isThreeLine: true,
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  tooltip: t.openInMaps,
                                  icon: const Icon(Icons.map_outlined),
                                  onPressed: () => _openMaps(c),
                                ),
                                IconButton(
                                  tooltip: t.call,
                                  icon: const Icon(Icons.call_outlined),
                                  onPressed: () => _call(c.phone),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openMaps(Church c) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('${c.name} ${c.lat},${c.lng}')}',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _call(String phone) async {
    final tel = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    await launchUrl(tel, mode: LaunchMode.externalApplication);
  }
}
