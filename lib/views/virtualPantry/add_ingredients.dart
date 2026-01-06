import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/virtualPantry/ingredient_model.dart';
import '../../viewmodels/virtualPantry/pantry_viewmodel.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';


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

  Future<void> _scanQRCode() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerPage(),
      ),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        _handleQRResult(result);
      }
    });
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
    
    // Hỗ trợ categoryId hoặc categoryName
    if (qrData.containsKey('categoryId')) {
      final categoryId = (qrData['categoryId'] ?? '').toString();
      if (categories.any((c) => c['id'] == categoryId)) {
        setState(() {
          selectedCategoryId = categoryId;
        });
      }
    } else if (qrData.containsKey('categoryName')) {
      final categoryName = (qrData['categoryName'] ?? '').toString().toLowerCase();
      final matched = categories.firstWhere(
        (c) => (c['name'] ?? '').toLowerCase() == categoryName,
        orElse: () => {},
      );
      if (matched.isNotEmpty) {
        setState(() {
          selectedCategoryId = matched['id'];
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
                                  : const AssetImage('assets/images/ingre.png')
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
                        enabled: !isEditMode,
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

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  final ImagePicker _galleryPicker = ImagePicker();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final barcode = barcodes.first;
                if (barcode.rawValue != null) {
                  _handleScannedCode(barcode.rawValue!);
                }
              }
            },
          ),
          // Overlay với khung quét
          CustomPaint(
            painter: QRScannerOverlay(),
            child: Container(),
          ),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Quét mã QR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Instructions
          const Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Đưa mã QR vào khung ở giữa màn hình',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom actions
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _actionButton(
                  label: 'Camera',
                  icon: Icons.qr_code_scanner,
                  onTap: () => controller.start(),
                  isPrimary: true,
                ),
                const SizedBox(width: 16),
                _actionButton(
                  label: 'Gallery',
                  icon: Icons.image,
                  onTap: _pickFromGallery,
                  isPrimary: false,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF00C850) : Colors.white24,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isPrimary ? const Color(0xFF00C850) : Colors.white30,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFF00C850).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image =
          await _galleryPicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final capture = await controller.analyzeImage(image.path);

      if (capture == null || capture.barcodes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy mã QR trong ảnh'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final raw = capture.barcodes.first.rawValue;
      if (raw == null || raw.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ảnh không chứa dữ liệu QR hợp lệ'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      _handleScannedCode(raw);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi quét từ ảnh: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleScannedCode(String code) {
    // Dừng scanner
    controller.stop();
    final parsed = _parseQRPayload(code);
    if (mounted) {
      Navigator.pop(context, parsed);
    }
  }

  Map<String, dynamic> _parseQRPayload(String code) {
    // 1) Thử JSON
    try {
      final data = jsonDecode(code);
      if (data is Map<String, dynamic>) {
        return _normalizeKeys(data);
      }
    } catch (_) {}

    // 2) Thử URL/query string
    final uri = Uri.tryParse(code);
    if (uri != null && uri.queryParameters.isNotEmpty) {
      final qp = uri.queryParameters;
      return _normalizeKeys({
        'name': qp['name'] ?? qp['product'] ?? qp['title'],
        'quantity': qp['quantity'] ?? qp['qty'],
        'unit': qp['unit'] ?? qp['u'],
        'categoryId': qp['categoryId'] ?? qp['catId'],
        'categoryName': qp['category'] ?? qp['cat'],
        'expirationDate': qp['expirationDate'] ?? qp['exp'] ?? qp['date'],
      });
    }

    // 3) Thử pattern key=value;key=value
    if (code.contains('=')) {
      final parts = code.replaceAll(';', '&').split('&');
      final map = <String, String>{};
      for (final p in parts) {
        final kv = p.split('=');
        if (kv.length == 2) {
          map[kv[0].trim()] = kv[1].trim();
        }
      }
      if (map.isNotEmpty) {
        return _normalizeKeys(map);
      }
    }

    // 4) Fallback: chỉ có name
    return {'name': code};
  }

  Map<String, dynamic> _normalizeKeys(Map data) {
    // Chuẩn hóa key về chuẩn app: name, quantity, unit, categoryId, categoryName, expirationDate
    Map<String, dynamic> result = {};
    data.forEach((k, v) {
      final key = k.toString().toLowerCase();
      switch (key) {
        case 'name':
        case 'product':
        case 'title':
          result['name'] = v;
          break;
        case 'quantity':
        case 'qty':
        case 'q':
          result['quantity'] = v;
          break;
        case 'unit':
        case 'u':
          result['unit'] = v;
          break;
        case 'categoryid':
        case 'catid':
          result['categoryId'] = v;
          break;
        case 'category':
        case 'cat':
        case 'categoryname':
          result['categoryName'] = v;
          break;
        case 'expirationdate':
        case 'exp':
        case 'expiry':
        case 'date':
          result['expirationDate'] = v;
          break;
        default:
          // ignore extras
          break;
      }
    });
    return result;
  }
}

// Custom painter cho overlay khung quét
class QRScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final scanArea = 250.0;
    final left = (size.width - scanArea) / 2;
    final top = (size.height - scanArea) / 2 - 50;
    final scanRect = Rect.fromLTWH(left, top, scanArea, scanArea);

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(scanRect, const Radius.circular(16)),
      );

    final combinedPath = Path.combine(
      PathOperation.difference,
      path,
      cutoutPath,
    );

    canvas.drawPath(combinedPath, paint);

    // Vẽ khung quét
    final borderPaint = Paint()
      ..color = const Color(0xFF00C850)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(16)),
      borderPaint,
    );

    // Vẽ góc vuông
    final cornerLength = 20.0;
    final cornerPaint = Paint()
      ..color = const Color(0xFF00C850)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Góc trên trái
    canvas.drawLine(
      Offset(left, top + cornerLength),
      Offset(left, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      cornerPaint,
    );

    // Góc trên phải
    canvas.drawLine(
      Offset(left + scanArea - cornerLength, top),
      Offset(left + scanArea, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanArea, top),
      Offset(left + scanArea, top + cornerLength),
      cornerPaint,
    );

    // Góc dưới trái
    canvas.drawLine(
      Offset(left, top + scanArea - cornerLength),
      Offset(left, top + scanArea),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanArea),
      Offset(left + cornerLength, top + scanArea),
      cornerPaint,
    );

    // Góc dưới phải
    canvas.drawLine(
      Offset(left + scanArea - cornerLength, top + scanArea),
      Offset(left + scanArea, top + scanArea),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanArea, top + scanArea - cornerLength),
      Offset(left + scanArea, top + scanArea),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
