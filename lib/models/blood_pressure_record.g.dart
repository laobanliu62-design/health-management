// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blood_pressure_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BloodPressureRecordAdapter extends TypeAdapter<BloodPressureRecord> {
  @override
  final int typeId = 0;

  @override
  BloodPressureRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BloodPressureRecord(
      userId: fields[0] as String,
      systolic: fields[1] as int,
      diastolic: fields[2] as int,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BloodPressureRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.systolic)
      ..writeByte(2)
      ..write(obj.diastolic)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BloodPressureRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
