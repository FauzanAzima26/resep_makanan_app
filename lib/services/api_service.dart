import '../models/resep.dart';

class ApiService {
  static List<Resep> dataResep = [
    Resep(
      id: 1,
      name: 'Nasi Goreng',
      category: 'Makanan',
      bahan: 'Nasi, Telur, Bawang',
      steps: 'Tumis bawang, masukkan telur, masukkan nasi',
      image: 'https://picsum.photos/200',
    ),
    Resep(
      id: 2,
      name: 'Es Teh',
      category: 'Minuman',
      bahan: 'Teh, Gula, Es',
      steps: 'Seduh teh, tambahkan gula dan es',
      image: 'https://picsum.photos/201',
    ),
  ];

  static List<Resep> getResep() => dataResep;

  static Resep getDetail(int id) =>
      dataResep.firstWhere((e) => e.id == id);

  static List<Resep> getByCategory(String category) =>
      dataResep.where((e) => e.category == category).toList();
}
