import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/local_storage.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Product>> _futureFavs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _futureFavs = LocalStorage.getFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: FutureBuilder<List<Product>>(
        future: _futureFavs,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final favs = snapshot.data!;
          if (favs.isEmpty) {
            return const Center(child: Text('No favorites saved yet'));
          }
          return ListView.builder(
            itemCount: favs.length,
            itemBuilder: (context, i) {
              final p = favs[i];
              return ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: Text(p.title),
                subtitle: Text('€${p.price.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await LocalStorage.removeFavorite(p.id);
                    _load();
                  },
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen(product: p)),
                  );
                  _load();
                },
              );
            },
          );
        },
      ),
    );
  }
}