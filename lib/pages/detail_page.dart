import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/resep.dart';
import '../models/bookmark.dart';

class DetailPage extends StatefulWidget {
  final int resepId;
  final int? userId;

  const DetailPage({super.key, required this.resepId, this.userId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  static const Color mainRed = Color(0xffff565f);
  static const Color white = Color(0xffffffff);
  
  Resep? resep;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadResep();
    _checkBookmark();
  }

  Future<void> _loadResep() async {
    final resepData = await DatabaseService.instance.getResepById(widget.resepId);
    setState(() {
      resep = resepData;
    });
  }

  Future<void> _checkBookmark() async {
    if (widget.userId == null) return;
    
    final bookmarked = await DatabaseService.instance.isBookmarked(
      widget.userId!,
      widget.resepId,
    );
    setState(() {
      isBookmarked = bookmarked;
    });
  }

  Future<void> _toggleBookmark() async {
  if (widget.userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Silakan login terlebih dahulu')),
    );
    return;
  }

  try {
    if (isBookmarked) {
      // Hapus bookmark
      await DatabaseService.instance.deleteBookmark(
        widget.userId!,
        widget.resepId,
      );
      setState(() {
        isBookmarked = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dihapus dari favorit'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      // Tambah bookmark
      final now = DateTime.now().toIso8601String();
      
      // Cek dulu apakah sudah ada
      final alreadyBookmarked = await DatabaseService.instance.isBookmarked(
        widget.userId!,
        widget.resepId,
      );
      
      if (!alreadyBookmarked) {
        await DatabaseService.instance.insertBookmark(
          Bookmark(
            id: 0,
            userId: widget.userId!,
            resepId: widget.resepId,
            createdAt: now,
          ),
        );
      }
      
      setState(() {
        isBookmarked = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ditambahkan ke favorit'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  } catch (e) {
    // Tangani error
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    // Refresh status bookmark
    _checkBookmark();
  }
}

  @override
  Widget build(BuildContext context) {
    if (resep == null) {
      return Scaffold(
        backgroundColor: white,
        appBar: AppBar(
          title: const Text('Detail Resep'),
          backgroundColor: mainRed,
          foregroundColor: white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: Text(resep!.name),
        backgroundColor: mainRed,
        foregroundColor: white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.favorite : Icons.favorite_border,
              color: white,
            ),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  resep!.image,
                  fit: BoxFit.cover,
                  height: 250,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 100),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Bahan:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: mainRed,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                resep!.bahan,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                'Langkah:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: mainRed,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                resep!.steps,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
