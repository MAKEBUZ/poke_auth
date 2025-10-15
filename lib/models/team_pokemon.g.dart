// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_pokemon.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TeamPokemonAdapter extends TypeAdapter<TeamPokemon> {
  @override
  final int typeId = 0;

  @override
  TeamPokemon read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TeamPokemon(
      id: fields[0] as int,
      name: fields[1] as String,
      imageUrl: fields[2] as String,
      types: (fields[3] as List).cast<String>(),
      weaknesses: (fields[4] as List).cast<String>(),
      attacks: (fields[5] as List).cast<String>(),
      stats: (fields[6] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, TeamPokemon obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.types)
      ..writeByte(4)
      ..write(obj.weaknesses)
      ..writeByte(5)
      ..write(obj.attacks)
      ..writeByte(6)
      ..write(obj.stats);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamPokemonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
