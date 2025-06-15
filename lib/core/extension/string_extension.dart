extension StringExtension on String? {
  String get nullOrEmpty => this ?? '';
  String toVerticalText() => this?.split(' ').join('\n') ?? '';

  bool get isYesOrOn =>
      this?.toLowerCase() == 'yes' || this?.toLowerCase() == 'on';

  int toSeconds() {
    if (this == null) return 0;
    try {
      final parts = this!.split(':');
      if (parts.length == 2) {
        final minutes = int.tryParse(parts[0]) ?? 0;
        final seconds = int.tryParse(parts[1]) ?? 0;
        return (minutes * 60) + seconds;
      }
    } catch (e) {
      // Hata durumunda varsayılan değer döndür
    }
    return 0;
  }

  int toInt() {
    if (this == null) return 0;
    return int.tryParse(this!) ?? 0;
  }

  double toDouble() {
    if (this == null) return 0.0;
    return double.tryParse(this!) ?? 0.0;
  }

  int toColor() {
    if (this == null) return 0;
    try {
      if (this!.startsWith('0x')) {
        return int.tryParse(this!) ?? 0;
      }
      return int.tryParse(this!.replaceAll('#', '0x')) ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
