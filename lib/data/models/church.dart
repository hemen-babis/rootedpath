class Church {
  final String id;
  final String name;
  final double lat, lng;
  final String address;
  final String phone;
  final List<String> languages; // ['am','ti','om','en']
  const Church({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.address,
    required this.phone,
    required this.languages,
  });
}
