import 'package:latlong2/latlong.dart';

String soLeKm(double km) => km.toStringAsFixed(1).replaceAll('.', ',');

// Distance làm tròn kết quả nên phải đo bằng mét, đo thẳng ra km thì đoạn ngắn về 0
double kmTuLoTrinh(List<LatLng> diem) {
  const thuoc = Distance();
  var met = 0.0;
  for (var i = 1; i < diem.length; i++) {
    met += thuoc.as(LengthUnit.Meter, diem[i - 1], diem[i]);
  }
  return met / 1000;
}
