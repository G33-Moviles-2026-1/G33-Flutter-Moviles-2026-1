import 'package:andespace/features/friendships/domain/entities/free_slot_selection.dart';
import 'package:andespace/features/friendships/presentation/notifiers/friends_free_slots_state.dart';
import 'package:andespace/features/friendships/presentation/widgets/friends_free_slots_grid.dart';
import 'package:andespace/features/friendships/presentation/widgets/friends_free_slots_theme.dart';
import 'package:flutter/material.dart';

class FriendsFreeSlotsContent extends StatelessWidget {
  const FriendsFreeSlotsContent({
    super.key,
    required this.state,
    required this.onSlotToggled,
    required this.onClearSelection,
    required this.onFindRooms,
  });

  final FriendsFreeSlotsState state;
  final ValueChanged<FreeSlotSelection> onSlotToggled;
  final VoidCallback onClearSelection;
  final VoidCallback onFindRooms;

  @override
  Widget build(BuildContext context) {
    final freeSlots = state.freeSlots;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && state.errorMessage != null) {
      return FriendsFreeSlotsMessage(message: state.errorMessage!);
    }

    if (freeSlots == null || freeSlots.slots.isEmpty) {
      return const FriendsFreeSlotsMessage(
        message: 'No shared free slots were found.',
      );
    }

    return FriendsFreeSlotsGrid(
      referenceDate: state.referenceDate,
      freeSlots: freeSlots,
      selectedSlotKeys: state.selectedSlotKeys,
      isFindingRooms: state.isFindingRooms,
      onSlotToggled: onSlotToggled,
      onClearSelection: onClearSelection,
      onFindRooms: onFindRooms,
    );
  }
}

class FriendsFreeSlotsMessage extends StatelessWidget {
  const FriendsFreeSlotsMessage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: friendsFreeSlotsPanelBackground(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: friendsFreeSlotsGridBorderColor(context)),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
