// lib/features/readings/reading_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../services/cache.dart';
import '../../data/repositories/readings_repo.dart';

class ReadingScreen extends StatefulWidget {
  final Locale contentLocale;
  const ReadingScreen({super.key, required this.contentLocale});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  late final String _lang;
  late DateTime _date; // selected day
  late final ReadingsRepo _repo;
  Future<String?>? _future;

  @override
  void initState() {
    super.initState();
    _lang = widget.contentLocale.languageCode;
    _date = DateTime.now();
    _repo = ReadingsRepo();
    // warm the cache for the next 7 days
    Future.microtask(() => _repo.prefetchDays(7, _lang));
    _load();
  }

  String _dateId(DateTime d) => DateFormat('yyyyMMdd').format(d);
  String _pretty(DateTime d) => DateFormat('EEE, MMM d, y').format(d);

  void _load() {
    final id = _dateId(_date);
    setState(() {
      _future = _repo.getReading(dateId: id, lang: _lang);
    });
  }

  void _prev() {
    setState(() => _date = _date.subtract(const Duration(days: 1)));
    _load();
  }

  void _next() {
    setState(() => _date = _date.add(const Duration(days: 1)));
    _load();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
      _load();
    }
  }

  void _today() {
    setState(() => _date = DateTime.now());
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppLocalizations>(
      future: AppLocalizations.delegate.load(widget.contentLocale),
      builder: (context, tSnap) {
        final t = tSnap.data;
        if (!tSnap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final id = _dateId(_date);
        final cacheKey = 'reading:$id:$_lang';

        return Scaffold(
          appBar: AppBar(
            title: Text(t!.dailyReading),
            actions: [
              IconButton(icon: const Icon(Icons.today), tooltip: 'Today', onPressed: _today),
              IconButton(icon: const Icon(Icons.calendar_month), tooltip: 'Pick date', onPressed: () => _pickDate(context)),
            ],
          ),
          body: FutureBuilder<String?>(
            future: _future,
            builder: (context, rSnap) {
              final remote = rSnap.data;
              final cached = CacheService.get<String>(cacheKey);
              final text = remote ?? cached ?? (_sample[_lang] ?? _sample['en']!);

              if (remote != null && remote != cached) {
                Future.microtask(() => CacheService.put(cacheKey, remote));
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Day controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(onPressed: _prev, icon: const Icon(Icons.chevron_left)),
                        Text(_pretty(_date), style: Theme.of(context).textTheme.titleMedium),
                        IconButton(onPressed: _next, icon: const Icon(Icons.chevron_right)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('dateId: $id  •  lang: $_lang',
                                    style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 6),
                                if (remote != null)
                                  Text('Live ✓', style: Theme.of(context).textTheme.bodySmall)
                                else if (cached != null)
                                  Text('Cached ✓', style: Theme.of(context).textTheme.bodySmall)
                                else
                                  Text('Sample (fallback)', style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 10),
                                Text(text),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

const Map<String, String> _sample = {
  'en': '“Your word is a lamp to my feet and a light to my path.” — Psalm 119:105',
  'am': '«ቃልህ ለእግረቴ ማብራት፣ ለመንገዴም ብርሃን ነው።» — መዝ 119፥105',
  'ti': '«ቃልካ መግሩም ለእግረይ መብራሂ እዩ፣ ለመንገዲይ ብርሃን እዩ።» — መዝ 119፥105',
  'om': '“Jecha kee bubbee miilla koo fi ifa kara koo ti.” — Faarfannaa 119:105',
};
