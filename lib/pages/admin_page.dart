import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/resep.dart';
import '../models/user.dart';

class AdminPage extends StatefulWidget {
  final int? userId; // Tambahkan parameter userId

  const AdminPage({super.key, this.userId});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  static const Color mainRed = Color(0xffff565f);
  static const Color white = Color(0xffffffff);

  List<Resep> resepList = [];
  bool isLoading = true;
  String searchQuery = '';
  bool isAdmin = false; // Tambahkan variabel ini
  User? currentUser; // Tambahkan variabel ini

  @override
  void initState() {
    super.initState();
    _checkAdminAccess(); // Ubah dari _loadResep() ke _checkAdminAccess()
  }

  Future<void> _checkAdminAccess() async {
    if (widget.userId != null) {
      final user = await DatabaseService.instance.getUserById(widget.userId!);
      setState(() {
        currentUser = user;
        // Check if user is admin (email contains 'admin')
        isAdmin = user?.email.toLowerCase().contains('admin') ?? false;
      });

      if (!isAdmin) {
        // Jika bukan admin, tampilkan pesan dan kembali
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Akses ditolak. Hanya admin yang dapat mengakses halaman ini.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
        return;
      }
    } else {
      // Jika tidak ada userId, kembalikan ke halaman sebelumnya
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda harus login terlebih dahulu.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    _loadResep();
  }

  Future<void> _loadResep() async {
    setState(() {
      isLoading = true;
    });
    final resep = await DatabaseService.instance.getAllResep();
    setState(() {
      resepList = resep;
      isLoading = false;
    });
  }

  List<Resep> get filteredResep {
    if (searchQuery.isEmpty) {
      return resepList;
    }
    return resepList.where((resep) {
      return resep.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          resep.category.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _showAddEditDialog({Resep? resep}) async {
    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Akses ditolak. Hanya admin yang dapat menambah/mengedit resep.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final nameController = TextEditingController(text: resep?.name ?? '');
    final categoryController = TextEditingController(
      text: resep?.category ?? '',
    );
    final bahanController = TextEditingController(text: resep?.bahan ?? '');
    final stepsController = TextEditingController(text: resep?.steps ?? '');
    final imageController = TextEditingController(text: resep?.image ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(resep == null ? 'Tambah Resep' : 'Edit Resep'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Resep *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Kategori *',
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: Olahan Nasi, Sup & Soto',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bahanController,
                decoration: const InputDecoration(
                  labelText: 'Bahan-bahan *',
                  border: OutlineInputBorder(),
                  hintText: 'Pisahkan dengan koma',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stepsController,
                decoration: const InputDecoration(
                  labelText: 'Langkah-langkah *',
                  border: OutlineInputBorder(),
                  hintText: 'Pisahkan setiap langkah dengan baris baru',
                ),
                maxLines: 6,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar *',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainRed),
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  categoryController.text.isEmpty ||
                  bahanController.text.isEmpty ||
                  stepsController.text.isEmpty ||
                  imageController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua field harus diisi')),
                );
                return;
              }

              if (resep == null) {
                // Add new
                await DatabaseService.instance.insertResep(
                  Resep(
                    id: 0,
                    name: nameController.text,
                    category: categoryController.text,
                    bahan: bahanController.text,
                    steps: stepsController.text,
                    image: imageController.text,
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Resep berhasil ditambahkan')),
                );
              } else {
                // Update existing
                await DatabaseService.instance.updateResep(
                  Resep(
                    id: resep.id,
                    name: nameController.text,
                    category: categoryController.text,
                    bahan: bahanController.text,
                    steps: stepsController.text,
                    image: imageController.text,
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Resep berhasil diperbarui')),
                );
              }
              Navigator.pop(context);
              _loadResep();
            },
            child: const Text('Simpan', style: TextStyle(color: white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteResep(Resep resep) async {
    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Akses ditolak. Hanya admin yang dapat menghapus resep.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Resep'),
        content: Text('Apakah Anda yakin ingin menghapus "${resep.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService.instance.deleteResep(resep.id);
      _loadResep();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Resep berhasil dihapus')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isAdmin && currentUser != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Akses Ditolak'),
          backgroundColor: mainRed,
          foregroundColor: white,
        ),
        body: const Center(
          child: Text('Anda tidak memiliki akses ke halaman ini.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: const Text('Admin - Kelola Resep'),
        backgroundColor: mainRed,
        foregroundColor: white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari resep...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: mainRed.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '${resepList.length}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: mainRed,
                            ),
                          ),
                          const Text(
                            'Total Resep',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.green.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '${resepList.map((r) => r.category).toSet().length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Text(
                            'Kategori',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Resep List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: mainRed))
                : filteredResep.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          searchQuery.isEmpty
                              ? Icons.restaurant_menu
                              : Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty
                              ? 'Belum ada resep'
                              : 'Tidak ada resep yang ditemukan',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadResep,
                    color: mainRed,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredResep.length,
                      itemBuilder: (context, index) {
                        final resep = filteredResep[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                resep.image,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image),
                                  );
                                },
                              ),
                            ),
                            title: Text(
                              resep.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: mainRed.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    resep.category,
                                    style: TextStyle(
                                      color: mainRed,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () =>
                                      _showAddEditDialog(resep: resep),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteResep(resep),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: mainRed,
              onPressed: () => _showAddEditDialog(),
              icon: const Icon(Icons.add, color: white),
              label: const Text('Tambah Resep', style: TextStyle(color: white)),
            )
          : null, // Sembunyikan FAB jika bukan admin
    );
  }
}
