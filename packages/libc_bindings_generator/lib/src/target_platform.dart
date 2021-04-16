class TargetPlatform {
  const TargetPlatform(this.name);

  factory TargetPlatform.fromName(String name) => values.singleWhere((platform) => platform.name == name);

  final String name;

  /// Ubuntu 12.04 Precise Pangolin, support 2012 - 2017
  static const precise = TargetPlatform('precise');

  /// Ubuntu 14.04 Trusty Tahr, support 2014 - 2019
  static const trusty = TargetPlatform('trusty');

  /// Debian 8 Jessie, support 2015 - 2018
  static const jessie = TargetPlatform('jessie');

  /// Debian Unstable
  static const sid = TargetPlatform('sid');

  static const values = {precise, trusty, jessie, sid};

  @override
  String toString() => 'TargetPlatform.$name';
}
