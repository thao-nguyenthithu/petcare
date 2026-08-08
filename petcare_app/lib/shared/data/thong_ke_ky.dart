class ThongKeCot {
  const ThongKeCot({
    required this.label,
    required this.amount,
    this.upcoming = false,
  });

  final String label;
  final int amount;
  final bool upcoming;
}

class ThongKeKy {
  const ThongKeKy({
    required this.rangeLabel,
    required this.total,
    required this.changePercent,
    required this.ordersDone,
    required this.hoursWorked,
    required this.chartTitle,
    required this.bars,
    required this.highlightBar,
  });

  final String rangeLabel;
  final int total;
  final int changePercent;
  final int ordersDone;
  final String hoursWorked;
  final String chartTitle;
  final List<ThongKeCot> bars;
  final int highlightBar;
}
