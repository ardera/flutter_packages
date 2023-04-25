class TargetArch {
  const TargetArch(
    this.name,
    this.targetTriple, {
    String? gccDirName,
    this.aliases = const <String>[],
  }) : gccDirName = gccDirName ?? targetTriple;

  final String name;
  final List<String> aliases;
  final String targetTriple;
  final String gccDirName;

  static const arm = TargetArch('arm', 'arm-linux-gnueabihf');
  static const arm64 = TargetArch('arm64', 'aarch64-linux-gnu');
  static const i386 = TargetArch('i386', 'i386-linux-gnu', gccDirName: 'i686-linux-gnu', aliases: ['x86']);
  static const amd64 = TargetArch('amd64', 'x86_64-linux-gnu', aliases: ['x64']);

  static const values = <TargetArch>{arm, arm64, i386, amd64};

  factory TargetArch.forNameOrAlias(String nameOrAlias) {
    return values
        .singleWhere((element) => element.name == nameOrAlias || element.aliases.any((alias) => alias == nameOrAlias));
  }

  @override
  String toString() => 'TargetArch.$name';
}
