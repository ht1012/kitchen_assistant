import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          _buildHeader(),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Mới'),
                  const SizedBox(height: 12),
                  _buildExpiredNotification(),
                  const SizedBox(height: 12),
                  _buildExpiringTodayNotification(),
                  const SizedBox(height: 12),
                  _buildExpiringInTwoDaysNotification(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Trước đó'),
                  const SizedBox(height: 12),
                  _buildPreviousNotification(),
                  const SizedBox(height: 12),
                  _buildLowStockNotification(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF2F4F6))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6366), Color(0xFFFA2B36)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      left: 8,
                      top: 8,
                      child: Icon(Icons.notifications, size: 24, color: Colors.white),
                    ),
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6800),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Center(
                          child: Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Thông báo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101727),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '3 thông báo mới',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF495565),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Đánh dấu tất cả đã đọc
                },
                child: const Text(
                  'Đánh dấu tất cả là đã đọc',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF00A63D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFilterTabs(),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterTab('Tất cả', true, '5'),
          const SizedBox(width: 8),
          _buildFilterTab('Cấp bách', false, '2'),
          const SizedBox(width: 8),
          _buildFilterTab('Cảnh báo', false, '1'),
          const SizedBox(width: 8),
          _buildFilterTab('Thông tin', false, '2'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, bool isSelected, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF697282) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF697282) : const Color(0xFFE5E7EB),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF354152),
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withValues(alpha: 0.3) : const Color(0xFFF2F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                count,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF354152),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF697282),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildExpiredNotification() {
    return _buildNotificationCard(
      iconColor: const LinearGradient(colors: [Color(0xFFFF6366), Color(0xFFFA2B36)]),
      iconAsset: 'assets/images/icon_warning.png',
      title: 'Thành phần đã hết hạn!',
      subtitle: 'Sữa chua đã hết hạn vào hôm nay',
      time: 'Vừa xong',
      badgeText: 'Hết hạn hôm nay',
      badgeColor: const Color(0xFFFEE1E1),
      badgeTextColor: const Color(0xFFC10007),
      primaryButtonText: 'Xem 8 công thức',
      primaryButtonIcon: SvgPicture.asset(
        'assets/images/icon_viewRecipe.svg',
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
      ),
      primaryButtonColor: const LinearGradient(colors: [Color(0xFFFF6366), Color(0xFFFA2B36)]),
      backgroundColor: const LinearGradient(colors: [Color(0xFFFEF2F2), Color(0x7FFEE1E1)]),
      borderColor: const Color(0xFFFFA2A2),
      isNew: true,
    );
  }

  Widget _buildExpiringTodayNotification() {
    return _buildNotificationCard(
      iconColor: const LinearGradient(colors: [Color(0xFFFF6366), Color(0xFFFA2B36)]),
      iconAsset: 'assets/images/icon_warning.png',
      title: 'Hết hạn hôm nay!',
      subtitle: 'Sữa sẽ hết hạn vào hôm nay',
      time: '2 giờ trước',
      badgeText: 'Expires today',
      badgeColor: const Color(0xFFFEE1E1),
      badgeTextColor: const Color(0xFFC10007),
      primaryButtonText: 'Xem 5 công thức',
      primaryButtonIcon: SvgPicture.asset(
        'assets/images/icon_viewRecipe.svg',
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
      ),
      primaryButtonColor: const LinearGradient(colors: [Color(0xFFFF6366), Color(0xFFFA2B36)]),
      backgroundColor: const LinearGradient(colors: [Color(0xFFFEF2F2), Color(0x7FFEE1E1)]),
      borderColor: const Color(0xFFFFA1A2),
      isNew: true,
    );
  }

  Widget _buildExpiringInTwoDaysNotification() {
    return _buildNotificationCard(
      iconColor: const LinearGradient(colors: [Color(0xFFFFDF20), Color(0xFFFFDF20)]),
      iconAsset: 'assets/images/icon_time.png',
      title: 'Sắp hết hạn',
      subtitle: 'Gà sẽ hết hạn sau 2 ngày',
      time: '5 giờ trước',
      badgeText: 'Còn 2 ngày nữa',
      badgeColor: const Color(0xFFFFECD4),
      badgeTextColor: const Color(0xFFC93400),
      primaryButtonText: 'Xem 8 công thức',
      primaryButtonIcon: SvgPicture.asset(
        'assets/images/icon_viewRecipe.svg',
        colorFilter: const ColorFilter.mode(
          Color(0xFFFF8904),
          BlendMode.srcIn,
        ),
      ),
      primaryButtonColor: const LinearGradient(colors: [Color(0xFFFFDF20), Color(0xFFFFDF20)]),
      primaryButtonTextColor: const Color(0xFFFF8904),
      backgroundColor: const LinearGradient(colors: [Color(0xFFFFF7EC), Color(0x7FFEF9C2)]),
      borderColor: const Color(0xFFFFDF20),
      isNew: true,
    );
  }

  Widget _buildPreviousNotification() {
    return _buildNotificationCard(
      iconColor: const LinearGradient(colors: [Color(0xFFFFDF20), Color(0xFFFFDF20)]),
      iconAsset: 'assets/images/icon_time.png',
      title: 'Hết hạn hôm nay!',
      subtitle: 'Sữa sẽ hết hạn vào hôm nay',
      time: '2 giờ trước',
      badgeText: 'Còn 3 ngày nữa',
      badgeColor: const Color(0xFFFFECD4),
      badgeTextColor: const Color(0xFFC93400),
      primaryButtonText: 'Xem 5 công thức',
      primaryButtonIcon: SvgPicture.asset(
        'assets/images/icon_viewRecipe.svg',
        colorFilter: const ColorFilter.mode(
          Color(0xFFFF8904),
          BlendMode.srcIn,
        ),
      ),
      primaryButtonColor: const LinearGradient(colors: [Color(0xFFFFDF20), Color(0xFFFFDF20)]),
      primaryButtonTextColor: const Color(0xFFFF8904),
      backgroundColor: null,
      borderColor: const Color(0xFFE5E7EB),
      isNew: false,
    );
  }

  Widget _buildLowStockNotification() {
    return _buildNotificationCard(
      iconColor: const LinearGradient(colors: [Color(0xFF50A2FF), Color(0xFF2B7FFF)]),
      iconAsset: 'assets/images/icon_infor.png',
      title: 'Sắp hết',
      subtitle: 'Chỉ còn 2 quả trứng trong kho',
      time: '1 ngày trước',
      badgeText: null,
      primaryButtonText: 'Xem 5 công thức',
      primaryButtonIcon: SvgPicture.asset(
        'assets/images/icon_viewRecipe.svg',
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
      ),
      primaryButtonColor: const LinearGradient(colors: [Color(0xFF50A2FF), Color(0xFF2B7FFF)]),
      backgroundColor: null,
      borderColor: const Color(0xFFE5E7EB),
      isNew: false,
    );
  }

  Widget _buildNotificationCard({
    required LinearGradient iconColor,
    required String iconAsset,
    required String title,
    required String subtitle,
    required String time,
    String? badgeText,
    Color? badgeColor,
    Color? badgeTextColor,
    required String primaryButtonText,
    required Widget primaryButtonIcon,
    required LinearGradient primaryButtonColor,
    Color? primaryButtonTextColor,
    LinearGradient? backgroundColor,
    required Color borderColor,
    required bool isNew,
  }) {
return Stack(
  children: [
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: backgroundColor,
        color: backgroundColor == null ? Colors.white : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: iconColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: Image.asset(
                      iconAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: backgroundColor != null ? const Color(0xFF811719) : const Color(0xFF7E2A0B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF354152),
                      ),
                    ),
                  ],
                ),
              ),
              if (isNew)
                Padding(
                    padding: const EdgeInsets.only(bottom: 36),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                      color: Color(0xFFFA2B36),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF697282),
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 8),
                const Text(
                  '•',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF99A1AE),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 11,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: primaryButtonColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: primaryButtonIcon,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          primaryButtonText,
                          style: TextStyle(
                            fontSize: 13,
                            color: primaryButtonTextColor ?? Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      'Đánh dấu đã đọc',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF354152),
                      ),
                    ),
                  ),
                ),
              ),
            ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 16,
          right: 10,
          child: Transform.scale(
            scale: 1.4,
            child: Image.asset(
              'assets/images/icon_cancel.png',
              width: 36,
              height: 36,
            ),
          ),
        ),
      ],
    );
  }
}
