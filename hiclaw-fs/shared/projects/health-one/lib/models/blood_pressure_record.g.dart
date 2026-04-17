// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// HiveTypeAnalyzer
// **************************************************************************

// ignore_for_file: type=lint
// ignore_for_file: comments_requiring_docs, permission_reject_name, no_leading_underscores_for_local_identifiers

part of 'blood_pressure_record.dart';

class BloodPressureRecordAdapter extends Adapter<BloodPressureRecord> {
  @override
  BloodPressureRecord read(HiveReader reader) {
    final data = reader.readData((reader) {
      return BloodPressureRecord(
        userId: reader.read(0) as String,
        systolic: reader.read(1) as int,
        diastolic: reader.read(2) as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(reader.read(3) as int),
      );
    });
    data._hiveBox = reader.box;
    return data;
  }

  @override
  void write(HiveWriter writer, BloodPressureRecord obj) {
    writer.writeData((writer) {
      writer.write(0, obj.userId);
      writer.write(1, obj.systolic);
      writer.write(2, obj.diastolic);
      writer.write(3, obj.createdAt.millisecondsSinceEpoch);
    });
  }
}
