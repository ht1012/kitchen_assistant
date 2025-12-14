import 'package:flutter/material.dart';
class add_ingre extends StatelessWidget {
  const add_ingre({super.key});

  @override
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.arrow_back),
                    Text(
                      'Thêm nguyên liệu',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFF075B33),
                      ),
                    ),
                    SizedBox(width: 24),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Image
                      Stack(
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
                          Positioned(
                            bottom: -8,
                            right: -8,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFF00C850),
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                          )
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
                              suffix: const Icon(Icons.keyboard_arrow_down),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _inputField(
                        label: 'Hạn sử dụng',
                        required: true,
                        suffix: const Icon(Icons.calendar_today),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

static Widget _inputField({
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
              const Expanded(child: SizedBox()),
              if (suffix != null) suffix,
            ],
          ),
        ),
      ],
    );
  }
}