import 'package:hive/hive.dart';
import 'show_model.dart';

class EpisodeModel {
  final int id;
  final String name;
  final int? season;
  final int? number;
  final String? airdate;
  final String? airtime;
  final String? airstamp;
  final int? runtime;
  final String? imageUrl;
  final String? originalImageUrl;
  final String? summary;
  final ShowModel show;

  EpisodeModel({
    required this.id,
    required this.name,
    this.season,
    this.number,
    this.airdate,
    this.airtime,
    this.airstamp,
    this.runtime,
    this.imageUrl,
    this.originalImageUrl,
    this.summary,
    required this.show,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      season: json['season'],
      number: json['number'],
      airdate: json['airdate'],
      airtime: json['airtime'],
      airstamp: json['airstamp'],
      runtime: json['runtime'],
      imageUrl: json['image']?['medium'],
      originalImageUrl: json['image']?['original'],
      summary: json['summary'],
      show: ShowModel.fromJson(json['show'] ?? {}),
    );
  }
}

class EpisodeModelAdapter extends TypeAdapter<EpisodeModel> {
  @override
  final int typeId = 3;

  @override
  EpisodeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EpisodeModel(
      id: fields[0] as int,
      name: fields[1] as String,
      season: fields[2] as int?,
      number: fields[3] as int?,
      airdate: fields[4] as String?,
      airtime: fields[5] as String?,
      airstamp: fields[6] as String?,
      runtime: fields[7] as int?,
      imageUrl: fields[8] as String?,
      originalImageUrl: fields[9] as String?,
      summary: fields[10] as String?,
      show: fields[11] as ShowModel,
    );
  }

  @override
  void write(BinaryWriter writer, EpisodeModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.season)
      ..writeByte(3)
      ..write(obj.number)
      ..writeByte(4)
      ..write(obj.airdate)
      ..writeByte(5)
      ..write(obj.airtime)
      ..writeByte(6)
      ..write(obj.airstamp)
      ..writeByte(7)
      ..write(obj.runtime)
      ..writeByte(8)
      ..write(obj.imageUrl)
      ..writeByte(9)
      ..write(obj.originalImageUrl)
      ..writeByte(10)
      ..write(obj.summary)
      ..writeByte(11)
      ..write(obj.show);
  }
}
