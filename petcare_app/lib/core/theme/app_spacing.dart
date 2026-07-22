// Thang khoảng cách dùng chung, giá trị đều là bội số 4.
// Đặt tên theo CÔNG DỤNG để đọc code là biết ngay chỗ đó nên dùng cái nào.
// Nhiều tên trùng giá trị là cố ý: sau này đổi lề màn sẽ không kéo theo padding
// trong card.
//
// Số đo RIÊNG của một widget (rộng card, đường kính avatar, cao ảnh bìa, vị trí
// một nhãn trên ảnh) giữ tại chính widget đó, KHÔNG đưa vào đây.
class AppSpacing {
  AppSpacing._();

  // 4 — giữa icon và chữ đi kèm, giữa hai dòng chữ dính nhau
  static const double textGap = 4;

  // 8 — giữa nhãn và ô nhập, giữa tiêu đề và mô tả của nó
  static const double labelGap = 8;

  // 12 — giữa các item cùng loại trong một danh sách
  static const double itemGap = 12;

  // 12 — giữa tiêu đề section và nội dung của section đó
  static const double titleGap = 12;

  // 16 — lề trái/phải nội dung trong màn
  static const double screenPadding = 16;

  // 16 — padding bên trong card, banner, ô
  static const double cardPadding = 16;

  // 16 — giữa các khối xếp chồng: card trong danh sách, trường nhập trong form.
  // Khối dày nên cần thở hơn itemGap vốn dành cho dòng list mỏng.
  static const double stackGap = 16;

  // 20 — giữa hai khối nội dung trong cùng một section
  static const double blockGap = 20;

  // 24 — lề trái/phải bản RỘNG, dùng cho bottom sheet và khối cần thoáng hơn
  static const double screenPaddingWide = 24;

  // 24 — giữa hai nhóm nội dung lớn
  static const double groupGap = 24;

  // 28 — giữa hai section lớn
  static const double sectionGap = 28;

  // 32 — đệm sát mép trên/dưới của màn
  static const double screenEdgeGap = 32;
}
