import '../../../../core/local/app_database.dart';
import '../models/my_booking_dto.dart';

class BookingsLocalDataSource {
  final AppDatabase _db;

  const BookingsLocalDataSource(this._db);

  Future<List<MyBookingDto>> getBookings() async {
    final rows = await _db.getAllBookings();
    return rows.map(_rowToDto).toList();
  }

  Future<void> saveBookings(List<MyBookingDto> dtos) =>
      _db.replaceAllBookings(dtos.map(_dtoToCompanion).toList());

  Future<void> removeBooking(String bookingId) =>
      _db.deleteBookingById(bookingId);

  Future<void> clear() => _db.delete(_db.myBookingsTable).go();

  MyBookingDto _rowToDto(MyBookingsTableData row) => MyBookingDto(
        id: row.id,
        roomId: row.roomId,
        date: row.date,
        createdAt: row.createdAt,
        startTime: row.startTime,
        endTime: row.endTime,
        purpose: row.purpose,
        status: row.status,
      );

  MyBookingsTableCompanion _dtoToCompanion(MyBookingDto dto) =>
      MyBookingsTableCompanion.insert(
        id: dto.id,
        roomId: dto.roomId,
        date: dto.date,
        createdAt: dto.createdAt,
        startTime: dto.startTime,
        endTime: dto.endTime,
        purpose: dto.purpose,
        status: dto.status,
      );
}