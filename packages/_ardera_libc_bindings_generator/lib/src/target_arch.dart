class TargetArch {
  const TargetArch.smallLong(
    this.name,
    this.targetTriple, {
    String? gccDirName,
    this.aliases = const <String>[],
  })  : this.gccDirName = gccDirName ?? targetTriple,
        this.charSize = 1,
        this.unsignedCharSize = 1,
        this.shortSize = 2,
        this.unsignedShortSize = 2,
        this.intSize = 4,
        this.unsignedIntSize = 4,
        this.longSize = 4,
        this.unsignedLongSize = 4,
        this.longLongSize = 8,
        this.unsignedLongLongSize = 8,
        this.enumSize = 4;

  const TargetArch.largeLong(
    this.name,
    this.targetTriple, {
    String? gccDirName,
    this.aliases = const <String>[],
  })  : this.gccDirName = gccDirName ?? targetTriple,
        this.charSize = 1,
        this.unsignedCharSize = 1,
        this.shortSize = 2,
        this.unsignedShortSize = 2,
        this.intSize = 4,
        this.unsignedIntSize = 4,
        this.longSize = 8,
        this.unsignedLongSize = 8,
        this.longLongSize = 8,
        this.unsignedLongLongSize = 8,
        this.enumSize = 4;

  final String name;
  final List<String> aliases;
  final String targetTriple;
  final String gccDirName;
  final int charSize;
  final int unsignedCharSize;
  final int shortSize;
  final int unsignedShortSize;
  final int intSize;
  final int unsignedIntSize;
  final int longSize;
  final int unsignedLongSize;
  final int longLongSize;
  final int unsignedLongLongSize;
  final int enumSize;

  static const arm = TargetArch.smallLong('arm', 'arm-linux-gnueabihf');
  static const arm64 = TargetArch.largeLong('arm64', 'aarch64-linux-gnu');
  static const i386 = TargetArch.smallLong('i386', 'i386-linux-gnu',
      gccDirName: 'i686-linux-gnu', aliases: ['x86']);
  static const amd64 =
      TargetArch.largeLong('amd64', 'x86_64-linux-gnu', aliases: ['x64']);
  static const mips =
      TargetArch.smallLong('mips', 'mipsel-linux-gnu', aliases: ['mipsel']);
  static const mips64el = TargetArch.largeLong(
      'mips64el', 'mips64el-linux-gnuabi64',
      aliases: ['mips64']);

  static const values = <TargetArch>{arm, arm64, i386, amd64, mips, mips64el};

  factory TargetArch.forNameOrAlias(String nameOrAlias) {
    return values.singleWhere((element) =>
        element.name == nameOrAlias ||
        element.aliases.any((alias) => alias == nameOrAlias));
  }

  String toString() => 'TargetArch.$name';
}
