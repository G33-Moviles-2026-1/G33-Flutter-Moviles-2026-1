import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/room_date_availability.dart';
import '../../domain/entities/room_search.dart';
import '../../domain/repositories/rooms_repository.dart';
import '../../domain/usecases/search_rooms_exceptions.dart';
import '../cache/room_search_memory_cache.dart';
import '../models/room_date_availability_dto.dart';
import '../models/room_search_request_dto.dart';
import '../models/room_search_response_dto.dart';
import '../remote/rooms_api.dart';

class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl({
    required this.roomsApi,
    required this.memoryCache,
  });

  final RoomsApi roomsApi;
  final RoomSearchMemoryCache memoryCache;

  @override
  Future<RoomSearchResponse> searchRooms(RoomSearchRequest request) async {
    try {
      final requestDto = RoomSearchRequestDto(request);
      final raw = await roomsApi.searchRooms(requestDto.toJson());
      final responseDto = RoomSearchResponseDto.fromJson(raw);
      return responseDto.toDomain();
    } on DioException catch (e) {
      if (_isConnectivityError(e)) {
        throw const SearchRoomsConnectivityException();
      }
      rethrow;
    } catch (e) {
      final raw = e.toString().toLowerCase();
      if (raw.contains('socketexception') ||
          raw.contains('failed host lookup') ||
          raw.contains('network is unreachable') ||
          raw.contains('timeout')) {
        throw const SearchRoomsConnectivityException();
      }
      rethrow;
    }
  }

  @override
  Future<RoomDateAvailability> fetchRoomDateAvailability({
    required String roomId,
    required String date,
  }) async {
    final raw = await roomsApi.fetchRoomDateAvailability(
      roomId: roomId,
      date: date,
    );

    return compute(_parseAvailability, raw);
  }

  static RoomDateAvailability _parseAvailability(Map<String, dynamic> json) {
    return RoomDateAvailabilityDto.fromJson(json).toDomain();
  }

  @override
  RoomSearchResponse? getCachedSearchPage(int pageNumber) {
    return memoryCache.getCachedPage(pageNumber);
  }

  @override
  void cacheFirstSearchPage({
    required RoomSearchRequest baseQuery,
    required RoomSearchResponse firstPage,
  }) {
    memoryCache.replaceWithFirstPage(
      baseQuery: baseQuery,
      firstPage: firstPage,
    );
  }

  @override
  Future<void> prefetchFirstPages(RoomSearchRequest baseQuery) async {
    Future<void>(() async {
      await _prefetchPage(baseQuery, 2);
      await _prefetchPage(baseQuery, 3);
    });
  }

  Future<void> _prefetchPage(RoomSearchRequest baseQuery, int pageNumber) async {
    if (pageNumber < 2 || pageNumber > 3) return;

    final offset = (pageNumber - 1) * baseQuery.limit;
    final request = baseQuery.copyWith(offset: offset);

    try {
      final response = await searchRooms(request);
      memoryCache.storePage(pageNumber: pageNumber, response: response);
    } catch (_) {
      // silent by requirement
    }
  }

  bool _isConnectivityError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.unknown:
        final msg = error.message?.toLowerCase() ?? '';
        return msg.contains('socketexception') ||
            msg.contains('failed host lookup') ||
            msg.contains('network is unreachable') ||
            msg.contains('timeout');
      case DioExceptionType.badResponse:
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        return false;
    }
  }
}