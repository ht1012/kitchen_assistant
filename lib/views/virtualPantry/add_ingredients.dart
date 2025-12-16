import 'package:flutter/material.dart';

class AddIngredientPage extends StatefulWidget {
  final Map<String, String>? ingredientData;

  const AddIngredientPage({super.key, this.ingredientData});

  @override
  State<AddIngredientPage> createState() => _AddIngredientPageState();
}

class _AddIngredientPageState extends State<AddIngredientPage> {
  late TextEditingController nameController;
  late TextEditingController quantityController;
  bool get isEditMode => widget.ingredientData != null;

  @override
  void initState(){
    super.initState();
    nameController = TextEditingController(
      text: isEditMode ? widget.ingredientData!['name'] : ""
    );
    quantityController = TextEditingController(
      text: isEditMode ? widget.ingredientData!['quantity'] : ""
    );
  }
  
  Widget build(BuildContext context) {
    return Scaffold(
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
                    const Text(
                      'Thêm nguyên liệu',
                      style: TextStyle(
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
                      // Image
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
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF00C850),
                            child:
                                const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _inputField(label: 'Tên nguyên liệu', required: true),
                      const SizedBox(height: 12),

                      _inputField(
                        label: 'Danh mục',
                        required: true,
                        suffix: const Icon(Icons.keyboard_arrow_down),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _inputField(
                              label: 'Số lượng',
                              required: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _inputField(
                              label: 'Đơn vị',
                              required: true,
                              suffix:
                                  const Icon(Icons.keyboard_arrow_down),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _inputField(
                        label: 'Hạn sử dụng',
                        required: true,
                        suffix:
                            const Icon(Icons.calendar_today, size: 18),
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
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF00C850),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Thêm nguyên liệu'),
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

  // ===== Input Field =====
  Widget _inputField({
    required String label,
    bool required = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF495565),
              ),
              children: [
                TextSpan(text: label),
                if (required)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Color(0xFFFF383C)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            border: Border.all(color: const Color(0xFF83F2AD)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (suffix != null) suffix,
            ],
          ),
        ),
      ],
    );
  }
}
