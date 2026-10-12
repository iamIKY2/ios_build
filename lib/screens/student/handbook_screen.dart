import 'package:flutter/material.dart';
import '../../models/handbook_article.dart';
import '../../widgets/handbook_card.dart';
import 'handbook_detail_screen.dart';
import '../../theme/app_theme.dart';

class HandbookScreen extends StatefulWidget {
  const HandbookScreen({super.key});

  @override
  State<HandbookScreen> createState() => _HandbookScreenState();
}

class _HandbookScreenState extends State<HandbookScreen> {
  final List<HandbookArticle> _articles = HandbookArticle.mockArticles;
  String _selectedCategory = 'Tất cả';
  final List<String> _categories = ['Tất cả', 'Ăn uống', 'Sức khỏe', 'Quyền lợi', 'Nhà trọ'];

  @override
  Widget build(BuildContext context) {
    final filteredArticles = _selectedCategory == 'Tất cả'
        ? _articles
        : _articles.where((a) => a.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cẩm Nang Thực Tập'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedCategory = cat);
                    },
                    selectedColor: AppTheme.primary,
                    checkmarkColor: Colors.white,
                    backgroundColor: AppTheme.surfaceColor(context),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.onSurface(context),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : AppTheme.borderColor(context),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Articles List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredArticles.length,
              itemBuilder: (context, index) {
                final article = filteredArticles[index];
                return HandbookCard(
                  key: ValueKey(article.id),
                  article: article,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HandbookDetailScreen(article: article),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
