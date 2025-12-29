import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/virtualPantry/ingredient_model.dart';
import '../../viewmodels/virtualPantry/pantry_viewmodel.dart';

class AddIngredientPage extends StatefulWidget {
  final Ingredient? ingredient;

  const AddIngredientPage({super.key, this.ingredient});

  @override
  State<AddIngredientPage> createState() => _AddIngredientPageState();
}

class _AddIngredientPageState extends State<AddIngredientPage> {
  late TextEditingController nameController;
  late TextEditingController quantityController;
  late TextEditingController dateController;

  DateTime? selectedDate;
  String? selectedCategoryId;
  String? selectedUnit;

  bool get isEditMode => widget.ingredient != null;

  // ===== Dropdown data =====
  final List<Map<String, String>> categories = [
    {'id': 'fruit', 'name': 'Trái cây'},
    {'id': 'vegetable', 'name': 'Rau củ'},
    {'id': 'meat', 'name': 'Thịt'},
    {'id': 'drink', 'name': 'Đồ uống'},
  ];

  final List<String> units = [
    'g',
    'kg',
    'ml',
    'l',
    'piece',
    'item',
    'box',
  ];

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: isEditMode ? widget.ingredient!.name : '');

    quantityController = TextEditingController(
        text: isEditMode
            ? widget.ingredient!.quantity.toString()
            : '');

    selectedCategoryId =
        isEditMode ? widget.ingredient!.categoryId : null;

    selectedUnit =
        isEditMode ? widget.ingredient!.unit : null;

    selectedDate =
        isEditMode ? widget.ingredient!.expirationDate : null;

    dateController = TextEditingController(
      text: selectedDate != null
          ? selectedDate!.toString().split(' ')[0]
          : '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = picked.toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0FDF4), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ===== Header =====
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      isEditMode ? 'Sửa nguyên liệu' : 'Thêm nguyên liệu',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Color(0xFF075B33),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // ===== Body =====
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // ===== Image =====
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/ingre.png',
                              width: 132,
                              height: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xFF00C850),
                            child: Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _inputField(
                        label: 'Tên nguyên liệu',
                        required: true,
                        controller: nameController,
                      ),
                      const SizedBox(height: 12),

                      // ===== Category dropdown (FULL WIDTH) =====
                      _dropdownField(
                        label: 'Danh mục',
                        value: selectedCategoryId,
                        items: categories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c['id'],
                                child: Text(c['name']!),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategoryId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _inputField(
                              label: 'Số lượng',
                              required: true,
                              controller: quantityController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _dropdownField(
                              label: 'Đơn vị',
                              value: selectedUnit,
                              items: units
                                  .map(
                                    (u) => DropdownMenuItem(
                                      value: u,
                                      child: Text(u),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedUnit = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _inputField(
                        label: 'Hạn sử dụng',
                        required: true,
                        controller: dateController,
                        suffix:
                            const Icon(Icons.calendar_today, size: 18),
                        onTap: () => _selectDate(context),
                      ),
                    ],
                  ),
                ),
              ),

              // ===== Footer =====
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF00C850),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          isEditMode
                              ? 'Lưu thay đổi'
                              : 'Thêm nguyên liệu',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Submit =====
  Future<void> _submit() async {
    if (nameController.text.isEmpty ||
        quantityController.text.isEmpty ||
        selectedCategoryId == null ||
        selectedUnit == null ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    final ingredient = Ingredient(
      id: isEditMode ? widget.ingredient!.id : '',
      name: nameController.text,
      categoryId: selectedCategoryId!,
      categoryName: categories
          .firstWhere((c) => c['id'] == selectedCategoryId)['name']!,
      quantity: double.parse(quantityController.text),
      unit: selectedUnit!,
      expirationDate: selectedDate!,
      imageUrl: 'assets/images/ingre.png',
    );

    final viewModel =
        Provider.of<PantryViewModel>(context, listen: false);

    if (isEditMode) {
      await viewModel.updateIngredient(widget.ingredient!.id, ingredient);
    } else {
      await viewModel.addIngredient(ingredient);
    }

    Navigator.pop(context);
  }

  // ===== Input Field =====
  Widget _inputField({
    required String label,
    bool required = false,
    required TextEditingController controller,
    Widget? suffix,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: _boxDecoration(),
            child: TextField(
              controller: controller,
              enabled: onTap == null,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Nhập $label',
                suffixIcon: suffix,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===== Dropdown Field (FULL WIDTH) =====
  Widget _dropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, true),
        const SizedBox(height: 6),
        Container(
          height: 50,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: _boxDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text('Chọn $label'),
              items: items,
              onChanged: onChanged,
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text, bool required) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF495565),
          ),
          children: [
            TextSpan(text: text),
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Color(0xFFFF383C)),
              ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: const Color(0xFFDCFCE7),
      border: Border.all(color: const Color(0xFF83F2AD)),
      borderRadius: BorderRadius.circular(16),
    );
  }
}
