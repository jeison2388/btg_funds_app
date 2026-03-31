// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionDtoAdapter extends TypeAdapter<TransactionDto> {
  @override
  final int typeId = 1;

  @override
  TransactionDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionDto(
      id: fields[0] as String,
      type: fields[1] as String,
      fundId: fields[2] as String,
      fundName: fields[3] as String,
      amount: fields[4] as double,
      date: fields[5] as DateTime,
      notificationMethod: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionDto obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.fundId)
      ..writeByte(3)
      ..write(obj.fundName)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.notificationMethod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
