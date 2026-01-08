import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/bookmark.dart';
import '../models/resep.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('resep_makanan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // Create resep table
    await db.execute('''
      CREATE TABLE resep (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        bahan TEXT NOT NULL,
        steps TEXT NOT NULL,
        image TEXT NOT NULL
      )
    ''');

    // Create bookmarks table
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        resep_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (resep_id) REFERENCES resep (id)
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    // Insert sample users
    await db.insert('users', {
      'name': 'Admin',
      'email': 'admin@example.com',
      'password': 'admin123',
    });

    // Insert sample recipes
    final sampleResep = [
      {
        'name': 'Nasi Goreng Spesial',
        'category': 'Olahan Nasi',
        'bahan':
            'Nasi 2 piring, Telur 2 butir, Bawang merah 3 siung, Bawang putih 2 siung, Kecap manis 2 sdm, Garam secukupnya, Merica secukupnya, Minyak goreng 2 sdm',
        'steps':
            '1. Panaskan minyak, tumis bawang merah dan bawang putih hingga harum\n2. Masukkan telur, orak-arik\n3. Tambahkan nasi, aduk rata\n4. Tambahkan kecap, garam, dan merica\n5. Masak hingga matang dan sajikan',
        'image':
            'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?w=400',
      },
      {
        'name': 'Soto Ayam Lamongan',
        'category': 'Sup & Soto',
        'bahan':
            'Ayam 500g, Bihun 200g, Tauge 100g, Bawang merah 5 siung, Bawang putih 3 siung, Kunyit 2cm, Jahe 1cm, Daun jeruk 3 lembar, Serai 2 batang, Garam secukupnya, Air 1.5L',
        'steps':
            '1. Rebus ayam hingga empuk, angkat dan suwir\n2. Tumis bumbu halus hingga harum\n3. Masukkan ke dalam kaldu ayam\n4. Rebus hingga mendidih, tambahkan garam\n5. Sajikan dengan bihun, tauge, dan suwiran ayam',
        'image':
            'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
      },
      {
        'name': 'Rendang Daging Sapi',
        'category': 'Olahan',
        'bahan':
            'Daging sapi 1kg, Santan 1L, Bawang merah 10 siung, Bawang putih 5 siung, Cabai merah 10 buah, Kunyit 3cm, Jahe 2cm, Lengkuas 3cm, Serai 3 batang, Daun jeruk 5 lembar, Garam secukupnya',
        'steps':
            '1. Tumis bumbu halus hingga harum\n2. Masukkan daging, aduk hingga berubah warna\n3. Tambahkan santan, masak dengan api kecil\n4. Masak hingga kuah mengental dan daging empuk\n5. Angkat dan sajikan',
        'image':
            'https://images.unsplash.com/photo-1558030006-450675393462?w=400',
      },
      {
        'name': 'Mie Goreng Jawa',
        'category': 'Olahan',
        'bahan':
            'Mie kuning 400g, Telur 2 butir, Bawang merah 5 siung, Bawang putih 3 siung, Cabai merah 3 buah, Kecap manis 3 sdm, Garam secukupnya, Minyak goreng 3 sdm',
        'steps':
            '1. Rebus mie hingga setengah matang, tiriskan\n2. Tumis bawang merah, bawang putih, dan cabai\n3. Masukkan telur, orak-arik\n4. Tambahkan mie, kecap, dan garam\n5. Aduk hingga rata dan sajikan',
        'image':
            'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
      },
    ];

    for (var resep in sampleResep) {
      await db.insert('resep', resep);
    }
  }

  // User operations
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User?> login(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user != null && user.password == password) {
      return user;
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      {'name': user.name, 'email': user.email, 'password': user.password},
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Resep operations
  Future<int> insertResep(Resep resep) async {
    final db = await database;
    return await db.insert('resep', {
      'name': resep.name,
      'category': resep.category,
      'bahan': resep.bahan,
      'steps': resep.steps,
      'image': resep.image,
    });
  }

  Future<List<Resep>> getAllResep() async {
    final db = await database;
    final maps = await db.query('resep', orderBy: 'id DESC');
    return maps.map((map) => Resep.fromMap(map)).toList();
  }

  Future<Resep?> getResepById(int id) async {
    final db = await database;
    final maps = await db.query('resep', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return Resep.fromMap(maps.first);
  }

  Future<List<Resep>> getResepByCategory(String category) async {
    final db = await database;
    final maps = await db.query(
      'resep',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'id DESC',
    );
    return maps.map((map) => Resep.fromMap(map)).toList();
  }

  Future<List<String>> getCategories() async {
    final db = await database;
    final maps = await db.rawQuery('SELECT DISTINCT category FROM resep');
    return maps.map((map) => map['category'] as String).toList();
  }

  Future<int> updateResep(Resep resep) async {
    final db = await database;
    return await db.update(
      'resep',
      {
        'name': resep.name,
        'category': resep.category,
        'bahan': resep.bahan,
        'steps': resep.steps,
        'image': resep.image,
      },
      where: 'id = ?',
      whereArgs: [resep.id],
    );
  }

  Future<int> deleteResep(int id) async {
    final db = await database;
    return await db.delete('resep', where: 'id = ?', whereArgs: [id]);
  }

  // Bookmark operations
  Future<int> insertBookmark(Bookmark bookmark) async {
  final db = await database;
  
  // Cek apakah bookmark sudah ada
  final existing = await isBookmarked(bookmark.userId, bookmark.resepId);
  if (existing) {
    // Jika sudah ada, kembalikan ID yang sudah ada
    final maps = await db.query(
      'bookmarks',
      where: 'user_id = ? AND resep_id = ?',
      whereArgs: [bookmark.userId, bookmark.resepId],
    );
    if (maps.isNotEmpty) {
      return maps.first['id'] as int;
    }
  }
  
  // Insert bookmark baru
  return await db.insert('bookmarks', {
    'user_id': bookmark.userId,
    'resep_id': bookmark.resepId,
    'created_at': bookmark.createdAt,
  });
}

  Future<List<Bookmark>> getBookmarksByUserId(int userId) async {
    final db = await database;
    final maps = await db.query(
      'bookmarks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Bookmark.fromMap(map)).toList();
  }

  Future<bool> isBookmarked(int userId, int resepId) async {
    final db = await database;
    final maps = await db.query(
      'bookmarks',
      where: 'user_id = ? AND resep_id = ?',
      whereArgs: [userId, resepId],
    );
    return maps.isNotEmpty;
  }

  Future<int> deleteBookmark(int userId, int resepId) async {
    final db = await database;
    return await db.delete(
      'bookmarks',
      where: 'user_id = ? AND resep_id = ?',
      whereArgs: [userId, resepId],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
