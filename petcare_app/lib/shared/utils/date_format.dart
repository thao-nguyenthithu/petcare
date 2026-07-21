// Định dạng ngày kiểu Việt Nam: dd/mm/yyyy
String dinhDangNgay(DateTime ngay) =>
    '${ngay.day.toString().padLeft(2, '0')}/'
    '${ngay.month.toString().padLeft(2, '0')}/${ngay.year}';
