// lib/screens/barcode_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});
  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final _manualCtrl = TextEditingController();

  @override
  void dispose() { _manualCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text('Scan Barcode', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Scanner icon / placeholder
            Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 80),
                const SizedBox(height: 12),
                Text(
                  kIsWeb ? 'Web pe camera\nsupported nahi' : 'Camera loading...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                ),
              ]),
            ),
            const SizedBox(height: 32),
            Text('Manual Entry', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              controller: _manualCtrl,
              autofocus: true,
              style: GoogleFonts.inter(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'SKU ya Barcode type karo...',
                prefixIcon: Icon(Icons.qr_code, color: AppColors.textMuted, size: 18),
              ),
              onSubmitted: (val) {
                if (val.isNotEmpty) Navigator.pop(context, val.trim());
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_manualCtrl.text.isNotEmpty) Navigator.pop(context, _manualCtrl.text.trim());
                },
                icon: const Icon(Icons.search, color: Colors.black),
                label: Text('Search Product', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
