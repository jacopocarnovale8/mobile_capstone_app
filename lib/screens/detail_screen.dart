import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/local_storage.dart';

class DetailScreen extends StatefulWidget {
  final Product product;
  const DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    LocalStorage.isFavorite(widget.product.id).then((fav) {
      if (mounted) setState(() => _isFavorite = fav);
    });
  }

  Future<void> _toggleFavorite() async {
    final nowFav = await LocalStorage.toggleFavorite(widget.product);
    if (!mounted) return;
    setState(() => _isFavorite = nowFav);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(nowFav
            ? 'Added to favorites (saved locally)'
            : 'Removed from favorites'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      appBar: AppBar(
        title: Text(p.title),
        actions: [
          IconButton(
            tooltip: 'Favorite',
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            color: _isFavorite ? Colors.red : null,
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              p.thumbnail,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
              const SizedBox(height: 240, child: Icon(Icons.image)),
            ),
          ),
          const SizedBox(height: 16),
          Text(p.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(label: Text(p.category)),
              const SizedBox(width: 8),
              const Icon(Icons.star, color: Colors.amber, size: 20),
              Text(p.rating.toStringAsFixed(1)),
              const Spacer(),
              Text(
                '€${p.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(p.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _toggleFavorite,
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            label: Text(
                _isFavorite ? 'Remove from favorites' : 'Add to favorites'),
          ),
        ],
      ),
    );
  }
}