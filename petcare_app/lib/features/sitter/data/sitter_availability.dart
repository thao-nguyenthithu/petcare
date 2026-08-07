// Giờ rảnh của NCC

enum DayMode { macDinh, gioRieng, nghi }

extension DayModeApi on DayMode {
  // Mã gửi lên backend
  String get ma => switch (this) {
    DayMode.macDinh => 'default',
    DayMode.gioRieng => 'customHours',
    DayMode.nghi => 'off',
  };
}

DayMode dayModeTuMa(Object? ma) => switch (ma) {
  'customHours' => DayMode.gioRieng,
  'off' => DayMode.nghi,
  _ => DayMode.macDinh,
};

class DayAvailability {
  const DayAvailability({
    this.mode = DayMode.macDinh,
    this.start,
    this.end,
    required this.boardingSlots,
    this.boardingUsed = 0,
    this.lyDo,
  });

  final DayMode mode;
  final String? start;
  final String? end;
  final int boardingSlots;
  final int boardingUsed;
  final String? lyDo;

  bool get nghi => mode == DayMode.nghi;

  int get boardingLeft {
    final con = boardingSlots - boardingUsed;
    return con > 0 ? con : 0;
  }

  DayAvailability copyWith({
    DayMode? mode,
    String? start,
    String? end,
    int? boardingSlots,
    int? boardingUsed,
    String? lyDo,
  }) => DayAvailability(
    mode: mode ?? this.mode,
    start: start ?? this.start,
    end: end ?? this.end,
    boardingSlots: boardingSlots ?? this.boardingSlots,
    boardingUsed: boardingUsed ?? this.boardingUsed,
    lyDo: lyDo ?? this.lyDo,
  );

  factory DayAvailability.fromJson(Map<String, dynamic> j, int soChoMacDinh) =>
      DayAvailability(
        mode: dayModeTuMa(j['mode']),
        start: j['start'] as String?,
        end: j['end'] as String?,
        boardingSlots: (j['boardingSlots'] as num?)?.toInt() ?? soChoMacDinh,
        boardingUsed: (j['boardingUsed'] as num?)?.toInt() ?? 0,
        lyDo: j['reason'] as String?,
      );
}
