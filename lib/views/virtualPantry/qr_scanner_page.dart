import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    formats: const [
      // QR Code
      BarcodeFormat.qrCode,
      // Barcode formats (mã vạch)
      BarcodeFormat.ean13,      // EAN-13 (13 số)
      BarcodeFormat.ean8,       // EAN-8 (8 số)
      BarcodeFormat.upcA,       // UPC-A
      BarcodeFormat.upcE,       // UPC-E
      BarcodeFormat.code128,    // CODE-128
      BarcodeFormat.code39,     // CODE-39
      BarcodeFormat.code93,     // CODE-93
      BarcodeFormat.codabar,    // Codabar
      BarcodeFormat.itf,        // ITF
      BarcodeFormat.dataMatrix, // Data Matrix
      BarcodeFormat.aztec,      // Aztec
      BarcodeFormat.pdf417,     // PDF417
    ],
  );
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
                final rawValue = barcode.rawValue;
                if (rawValue != null && rawValue.isNotEmpty) {
                  // Debug: In ra loại mã đã quét được
                  debugPrint('✅ Đã quét được mã: $rawValue, loại: ${barcode.type}');
                  // Chỉ xử lý một lần để tránh duplicate
                  if (mounted) {
                    _handleScannedCode(rawValue);
                  }
                } else {
                  debugPrint('⚠️ Quét được nhưng rawValue null hoặc rỗng');
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
              color: Colors.white,
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
    debugPrint('Xử lý mã đã quét: $code');
    final parsed = _parseQRPayload(code);
    debugPrint('Kết quả parse: $parsed');
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

    // 4) Kiểm tra nếu là barcode (chỉ có số, độ dài từ 6-18 ký tự)
    // Hỗ trợ nhiều loại barcode: EAN-8 (8 số), EAN-13 (13 số), UPC-A (12 số), CODE-128, v.v.
    final barcodeRegex = RegExp(r'^\d{6,18}$');
    final trimmedCode = code.trim();
    if (barcodeRegex.hasMatch(trimmedCode)) {
      return {'barcode': trimmedCode};
    }

    // 5) Fallback: chỉ có name
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

