import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/virtualPantry/pantry_viewmodel.dart';
import '../../models/virtualPantry/ingredient_model.dart';
import 'add_ingredients.dart';
class PantryPage extends StatefulWidget {
  const PantryPage({super.key});

  @override
  State<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
  @override
  void initState() {
    super.initState();
    // Tự động load ingredients khi mở màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<PantryViewModel>(context, listen: false);
      viewModel.loadIngredients();
    });
  }

  Widget ingredientSection(BuildContext context, String title, List<Ingredient> items, PantryViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF101727)),
        ),
        SizedBox(height: 12),
        Column(
          children: items.map((ingredient) => InkWell(
            onTap: () {
              // Có thể truyền ingredient thay vì Map
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddIngredientPage(
                    ingredient: ingredient, // Truyền Ingredient object
                  ),
                ),
              );
            },
            child: IngredientCard(
              name: ingredient.name,
              quantity: '${ingredient.quantity} ${ingredient.unit}',
              expiry: ingredient.expirationDate.toString().split(' ')[0], // Format date
              status: viewModel.getStatus(ingredient),
              color: _getStatusColor(viewModel.getStatus(ingredient)),
              image: ingredient.imageUrl,
            ),
          )).toList(),
        )
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Tươi':
        return Color(0xFF00A63D);
      case 'Sắp hết hạn':
        return Color(0xFFD08700);
      case 'Hết hạn':
        return Color(0xFFE7000A);
      default:
        return Colors.black;
    }
  }
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PantryViewModel>();

    // Lọc ingredients theo status
    final freshIngredients = viewModel.ingredients.where((i) => viewModel.getStatus(i) == 'Tươi').toList();
    final expiringIngredients = viewModel.ingredients.where((i) => viewModel.getStatus(i) == 'Sắp hết hạn').toList();
    final expiredIngredients = viewModel.ingredients.where((i) => viewModel.getStatus(i) == 'Hết hạn').toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF0FDF4),
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF00C850),
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddIngredientPage(),
              ),
            );
          },
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await viewModel.loadIngredients();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Kho nguyên liệu",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF101727)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Quản lý nguyên liệu của bạn",
                    style: TextStyle(
                        fontSize: 14.8,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF697282)),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _StatusCard(
                        count: freshIngredients.length.toString(),
                        label: 'Tươi',
                        bgColor: Colors.white,
                        textColor: Color(0xFF00A63D),
                      ),
                      SizedBox(width: 12),
                      _StatusCard(
                        count: expiringIngredients.length.toString(),
                        label: 'Sắp hết hạn',
                        bgColor: Color(0xFFFDFBE8),
                        textColor: Color(0xFFD08700),
                      ),
                      SizedBox(width: 12),
                      _StatusCard(
                        count: expiredIngredients.length.toString(),
                        label: 'Hết hạn',
                        bgColor: Color(0xFFFEF2F2),
                        textColor: Color(0xFFE7000A),
                      ),
                    ],
                  ),
                  if (freshIngredients.isNotEmpty)
                    ingredientSection(context, "Tươi", freshIngredients, viewModel),
                  if (expiringIngredients.isNotEmpty)
                    ingredientSection(context, "Sắp hết hạn", expiringIngredients, viewModel),
                  if (expiredIngredients.isNotEmpty)
                    ingredientSection(context, "Hết hạn", expiredIngredients, viewModel),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String count;
  final String label;
  final Color bgColor;
  final Color textColor;

  const _StatusCard({
    required this.count,
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(count, style: TextStyle(fontSize: 24, color: textColor)),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF495565)),
            ),
          ],
        ),
      ),
    );
  }
}
class IngredientCard extends StatelessWidget {
  final String name;
  final String quantity;
  final String expiry;
  final String status;
  final Color color;
  final String image;

  IngredientCard({
    required this.name,
    required this.quantity,
    required this.expiry,
    required this.status,
    required this.color,
    required this.image,
  });

  Color getBackgroundColor() {
    switch (status) {
      case 'Tươi':
        return Color(0xFFEFFAF1); // xanh nhạt
      case 'Sắp hết hạn':
        return Color(0xFFFFFBE8); // vàng nhạt
      case 'Hết hạn':
        return Color(0xFFFFF2F2); // đỏ nhạt
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      height: 76,
      decoration: BoxDecoration(
        color: getBackgroundColor(), // dùng màu nền theo status
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: image.startsWith('http') ? NetworkImage(image) : AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 14.8, color: Color(0xFF101727))),
                Text(status, style: TextStyle(fontSize: 10, color: color)),
                Text("Số lượng: $quantity", style: TextStyle(fontSize: 10, color: Color(0xFF495565))),
                Text("Hạn sử dụng: $expiry", style: TextStyle(fontSize: 10, color: Color(0xFF495565))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
