/// Uma data importante do casal.
/// - [recurring] = true  → recorre todo ano (aniversário, 1º beijo…).
/// - [recurring] = false → contagem regressiva pra uma data futura única
///   (casamento, reencontro…).
class CoupleDate {
  const CoupleDate(this.id, this.name, this.date,
      {this.emoji = '💗', this.recurring = true});

  final String id;
  final String name;
  final DateTime date;
  final String emoji;
  final bool recurring;

  /// Dias até a próxima ocorrência (recorrente) ou até a data (regressiva).
  int daysUntilNext([DateTime? from]) {
    final now = from ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (!recurring) {
      final target = DateTime(date.year, date.month, date.day);
      return target.difference(today).inDays; // pode ser 0 ou negativo
    }
    var next = DateTime(today.year, date.month, date.day);
    if (next.isBefore(today)) next = DateTime(today.year + 1, date.month, date.day);
    return next.difference(today).inDays;
  }

  String serialize() =>
      '$id|$name|${date.millisecondsSinceEpoch}|$emoji|${recurring ? 1 : 0}';

  static CoupleDate? parse(String s) {
    final p = s.split('|');
    if (p.length < 3) return null;
    return CoupleDate(
      p[0],
      p[1],
      DateTime.fromMillisecondsSinceEpoch(int.tryParse(p[2]) ?? 0),
      emoji: p.length > 3 ? p[3] : '💗',
      recurring: p.length > 4 ? p[4] == '1' : true,
    );
  }
}
