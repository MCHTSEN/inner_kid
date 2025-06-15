extension ListExtension on List? {
  List<T> toList<T>() {
    if (this == null) return [];
    return List<T>.from(this!);
  }

  List<String> toStringList() {
    if (this == null) return [];
    return this!.map((e) => e.toString()).toList();
  }

  List<int> toColorList() {
    if (this == null) return [];
    return this!.map((e) {
      if (e is String) {
        if (e.startsWith('0x')) {
          return int.tryParse(e) ?? 0;
        }
        return int.tryParse(e.replaceAll('#', '0x')) ?? 0;
      }
      return 0;
    }).toList();
  }
}
