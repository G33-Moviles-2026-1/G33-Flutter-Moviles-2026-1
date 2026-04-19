import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_theme_extension.dart';

class PathBody extends ConsumerStatefulWidget {
  const PathBody({super.key});

  @override
  ConsumerState<PathBody> createState() => _PathBodyState();
}

class _PathBodyState extends ConsumerState<PathBody> {
  final TextEditingController _originController = TextEditingController(text: "ML 340");
  final TextEditingController _destController = TextEditingController(text: "C 404");

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final brand = t.extension<BrandColors>()!;
    final isDark = t.brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Where Are You?", t),
            const SizedBox(height: 8),
            _buildCustomTextField(_originController, isDark, t),
            const SizedBox(height: 24),    
            _buildSectionTitle("Where You Want to Go?", t),
            const SizedBox(height: 8),
            _buildCustomTextField(_destController, isDark, t),
            const SizedBox(height: 32),
            _buildSectionTitle("Follow Me:", t),
            const SizedBox(height: 12),
            _buildInstructionsContainer(brand, isDark, t),
            const SizedBox(height: 40),
            _buildSubmitButton(brand, t),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData t) {
    return Text(
      title,
      style: t.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w900,
        fontSize: 22,
      ),
    );
  }

  Widget _buildCustomTextField(TextEditingController controller, bool isDark, ThemeData t) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white24 : Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.black12,
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildInstructionsContainer(BrandColors brand, bool isDark, ThemeData t) {
    final List<String> mockSteps = [
      "Go Up the stairs to floor 4",
      "Take the lift to Building C",
      "Pass through the main corridor"
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? brand.accentYellow.withOpacity(0.2) : const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? brand.accentYellow : Colors.black.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: mockSteps.map((step) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("• ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(
                  step,
                  style: t.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildSubmitButton(BrandColors brand, ThemeData t) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: brand.accentYellow,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          elevation: 4,
          shadowColor: Colors.black,
        ),
        child: const Text(
          "Show me",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
    );
  }
}