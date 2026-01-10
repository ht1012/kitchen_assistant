import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/virtualPantry/ingredient_model.dart';
import '../../viewmodels/virtualPantry/pantry_viewmodel.dart';
import '../../services/virtualPantry/barcode_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'qr_scanner_page.dart';


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

    // Load categories từ Firebase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<PantryViewModel>(context, listen: false);
      viewModel.loadCategories();
    });
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

  Future<void> _scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerPage(),
      ),
    );
    
    if (result != null && result is Map<String, dynamic>) {
      debugPrint('📦 Kết quả từ scanner: $result');
      // Kiểm tra nếu là barcode (chỉ có số), tự động tra cứu
      if (result.containsKey('barcode')) {
        final barcode = result['barcode'] as String;
        debugPrint('🔍 Phát hiện barcode: $barcode, bắt đầu tra cứu...');
        await _lookupBarcode(barcode);
      } else {
        debugPrint('📝 Không phải barcode, xử lý như QR code thông thường');
        _handleQRResult(result);
      }
    } else {
      debugPrint('❌ Không có kết quả từ scanner');
    }
  }

  Future<void> _lookupBarcode(String barcode) async {
    // Hiển thị loading
    if (!mounted) return;
    
    // Thông báo đã quét được mã vạch
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã quét được mã vạch: $barcode. Đang tra cứu thông tin...'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      debugPrint('Bắt đầu tra cứu barcode: $barcode');
      final productData = await BarcodeService.lookupBarcode(barcode);
      debugPrint('Kết quả tra cứu: $productData');
      
      if (productData != null) {
        // Điền thông tin vào form
        if (productData['name'] != null) {
          nameController.text = productData['name'] as String;
        }
        
        if (productData['quantity'] != null && (productData['quantity'] as String).isNotEmpty) {
          quantityController.text = productData['quantity'] as String;
        }
        
        if (productData['unit'] != null && units.contains(productData['unit'])) {
          setState(() {
            selectedUnit = productData['unit'] as String;
          });
        }
        
        // Barcode service trả về categoryId, kiểm tra xem có trong Firebase categories không
        if (productData['categoryId'] != null) {
          final categoryId = productData['categoryId'] as String;
          final viewModel = Provider.of<PantryViewModel>(context, listen: false);
          // Kiểm tra categoryId có tồn tại trong Firebase categories không
          final categoryExists = viewModel.categories.any(
            (c) => c.categoryId == categoryId,
          );
          if (categoryExists) {
            setState(() {
              selectedCategoryId = categoryId;
            });
          }
        }

        if (mounted) {
          Navigator.pop(context); // Đóng loading
          
          final productName = productData['name'] as String;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(productName != barcode 
                  ? 'Đã tra cứu thông tin sản phẩm: $productName'
                  : 'Đã tra cứu barcode nhưng thông tin hạn chế'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Không tìm thấy sản phẩm trong database Open Food Facts
        if (mounted) {
          Navigator.pop(context); // Đóng loading
          
          // Chỉ điền mã vạch vào tên
          nameController.text = barcode;
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã quét được mã vạch: $barcode\nVui lòng nhập thông tin sản phẩm.'),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Đóng loading
        nameController.text = barcode;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tra cứu: ${e.toString().length > 50 ? e.toString().substring(0, 50) + "..." : e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleQRResult(Map<String, dynamic> qrData) {
    // Điền thông tin từ QR code vào form
    if (qrData.containsKey('name')) {
      nameController.text = (qrData['name'] ?? '').toString();
    }
    
    if (qrData.containsKey('quantity')) {
      quantityController.text = qrData['quantity'].toString();
    }
    
    if (qrData.containsKey('unit')) {
      final unit = (qrData['unit'] ?? '').toString();
      if (units.contains(unit)) {
        setState(() {
          selectedUnit = unit;
        });
      }
    }
    
    // Hỗ trợ categoryId hoặc categoryName từ QR code
    final viewModel = Provider.of<PantryViewModel>(context, listen: false);
    
    if (qrData.containsKey('categoryId')) {
      final categoryId = (qrData['categoryId'] ?? '').toString();
      // Kiểm tra categoryId có tồn tại trong Firebase categories không
      final categoryExists = viewModel.categories.any(
        (c) => c.categoryId == categoryId,
      );
      if (categoryExists) {
        setState(() {
          selectedCategoryId = categoryId;
        });
      }
    } else if (qrData.containsKey('categoryName')) {
      final categoryName = (qrData['categoryName'] ?? '').toString().toLowerCase();
      // Tìm category theo name (không phân biệt hoa thường)
      final matched = viewModel.categories.firstWhere(
        (c) => c.categoryName.toLowerCase() == categoryName,
        orElse: () => viewModel.categories.isNotEmpty 
            ? viewModel.categories.first 
            : throw StateError('No categories'),
      );
      if (viewModel.categories.isNotEmpty) {
        setState(() {
          selectedCategoryId = matched.categoryId;
        });
      }
    }
    
    if (qrData.containsKey('expirationDate')) {
      try {
        final dateStr = (qrData['expirationDate'] ?? '').toString();
        final date = DateTime.parse(dateStr);
        setState(() {
          selectedDate = date;
          dateController.text = date.toString().split(' ')[0];
        });
      } catch (e) {
        // Ignore date parsing errors
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã điền thông tin từ QR code'),
          backgroundColor: Colors.green,
        ),
      );
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
                      isEditMode ? 'Cập nhật hạn sử dụng' : 'Thêm nguyên liệu',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Color(0xFF075B33),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.qr_code_scanner,
                        color: isEditMode
                            ? const Color(0xFF9CA3AF) // xám khi disable
                            : const Color(0xFF075B33),
                        size: 28,
                      ),
                      onPressed: isEditMode ? null : _scanQRCode,
                    ),
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
                                  : (isEditMode &&
                                          widget.ingredient!.imageUrl.isNotEmpty &&
                                          widget.ingredient!.imageUrl.startsWith('http')
                                      ? NetworkImage(widget.ingredient!.imageUrl)
                                      : const AssetImage('assets/images/ingre.png'))
                                      as ImageProvider,
                              width: 132,
                              height: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (!isEditMode)
                            GestureDetector(
                              onTap: _takePhoto,
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
                        readOnly: isEditMode,
                      ),
                      const SizedBox(height: 12),

                      // ===== Category dropdown (FULL WIDTH) =====
                      Consumer<PantryViewModel>(
                        builder: (context, viewModel, child) {
                          if (viewModel.isLoadingCategories) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (viewModel.categories.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Chưa có danh mục. Vui lòng thêm danh mục trong Firebase.',
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          return _dropdownField(
                            label: 'Danh mục',
                            value: selectedCategoryId,
                            items: viewModel.categories
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category.categoryId,
                                    child: Text(category.categoryName),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategoryId = value;
                              });
                            },
                            enabled: !isEditMode,
                          );
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
                              readOnly: isEditMode,
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
                              enabled: !isEditMode,
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
                              ? 'Cập nhật'
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
          const SnackBar(
            content: Text('Vui lòng điền đầy đủ thông tin'),
            backgroundColor: Colors.red,
          ),
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

    final viewModel =
        Provider.of<PantryViewModel>(context, listen: false);

    // Tìm categoryName từ categoryId
    final selectedCategory = viewModel.categories.firstWhere(
      (c) => c.categoryId == selectedCategoryId,
      orElse: () => viewModel.categories.first, // Fallback nếu không tìm thấy
    );

    final ingredient = Ingredient(
      id: isEditMode ? widget.ingredient!.id : '',
      name: nameController.text,
      categoryId: selectedCategoryId!,
      categoryName: selectedCategory.categoryName,
      quantity: double.parse(quantityController.text),
      unit: selectedUnit!,
      expirationDate: selectedDate!,
      imageUrl: imageUrl,
      householdId: isEditMode ? widget.ingredient!.householdId : '', 
      slug: isEditMode ? widget.ingredient!.slug : '', 
    );

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
    bool readOnly = false,
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
              enabled: onTap == null && !readOnly,
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
    bool enabled = true,
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
              onChanged: enabled ? onChanged : null,
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
