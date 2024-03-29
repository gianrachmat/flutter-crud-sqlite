import 'package:flutter/foundation.dart';
import 'package:uts_unsia/data/datasource/database/nilai_database.dart';
import 'package:uts_unsia/domain/model/nilai.dart';
import 'package:uts_unsia/domain/model/nilai_list.dart';
import 'package:uts_unsia/domain/repo/nilai_repo.dart';

class NilaiRepoImpl implements NilaiRepo {
  final NilaiDatabase database;

  const NilaiRepoImpl(this.database);

  @override
  Future<Nilai> createNilai(Nilai nilai) async {
    debugPrint('nilai mhs ${nilai.mhs.toMap()}');
    final nilaiEntity = await database.insertNilai(nilai.toMap(insert: true));
    return Nilai.fromMap(nilaiEntity);
  }

  @override
  Future<void> deleteNilai(Nilai nilai) async {
    await database.deleteNilai(nilai.id);
  }

  @override
  Future<NilaiList> getNilaiList() async {
    final nilaiListEntity = await database.allNilai();
    return NilaiList.fromMap(nilaiListEntity);
  }

  @override
  Future<void> updateNilai(Nilai nilai) async {
    await database.updateNilai(nilai.toMap(insert: true));
  }

}