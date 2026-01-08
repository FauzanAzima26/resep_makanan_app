import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/resep.dart';
import 'detail_page.dart';
import 'home_page.dart';
import 'category_page.dart';
import 'profile_page.dart';

class FavoritPage extends StatefulWidget {
  final int? userId;

  const FavoritPage({super.key, this.userId});

  @override
  State<FavoritPage> createState() => _FavoritPageState();
}

class _FavoritPageState extends State<FavoritPage> {
  static const Color mainRed = Color(0xffff565f);
  static const Color white = Color(0xffffffff);

  List<Resep> bookmarkedResep = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    if (widget.userId == null) {
      setState(() {
        bookmarkedResep = [];
      });
      return;
    }

    final bookmarks = await DatabaseService.instance.getBookmarksByUserId(
      widget.userId!,
    );
    final resepList = <Resep>[];

    for (var bookmark in bookmarks) {
      final resep = await DatabaseService.instance.getResepById(
        bookmark.resepId,
      );
      if (resep != null) {
        resepList.add(resep);
      }
    }

    setState(() {
      bookmarkedResep = resepList;
    });
  }

  String getDifficulty(int index) {
    if (index % 3 == 0) return 'Mudah';
    if (index % 3 == 1) return 'Sedang';
    return 'Sulit';
  }

  Color getDifficultyColor(String difficulty) {
    if (difficulty == 'Mudah') return Colors.green;
    if (difficulty == 'Sedang') return Colors.orange;
    return Colors.red;
  }

  int getPreparationTime(int index) {
    return 30 + (index * 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: const Text('Favorit'),
        backgroundColor: mainRed,
        foregroundColor: white,
        elevation: 0,
      ),
      body: bookmarkedResep.isEmpty
          ? const Center(
              child: Text(
                'Belum ada favorit',
                style: TextStyle(
                  color: mainRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: bookmarkedResep.length,
              itemBuilder: (context, index) {
                final resep = bookmarkedResep[index];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(
                          resepId: resep.id,
                          userId: widget.userId,
                        ),
                      ),
                    );
                    _loadBookmarks(); // Reload after returning from detail
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            resep.image,
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 120,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 50),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resep.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${getPreparationTime(index)} menit',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    size: 14,
                                    color: getDifficultyColor(
                                      getDifficulty(index),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    getDifficulty(index),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: getDifficultyColor(
                                        getDifficulty(index),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 2,
          backgroundColor: white,
          selectedItemColor: mainRed,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomePage(userId: widget.userId),
                ),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryPage(userId: widget.userId),
                ),
              );
            } else if (index == 2) {
              // Already on favorit page
            } else if (index == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePage(userId: widget.userId),
                ),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view),
              label: 'Kategori',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: 'Favorit',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
