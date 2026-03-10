import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme_extension.dart';
import '../../domain/entities/room_search.dart';

class RoomDetailBody extends StatefulWidget {
  final RoomSearchItem room;

  const RoomDetailBody({super.key, required this.room});

  @override
  State<RoomDetailBody> createState() => _RoomDetailBodyState();
}

class _RoomDetailBodyState extends State<RoomDetailBody> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  void _pickDate() async {
    final now = DateTime.now();
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: brand.accentYellow,
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final brand = t.extension<BrandColors>()!;
    final room = widget.room;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER: ID, Building & Icons
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(room.roomId,
                              style: t.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            "Building: ${room.buildingName ?? room.buildingCode}",
                            style: t.textTheme.bodyMedium,
                          ),
                          Text("Capacity: ${room.capacity} people",
                              style: t.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    _HeaderIcon(
                        icon: Icons.report_gmailerrorred_outlined, onTap: () {}),
                    const SizedBox(width: 10),
                    _HeaderIcon(icon: Icons.favorite_border, onTap: () {}),
                  ],
                ),

                const SizedBox(height: 24),

                /// DATE SELECTOR
                Center(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 1.4),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(3, 3))
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_formatDate(selectedDate),
                              style: t.textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          const Icon(Icons.calendar_today_outlined, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                Center(
                    child: Text("Availability",
                        style: t.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold))),
                const SizedBox(height: 12),

                /// SLOTS DE DISPONIBILIDAD
                _buildAvailabilityList(room),

                const SizedBox(height: 30),
                Center(
                    child: Text("Utilities",
                        style: t.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold))),
                const SizedBox(height: 16),

                /// GRILLA DE UTILITIES
                _buildUtilitiesGrid(room, brand),
              ],
            ),
          ),
        ),

        /// BOTÓN FIJO DE RESERVA
        Padding(
          padding: const EdgeInsets.all(18),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: brand.accentYellow,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
              ).copyWith(
                overlayColor: WidgetStateProperty.all(Colors.black12),
              ),
              child: Text("Book Room",
                  style: t.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityList(RoomSearchItem room) {
    final t = Theme.of(context);
    
    // Mapeo de DateTime.weekday a los strings del DTO
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final selectedDayName = weekdays[selectedDate.weekday - 1];

    // Filtramos la disponibilidad semanal por el día seleccionado
    final dayWindows = room.weeklyAvailability
        .where((w) => w.day.toLowerCase() == selectedDayName.toLowerCase())
        .toList();

    if (dayWindows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text("No scheduled availability for $selectedDayName",
              style: t.textTheme.bodyMedium),
        ),
      );
    }

    return Column(
      children: dayWindows
          .map((window) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: Center(
                  child: Text("${window.start} - ${window.end}",
                      style: t.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildUtilitiesGrid(RoomSearchItem room, BrandColors brand) {
    final t = Theme.of(context);
    
    if (room.utilities.isEmpty) {
      return Center(child: Text("No utilities listed", style: t.textTheme.bodySmall));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: room.utilities.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3.5,
      ),
      itemBuilder: (context, index) {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: brand.softYellow.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Text(
            room.utilities[index],
            style: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 1.4),
        ),
        child: Icon(icon, size: 22, color: Colors.black),
      ),
    );
  }
}