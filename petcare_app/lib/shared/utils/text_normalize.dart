import 'package:diacritic/diacritic.dart';

// Gõ không dấu vẫn tìm ra kết quả
String boDau(String chuoi) => removeDiacritics(chuoi);
