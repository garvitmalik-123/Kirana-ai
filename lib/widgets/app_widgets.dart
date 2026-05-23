// lib/widgets/app_widgets.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

// ─── 1. KiranaAppBar ───────────────────────────
class KiranaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch;
  final bool showNotification;
  final bool showSettings;
  final bool showHelp;
  final bool showAvatar;
  final Widget? leading;
  final List<Widget>? actions;

  const KiranaAppBar({
    super.key,
    required this.title,
    this.showSearch = false,
    this.showNotification = true,
    this.showSettings = false,
    this.showHelp = false,
    this.showAvatar = false,
    this.leading,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bgDark,
      elevation: 0,
      leading: leading ?? Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF2A3D35)),
          ),
          child: const Icon(Icons.store_outlined, color: AppColors.primary, size: 20),
        ),
      ),
      title: Text(title, style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18)),
      actions: actions ?? buildDefaultActions(context),
    );
  }

  List<Widget> buildDefaultActions(BuildContext context) {
    final List<Widget> items = [];
    if (showSearch) {
      items.add(IconButton(
        icon: const Icon(Icons.search, color: AppColors.textSecondary),
        onPressed: () {},
      ));
    }
    if (showNotification) {
      items.add(Stack(
        alignment: Alignment.topRight,
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
            onPressed: () => showNotificationsSheet(context),
          ),
          Positioned(
            top: 10, right: 10,
            child: Container(width: 8, height: 8,
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)),
          ),
        ],
      ));
    }
    if (showSettings) {
      items.add(IconButton(
        icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
        onPressed: () => showSettingsSheet(context),
      ));
    }
    if (showHelp) {
      items.add(IconButton(
        icon: const Icon(Icons.help_outline, color: AppColors.textSecondary),
        onPressed: () {},
      ));
    }
    if (showAvatar) {
      items.add(Padding(
        padding: const EdgeInsets.only(right: 12),
        child: GestureDetector(
          onTap: () => showProfileSheet(context),
          child: const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.bgSurface,
            child: Icon(Icons.person, color: AppColors.primary, size: 18),
          ),
        ),
      ));
    }
    return items;
  }

  void showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Notifications', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          notifTile(Icons.warning_amber_rounded, 'Low Stock Alert', 'Organic Eggs — only 4 left', AppColors.error),
          notifTile(Icons.trending_up, 'Sales Up 12%', "Today's performance is great!", AppColors.success),
          notifTile(Icons.inventory_2_outlined, 'Restock Reminder', 'Whole Milk running low', AppColors.warning),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget notifTile(IconData icon, String title, String sub, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(sub, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
      contentPadding: EdgeInsets.zero,
    );
  }

  void showSettingsSheet(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  void doLogout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      // ignore
    }
  }

  void showProfileSheet(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }
}

// ─── 2. KiranaBottomNavBar ─────────────────────
class KiranaBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const KiranaBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.point_of_sale_outlined, label: 'POS'),
      _NavItem(icon: Icons.inventory_2_outlined, label: 'Inventory'),
      _NavItem(icon: Icons.analytics_outlined, label: 'Analytics'),
      _NavItem(icon: Icons.auto_awesome_outlined, label: 'AI Insights'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF101A15),
        border: Border(top: BorderSide(color: Color(0xFF1E3028), width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: selected
                      ? BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20))
                      : null,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(items[i].icon, color: selected ? AppColors.primary : AppColors.textMuted, size: 22),
                    const SizedBox(height: 3),
                    Text(items[i].label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600,
                        color: selected ? AppColors.primary : AppColors.textMuted)),
                  ]),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}

// ─── 3. KiranaCard ────────────────────────────
class KiranaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  const KiranaCard({super.key, required this.child, this.padding, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E3028), width: 1),
        ),
        child: child,
      ),
    );
  }
}

// ─── 4. KiranaPrimaryButton ───────────────────
class KiranaPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool isLoading;

  const KiranaPrimaryButton({
    super.key, required this.label, required this.onPressed,
    this.icon, this.isOutlined = false, this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2A3D35), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                foregroundColor: AppColors.textPrimary,
              ),
              child: buildChild())
          : ElevatedButton(onPressed: onPressed, child: buildChild()),
    );
  }

  Widget buildChild() {
    if (isLoading) {
      return const SizedBox(width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black));
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15,
          color: isOutlined ? AppColors.textPrimary : Colors.black)),
      if (icon != null) ...[
        const SizedBox(width: 8),
        Icon(icon, size: 18, color: isOutlined ? AppColors.textPrimary : Colors.black),
      ],
    ]);
  }
}

// ─── 5. KiranaTextField ───────────────────────
class KiranaTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const KiranaTextField({
    super.key, required this.label, required this.hint,
    this.prefixIcon, this.isPassword = false, this.controller, this.keyboardType,
  });

  @override
  State<KiranaTextField> createState() => _KiranaTextFieldState();
}

class _KiranaTextFieldState extends State<KiranaTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (widget.label.isNotEmpty) ...[
        Text(widget.label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
      ],
      TextField(
        controller: widget.controller,
        obscureText: widget.isPassword && _obscure,
        keyboardType: widget.keyboardType,
        style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, color: AppColors.textMuted, size: 18) : null,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textMuted, size: 18),
                  onPressed: () => setState(() => _obscure = !_obscure))
              : null,
        ),
      ),
    ]);
  }
}

// ─── 6. QuantitySelector ──────────────────────
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Color? color;

  const QuantitySelector({super.key, required this.quantity, required this.onIncrement, required this.onDecrement, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color ?? AppColors.bgSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF2A3D35))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(onTap: onDecrement, child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.remove, color: AppColors.primary, size: 16))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('$quantity', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14))),
        GestureDetector(onTap: onIncrement, child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.add, color: AppColors.primary, size: 16))),
      ]),
    );
  }
}

// ─── 7. HealthScoreWidget ─────────────────────
class HealthScoreWidget extends StatelessWidget {
  final double score;
  final String label;

  const HealthScoreWidget({super.key, required this.score, this.label = 'Optimal'});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 140, height: 140,
      child: CustomPaint(
        painter: CircleGaugePainter(score / 100),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(score.toInt().toString(), style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 36, fontWeight: FontWeight.w800)),
          Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
        ])),
      ),
    );
  }
}

class CircleGaugePainter extends CustomPainter {
  final double progress;
  CircleGaugePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 10.0;
    canvas.drawCircle(center, radius, Paint()..color = AppColors.bgSurface..style = PaintingStyle.stroke..strokeWidth = strokeWidth);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi * progress, false,
        Paint()..color = AppColors.primary..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─── 8. StatCard ──────────────────────────────
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBg;

  const StatCard({super.key, required this.title, required this.value, this.subtitle, this.icon, this.iconColor, this.iconBg});

  @override
  Widget build(BuildContext context) {
    return KiranaCard(
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: GoogleFonts.inter(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ])),
        if (icon != null)
          Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: iconBg ?? AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22)),
      ]),
    );
  }
}

// ─── 9. StockAlertTile ────────────────────────
class StockAlertTile extends StatelessWidget {
  final String name;
  final String status;
  final Color statusColor;

  const StockAlertTile({super.key, required this.name, required this.status, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Container(width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.inventory_2_outlined, color: AppColors.textSecondary, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
          Text(status, style: GoogleFonts.inter(color: statusColor, fontSize: 11)),
        ])),
        Container(padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary, size: 16)),
      ]),
    );
  }
}

// ─── 10. WeeklySalesChart ─────────────────────
class WeeklySalesChart extends StatelessWidget {
  final List<double> data;
  final List<String> days;

  const WeeklySalesChart({super.key, required this.data, required this.days});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.isEmpty ? 1.0 : data.reduce(math.max);
    return LayoutBuilder(
      builder: (context, constraints) {
        final barHeight = constraints.maxHeight - 20;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(data.length, (i) {
            final heightFrac = (data[i] / maxVal).clamp(0.05, 1.0);
            final isHighest = data[i] == maxVal;
            return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 400 + i * 50),
                width: 28,
                height: barHeight * heightFrac,
                decoration: BoxDecoration(
                  color: isHighest ? AppColors.primary : AppColors.chartBarDim,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 4),
              Text(days[i], style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w500)),
            ]);
          }),
        );
      },
    );
  }
}

// ─── 11. AIInsightCard ────────────────────────
class AIInsightCard extends StatelessWidget {
  final String title;
  final String description;
  final String tag;
  final Color tagColor;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData icon;

  const AIInsightCard({
    super.key, required this.title, required this.description, required this.tag,
    required this.tagColor, required this.actionLabel, required this.onAction, required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return KiranaCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: tagColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: tagColor, size: 18)),
        const SizedBox(height: 10),
        Text(title, style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 6),
        Text(description, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, height: 1.5)),
        const SizedBox(height: 12),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: tagColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(tag, style: GoogleFonts.inter(color: tagColor, fontSize: 10, fontWeight: FontWeight.w600))),
          const Spacer(),
          GestureDetector(onTap: onAction,
              child: Text(actionLabel, style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12))),
        ]),
      ]),
    );
  }
}

// ─── 12. PinDots ──────────────────────────────
class PinDots extends StatelessWidget {
  final int totalDots;
  final int filledDots;

  const PinDots({super.key, this.totalDots = 6, required this.filledDots});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalDots, (i) {
        final filled = i < filledDots;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 14, height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.primary : Colors.transparent,
            border: Border.all(color: filled ? AppColors.primary : AppColors.textMuted, width: 1.5),
          ),
        );
      }),
    );
  }
}

// ─── 13. InventoryProgressBar ─────────────────
class InventoryProgressBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const InventoryProgressBar({super.key, required this.label, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
        const Spacer(),
        Text('${(percent * 100).toInt()}%', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: percent, minHeight: 5,
              backgroundColor: AppColors.bgSurface, valueColor: AlwaysStoppedAnimation(color))),
      const SizedBox(height: 14),
    ]);
  }
}

// ─── 14. BillItemCard ─────────────────────────
class BillItemCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String price;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  const BillItemCard({
    super.key, required this.name, required this.subtitle, required this.price,
    required this.quantity, required this.onIncrement, required this.onDecrement, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return KiranaCard(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(width: 52, height: 52,
            decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.shopping_bag_outlined, color: AppColors.textMuted, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
          Text(subtitle, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Row(children: [
            QuantitySelector(quantity: quantity, onIncrement: onIncrement, onDecrement: onDecrement),
            const SizedBox(width: 12),
            Text(price, style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
          ]),
        ])),
        IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 20), onPressed: onDelete),
      ]),
    );
  }
}

// ─── 15. SectionHeader ────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title, style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
      if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      const Spacer(),
      if (actionLabel != null)
        GestureDetector(onTap: onAction,
            child: Text(actionLabel!, style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500))),
    ]);
  }
}
