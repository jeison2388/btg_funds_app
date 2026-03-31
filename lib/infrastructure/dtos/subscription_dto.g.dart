// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionDtoAdapter extends TypeAdapter<SubscriptionDto> {
  @override
  final int typeId = 0;

  @override
  SubscriptionDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubscriptionDto(
      fundId: fields[0] as String,
      fundName: fields[1] as String,
      amount: fields[2] as double,
      date: fields[3] as DateTime,
      notificationMethod: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SubscriptionDto obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.fundId)
      ..writeByte(1)
      ..write(obj.fundName)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.notificationMethod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
