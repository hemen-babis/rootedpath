import '../models/church.dart';

abstract class ChurchesRepo {
  Future<List<Church>> listAll();
}

class LocalChurchesRepo implements ChurchesRepo {
  @override
  Future<List<Church>> listAll() async => const [
    Church(
      id: 'c1',
      name: 'St. Michael Ethiopian Orthodox',
      lat: 34.108, lng: -117.289,
      address: '1234 E Highland Ave, San Bernardino, CA',
      phone: '+1-909-555-1234',
      languages: ['am','en'],
    ),
    Church(
      id: 'c2',
      name: 'St. Mary Eritrean Orthodox',
      lat: 34.090, lng: -117.300,
      address: '987 W 5th St, San Bernardino, CA',
      phone: '+1-909-555-5678',
      languages: ['ti','am','en'],
    ),
    Church(
      id: 'c3',
      name: 'Holy Trinity (Afaan Oromo Service)',
      lat: 34.12, lng: -117.25,
      address: '456 Trinity Rd, San Bernardino, CA',
      phone: '+1-909-555-9012',
      languages: ['om','en'],
    ),
  ];
}
