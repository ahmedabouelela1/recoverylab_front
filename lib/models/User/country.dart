class CountryCode {
  final String name;
  final String code;
  final String flag;

  CountryCode(this.name, this.code, this.flag);

  @override
  String toString() => '$flag $code';
}

final List<CountryCode> countryCodes = [
  CountryCode('Egypt', '+20', '🇪🇬'),
  CountryCode('Saudi Arabia', '+966', '🇸🇦'),
  CountryCode('UAE', '+971', '🇦🇪'),
  CountryCode('USA', '+1', '🇺🇸'),
  CountryCode('UK', '+44', '🇬🇧'),
];
