import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/virtualPantry/ingredient_model.dart';
import '../../viewmodels/virtualPantry/pantry_viewmodel.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


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

  File? _image;
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        final file = File(photo.path);
        
        // Kiểm tra file có tồn tại không
        if (await file.exists()) {
          setState(() {
            _image = file;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể lưu ảnh. Vui lòng thử lại.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chụp ảnh: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                            child: Image(
                              image: _image != null
                                  ? FileImage(_image!)
                                  : const AssetImage('assets/images/ingre.png')
                                      as ImageProvider,
                              width: 132,
                              height: 130,
                              fit: BoxFit.cover,
                            ),
                          ),

                          GestureDetector(
                            onTap: _takePhoto, // 👈 BẤM LÀ MỞ CAMERA
                            child: const CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0xFF00C850),
                              child: Icon(Icons.add, color: Colors.white),
                            ),
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

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    String imageUrl = 'assets/images/ingre.png'; // Default image

    // Upload image if selected
    if (_image != null) {
      try {
        // Kiểm tra file có tồn tại không
        final fileExists = await _image!.exists();
        if (!fileExists) {
          throw Exception('File ảnh không tồn tại tại đường dẫn: ${_image!.path}');
        }

        // Kiểm tra file có thể đọc được không
        final fileLength = await _image!.length();
        if (fileLength == 0) {
          throw Exception('File ảnh rỗng hoặc không thể đọc được');
        }

        // Tạo reference với tên file unique
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final randomId = timestamp.toString();
        final fileName = 'ingredients/$randomId.jpg';
        
        // Chỉ định storage bucket rõ ràng
        final storageRef = FirebaseStorage.instance
            .ref()
            .child(fileName);

        // Upload file với metadata
        final uploadTask = storageRef.putFile(
          _image!,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'uploadedAt': DateTime.now().toIso8601String(),
            },
          ),
        );

        // Đợi upload hoàn thành
        final snapshot = await uploadTask;
        
        // Kiểm tra upload có thành công không
        if (snapshot.state != TaskState.success) {
          throw Exception('Upload không thành công. Trạng thái: ${snapshot.state}');
        }
        
        // Đợi một chút để đảm bảo file đã được xử lý trên server
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Lấy download URL từ snapshot reference (đảm bảo dùng đúng reference)
        imageUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        Navigator.pop(context); // Close loading
        String errorMessage = 'Lỗi upload ảnh không xác định';
        
        if (e.toString().contains('File ảnh không tồn tại')) {
          errorMessage = 'Không tìm thấy file ảnh. Vui lòng chụp ảnh lại hoặc kiểm tra quyền truy cập file.';
        } else if (e.toString().contains('File ảnh rỗng')) {
          errorMessage = 'File ảnh bị lỗi. Vui lòng chụp ảnh lại.';
        } else if (e.toString().contains('PERMISSION_DENIED') || 
            e.toString().contains('permission-denied')) {
          errorMessage = 'Lỗi quyền truy cập: Vui lòng kiểm tra Firebase Storage Rules';
        } else if (e.toString().contains('object-not-found') || 
                   e.toString().contains('not-found')) {
          errorMessage = 'Lỗi: Không tìm thấy file trên server. Có thể do Firebase Storage Rules chưa được cấu hình. Vui lòng kiểm tra Storage Rules trong Firebase Console.';
        } else if (e.toString().contains('UNAVAILABLE') || 
                   e.toString().contains('unavailable')) {
          errorMessage = 'Lỗi kết nối: Vui lòng kiểm tra kết nối internet';
        } else {
          errorMessage = 'Lỗi upload ảnh: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }
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
      imageUrl: imageUrl,
      householdId: isEditMode ? widget.ingredient!.householdId : '', // householdId sẽ được cập nhật trong service
    );

    final viewModel =
        Provider.of<PantryViewModel>(context, listen: false);

    try {
      if (isEditMode) {
        await viewModel.updateIngredient(widget.ingredient!.id, ingredient);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật nguyên liệu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await viewModel.addIngredient(ingredient);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm nguyên liệu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      Navigator.pop(context); // Close loading
      Navigator.pop(context); // Close add page
    } catch (e) {
      Navigator.pop(context); // Close loading
      String errorMessage = 'Lỗi không xác định';
      
      if (e.toString().contains('PERMISSION_DENIED') || 
          e.toString().contains('permission-denied')) {
        errorMessage = 'Lỗi quyền truy cập: Vui lòng kiểm tra Firestore Security Rules';
      } else if (e.toString().contains('UNAVAILABLE') || 
                 e.toString().contains('unavailable')) {
        errorMessage = 'Lỗi kết nối: Vui lòng kiểm tra kết nối internet';
      } else if (e.toString().contains('NOT_FOUND') || 
                 e.toString().contains('not-found')) {
        errorMessage = 'Không tìm thấy tài liệu cần cập nhật';
      } else {
        errorMessage = 'Lỗi: ${e.toString()}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
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
