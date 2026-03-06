import 'package:andespace/shared/widgets/app_footer.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/mock_room_repository.dart';
import '../../domain/repositories/rooms_repository.dart';
import '../cubit/room_detail_cubit.dart';
import '../widgets/room_detail_body.dart';

class RoomDetailPage extends StatelessWidget {
  final String roomId;

  const RoomDetailPage({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    final RoomRepository repository = MockRoomRepository();

    return BlocProvider(
      create: (_) => RoomDetailCubit(repository)..fetchRoomDetail(roomId),
      child: AppScaffold(
      currentTab: AppTab.rooms,
      onTabSelected: (_) {},
        body: RoomDetailBody(),
      ),
    );
  }
}
