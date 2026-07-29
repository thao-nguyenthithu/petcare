import 'package:flutter/widgets.dart';
import 'package:petcare_app/features/pets/data/pet.dart';
import 'package:petcare_app/shared/utils/song_ngu.dart';

// Danh mục giống nuôi phổ biến tại Việt Nam
// Giống lưu bằng mã
class PetBreed {
  const PetBreed(this.ma, this.vi, this.en);

  final String ma;
  final String vi;
  final String en;
}

const maGiongKhac = 'khac';
const _giongKhac = PetBreed(maGiongKhac, 'Khác', 'Other');

const _giongCho = <PetBreed>[
  PetBreed('poodle', 'Poodle', 'Poodle'),
  PetBreed('phocSoc', 'Phốc sóc', 'Pomeranian'),
  PetBreed('phocHuou', 'Phốc hươu', 'Miniature Pinscher'),
  PetBreed('chihuahua', 'Chihuahua', 'Chihuahua'),
  PetBreed('corgi', 'Corgi', 'Welsh Corgi'),
  PetBreed('alaska', 'Alaska', 'Alaskan Malamute'),
  PetBreed('husky', 'Husky', 'Siberian Husky'),
  PetBreed('samoyed', 'Samoyed', 'Samoyed'),
  PetBreed('golden', 'Golden', 'Golden Retriever'),
  PetBreed('labrador', 'Labrador', 'Labrador Retriever'),
  PetBreed('pug', 'Pug', 'Pug'),
  PetBreed('shiba', 'Shiba', 'Shiba Inu'),
  PetBreed('akita', 'Akita', 'Akita'),
  PetBreed('beagle', 'Beagle', 'Beagle'),
  PetBreed('becgie', 'Becgie Đức', 'German Shepherd'),
  PetBreed('becgieBi', 'Becgie Bỉ', 'Belgian Malinois'),
  PetBreed('rottweiler', 'Rottweiler', 'Rottweiler'),
  PetBreed('doberman', 'Doberman', 'Doberman Pinscher'),
  PetBreed('dalmatian', 'Chó đốm', 'Dalmatian'),
  PetBreed('boxer', 'Boxer', 'Boxer'),
  PetBreed('bulldogAnh', 'Bulldog Anh', 'English Bulldog'),
  PetBreed('bulldogPhap', 'Bulldog Pháp', 'French Bulldog'),
  PetBreed('bostonTerrier', 'Boston Terrier', 'Boston Terrier'),
  PetBreed('yorkshire', 'Yorkshire Terrier', 'Yorkshire Terrier'),
  PetBreed('maltese', 'Maltese', 'Maltese'),
  PetBreed('bichon', 'Bichon Frise', 'Bichon Frise'),
  PetBreed('shihTzu', 'Shih Tzu', 'Shih Tzu'),
  PetBreed('lhasaApso', 'Lhasa Apso', 'Lhasa Apso'),
  PetBreed('bacKinh', 'Bắc Kinh', 'Pekingese'),
  PetBreed('nhatSpitz', 'Nhật', 'Japanese Spitz'),
  PetBreed('cavalier', 'Cavalier', 'Cavalier King Charles Spaniel'),
  PetBreed('cocker', 'Cocker Spaniel', 'Cocker Spaniel'),
  PetBreed('papillon', 'Papillon', 'Papillon'),
  PetBreed('borderCollie', 'Border Collie', 'Border Collie'),
  PetBreed('collie', 'Collie', 'Rough Collie'),
  PetBreed('ausShepherd', 'Chăn cừu Úc', 'Australian Shepherd'),
  PetBreed('greatDane', 'Ngao Đức', 'Great Dane'),
  PetBreed('saintBernard', 'Saint Bernard', 'Saint Bernard'),
  PetBreed('ngaoTayTang', 'Ngao Tây Tạng', 'Tibetan Mastiff'),
  PetBreed('ngaoAnh', 'Ngao Anh', 'English Mastiff'),
  PetBreed('caneCorso', 'Cane Corso', 'Cane Corso'),
  PetBreed('pitbull', 'Pit Bull', 'American Pit Bull Terrier'),
  PetBreed('americanBully', 'American Bully', 'American Bully'),
  PetBreed('greyhound', 'Greyhound', 'Greyhound'),
  PetBreed('whippet', 'Whippet', 'Whippet'),
  PetBreed('dachshund', 'Lạp xưởng', 'Dachshund'),
  PetBreed('basset', 'Basset Hound', 'Basset Hound'),
  PetBreed('schnauzer', 'Schnauzer', 'Schnauzer'),
  PetBreed('westie', 'Westie', 'West Highland White Terrier'),
  PetBreed('jackRussell', 'Jack Russell', 'Jack Russell Terrier'),
  PetBreed('foxTerrier', 'Fox Terrier', 'Fox Terrier'),
  PetBreed('chowChow', 'Chow Chow', 'Chow Chow'),
  PetBreed('sharpei', 'Sharpei', 'Shar Pei'),
  PetBreed('bernese', 'Bernese', 'Bernese Mountain Dog'),
  PetBreed('weimaraner', 'Weimaraner', 'Weimaraner'),
  PetBreed('phuQuoc', 'Phú Quốc', 'Phu Quoc Ridgeback'),
  PetBreed('hmongCoc', "H'Mông cộc đuôi", 'Hmong Bobtail'),
  PetBreed('bacHa', 'Bắc Hà', 'Bac Ha Dog'),
  PetBreed('lai', 'Chó lai', 'Mixed breed'),
  PetBreed('choCo', 'Chó cỏ', 'Vietnamese native dog'),
  _giongKhac,
];

const _giongMeo = <PetBreed>[
  PetBreed('meoTa', 'Mèo ta', 'Vietnamese domestic cat'),
  PetBreed('anhLongNgan', 'Anh lông ngắn', 'British Shorthair'),
  PetBreed('anhLongDai', 'Anh lông dài', 'British Longhair'),
  PetBreed('myLongNgan', 'Mỹ lông ngắn', 'American Shorthair'),
  PetBreed('myLongDai', 'Mỹ lông dài', 'American Longhair'),
  PetBreed('baTu', 'Ba Tư', 'Persian'),
  PetBreed('himalaya', 'Himalaya', 'Himalayan'),
  PetBreed('exotic', 'Exotic', 'Exotic Shorthair'),
  PetBreed('munchkin', 'Munchkin', 'Munchkin'),
  PetBreed('scottishFold', 'Tai cụp Scotland', 'Scottish Fold'),
  PetBreed('scottishStraight', 'Tai thẳng Scotland', 'Scottish Straight'),
  PetBreed('highlandFold', 'Highland Fold', 'Highland Fold'),
  PetBreed('maineCoon', 'Maine Coon', 'Maine Coon'),
  PetBreed('norwegian', 'Rừng Na Uy', 'Norwegian Forest Cat'),
  PetBreed('siberian', 'Siberia', 'Siberian'),
  PetBreed('ragdoll', 'Ragdoll', 'Ragdoll'),
  PetBreed('ragamuffin', 'RagaMuffin', 'RagaMuffin'),
  PetBreed('birman', 'Birman', 'Birman'),
  PetBreed('bengal', 'Bengal', 'Bengal'),
  PetBreed('savannah', 'Savannah', 'Savannah'),
  PetBreed('toyger', 'Toyger', 'Toyger'),
  PetBreed('ocicat', 'Ocicat', 'Ocicat'),
  PetBreed('egyptianMau', 'Ai Cập Mau', 'Egyptian Mau'),
  PetBreed('abyssinian', 'Abyssinian', 'Abyssinian'),
  PetBreed('somali', 'Somali', 'Somali'),
  PetBreed('xiem', 'Xiêm', 'Siamese'),
  PetBreed('oriental', 'Oriental', 'Oriental Shorthair'),
  PetBreed('balinese', 'Balinese', 'Balinese'),
  PetBreed('tonkinese', 'Tonkinese', 'Tonkinese'),
  PetBreed('burmese', 'Miến Điện', 'Burmese'),
  PetBreed('bombay', 'Bombay', 'Bombay'),
  PetBreed('russianBlue', 'Nga xanh', 'Russian Blue'),
  PetBreed('korat', 'Korat', 'Korat'),
  PetBreed('chartreux', 'Chartreux', 'Chartreux'),
  PetBreed('sphynx', 'Sphynx', 'Sphynx'),
  PetBreed('peterbald', 'Peterbald', 'Peterbald'),
  PetBreed('devonRex', 'Devon Rex', 'Devon Rex'),
  PetBreed('cornishRex', 'Cornish Rex', 'Cornish Rex'),
  PetBreed('selkirkRex', 'Selkirk Rex', 'Selkirk Rex'),
  PetBreed('laPerm', 'LaPerm', 'LaPerm'),
  PetBreed('americanCurl', 'American Curl', 'American Curl'),
  PetBreed('turkishAngora', 'Angora Thổ Nhĩ Kỳ', 'Turkish Angora'),
  PetBreed('turkishVan', 'Van Thổ Nhĩ Kỳ', 'Turkish Van'),
  PetBreed('chinchilla', 'Chinchilla', 'Chinchilla Persian'),
  PetBreed('manx', 'Manx', 'Manx'),
  PetBreed('japaneseBobtail', 'Nhật đuôi cộc', 'Japanese Bobtail'),
  PetBreed('kurilian', 'Kurilian Bobtail', 'Kurilian Bobtail'),
  PetBreed('singapura', 'Singapura', 'Singapura'),
  PetBreed('khaoManee', 'Khao Manee', 'Khao Manee'),
  PetBreed('ashera', 'Ashera', 'Ashera'),
  PetBreed('nebelung', 'Nebelung', 'Nebelung'),
  PetBreed('snowshoe', 'Snowshoe', 'Snowshoe'),
  PetBreed('meoRung', 'Mèo rừng lai', 'Wild hybrid cat'),
  PetBreed('meoLai', 'Mèo lai', 'Mixed breed'),
  _giongKhac,
];

// Tra nhanh theo mã
final Map<String, PetBreed> _theoMa = {
  for (final giong in [..._giongCho, ..._giongMeo]) giong.ma: giong,
};

List<PetBreed> giongTheoLoai(PetSpecies loai) =>
    loai == PetSpecies.dog ? _giongCho : _giongMeo;

// Tên giống theo ngôn ngữ đang dùng
String tenGiong(BuildContext context, String ma) {
  final giong = _theoMa[ma];
  if (giong == null) return ma;
  return tenSongNgu(context, vi: giong.vi, en: giong.en);
}
