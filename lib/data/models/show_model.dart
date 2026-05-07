import 'package:hive/hive.dart';

class ShowModel {
  final int id;
  final String name;
  final String? summary;
  final String? imageUrl;
  final String? originalImageUrl;
  final double? rating;
  final String? premiered;
  final List<String> genres;
  final String? type;
  final String? language;
  final String? status;
  final int? runtime;
  final int? averageRuntime;
  final String? ended;
  final String? officialSite;
  final ScheduleModel? schedule;
  final NetworkModel? network;
  final NetworkModel? webChannel;
  final String? imdbId;
  final String? url;

  ShowModel({
    required this.id,
    required this.name,
    this.summary,
    this.imageUrl,
    this.originalImageUrl,
    this.rating,
    this.premiered,
    this.genres = const [],
    this.type,
    this.language,
    this.status,
    this.runtime,
    this.averageRuntime,
    this.ended,
    this.officialSite,
    this.schedule,
    this.network,
    this.webChannel,
    this.imdbId,
    this.url,
  });

  factory ShowModel.fromJson(Map<String, dynamic> json) {
    return ShowModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      summary: json['summary'],
      imageUrl: json['image']?['medium'],
      originalImageUrl: json['image']?['original'],
      rating: json['rating']?['average']?.toDouble(),
      premiered: json['premiered'],
      genres: List<String>.from(json['genres'] ?? []),
      type: json['type'],
      language: json['language'],
      status: json['status'],
      runtime: json['runtime'],
      averageRuntime: json['averageRuntime'],
      ended: json['ended'],
      officialSite: json['officialSite'],
      schedule: json['schedule'] != null ? ScheduleModel.fromJson(json['schedule']) : null,
      network: json['network'] != null ? NetworkModel.fromJson(json['network']) : null,
      webChannel: json['webChannel'] != null ? NetworkModel.fromJson(json['webChannel']) : null,
      imdbId: json['externals']?['imdb'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'summary': summary,
      'image': {
        'medium': imageUrl,
        'original': originalImageUrl,
      },
      'rating': {
        'average': rating,
      },
      'premiered': premiered,
      'genres': genres,
      'type': type,
      'language': language,
      'status': status,
      'runtime': runtime,
      'averageRuntime': averageRuntime,
      'ended': ended,
      'officialSite': officialSite,
      'schedule': schedule?.toJson(),
      'network': network?.toJson(),
      'webChannel': webChannel?.toJson(),
      'externals': {
        'imdb': imdbId,
      },
      'url': url,
    };
  }
}

class ScheduleModel {
  final String? time;
  final List<String> days;

  ScheduleModel({this.time, this.days = const []});

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      time: json['time'],
      days: List<String>.from(json['days'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'days': days,
    };
  }
}

class NetworkModel {
  final String? name;
  final String? countryName;
  final String? countryCode;
  final String? timezone;

  NetworkModel({this.name, this.countryName, this.countryCode, this.timezone});

  factory NetworkModel.fromJson(Map<String, dynamic> json) {
    return NetworkModel(
      name: json['name'],
      countryName: json['country']?['name'],
      countryCode: json['country']?['code'],
      timezone: json['country']?['timezone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': {
        'name': countryName,
        'code': countryCode,
        'timezone': timezone,
      }
    };
  }
}

// ==========================================
// MANUAL HIVE ADAPTERS
// ==========================================

class ShowModelAdapter extends TypeAdapter<ShowModel> {
  @override
  final int typeId = 0;

  @override
  ShowModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShowModel(
      id: fields[0] as int,
      name: fields[1] as String,
      summary: fields[2] as String?,
      imageUrl: fields[3] as String?,
      originalImageUrl: fields[4] as String?,
      rating: fields[5] as double?,
      premiered: fields[6] as String?,
      genres: (fields[7] as List?)?.cast<String>() ?? [],
      type: fields[8] as String?,
      language: fields[9] as String?,
      status: fields[10] as String?,
      runtime: fields[11] as int?,
      averageRuntime: fields[12] as int?,
      ended: fields[13] as String?,
      officialSite: fields[14] as String?,
      schedule: fields[15] as ScheduleModel?,
      network: fields[16] as NetworkModel?,
      webChannel: fields[17] as NetworkModel?,
      imdbId: fields[18] as String?,
      url: fields[19] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ShowModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.summary)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.originalImageUrl)
      ..writeByte(5)
      ..write(obj.rating)
      ..writeByte(6)
      ..write(obj.premiered)
      ..writeByte(7)
      ..write(obj.genres)
      ..writeByte(8)
      ..write(obj.type)
      ..writeByte(9)
      ..write(obj.language)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.runtime)
      ..writeByte(12)
      ..write(obj.averageRuntime)
      ..writeByte(13)
      ..write(obj.ended)
      ..writeByte(14)
      ..write(obj.officialSite)
      ..writeByte(15)
      ..write(obj.schedule)
      ..writeByte(16)
      ..write(obj.network)
      ..writeByte(17)
      ..write(obj.webChannel)
      ..writeByte(18)
      ..write(obj.imdbId)
      ..writeByte(19)
      ..write(obj.url);
  }
}

class ScheduleModelAdapter extends TypeAdapter<ScheduleModel> {
  @override
  final int typeId = 1;

  @override
  ScheduleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduleModel(
      time: fields[0] as String?,
      days: (fields[1] as List?)?.cast<String>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.days);
  }
}

class NetworkModelAdapter extends TypeAdapter<NetworkModel> {
  @override
  final int typeId = 2;

  @override
  NetworkModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NetworkModel(
      name: fields[0] as String?,
      countryName: fields[1] as String?,
      countryCode: fields[2] as String?,
      timezone: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NetworkModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.countryName)
      ..writeByte(2)
      ..write(obj.countryCode)
      ..writeByte(3)
      ..write(obj.timezone);
  }
}
