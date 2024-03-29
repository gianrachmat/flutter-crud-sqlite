import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uts_unsia/data/datasource/database/nilai_database_impl.dart';
import 'package:uts_unsia/data/entity/nilai_entity.dart';
import 'package:uts_unsia/data/repository/nilai_repo_impl.dart';
import 'package:uts_unsia/domain/model/mahasiswa.dart';
import 'package:uts_unsia/domain/model/nilai.dart';
import 'package:uts_unsia/domain/repo/nilai_repo.dart';
import 'package:uts_unsia/presentation/view/input_model_view.dart';

class TambahListPage extends StatefulWidget {
  const TambahListPage({
    super.key,
    required this.title,
    this.isUpdate = false,
    this.nilai,
    this.mhs,
  });

  final String title;
  final bool isUpdate;
  final Nilai? nilai;
  final Mahasiswa? mhs;

  @override
  State<TambahListPage> createState() => _TambahListPageState();
}

class _TambahListPageState extends State<TambahListPage> {
  final List<String> _radioItems = [
    'Sistem Informasi',
    'Informatika',
  ];
  late String _selectedRadio;
  final NilaiRepo _nilaiRepo = NilaiRepoImpl(NilaiDatabaseImpl());
  bool _loading = false;
  late List<InputModel> _models;

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate) {
      _selectedRadio =
          widget.mhs?.prodi ?? widget.nilai?.mhs.prodi ?? _radioItems.first;
    } else {
      _selectedRadio = _radioItems.first;
    }
    _models = _generateModel();
    debugPrint('${widget.mhs?.toMap()}');
  }

  void _pressButton(String button) {
    switch (button) {
      case 'Update':
        _pressTambah();
        break;
      case 'Tambah':
        _pressTambah();
        break;
      case 'Hapus':
        _pressHapus();
        break;
      default:
        break;
    }
  }

  Future<void> _pressTambah() async {
    DataEntity entity = {};
    bool empty = false;
    if (widget.isUpdate) {
      entity.addAll(widget.nilai!.toMap());
    }
    for (var im in _models) {
      if (im.type == InputType.text || im.type == InputType.number) {
        if (im.controller!.text.isEmpty) {
          empty = true;
          return;
        } else {
          if (im.type == InputType.number) {
            entity[im.field] = int.tryParse(im.controller!.text);
          } else {
            entity[im.field] = im.controller!.text;
          }
        }
      }
      if (im.type == InputType.radio) {
        entity[im.field] = _selectedRadio;
      }
    }
    if (widget.mhs != null) {
      entity['mhsId'] = widget.mhs?.id;
    }
    debugPrint('entity mhs ${entity}');
    if (!empty) {
      setState(() {
        _loading = true;
      });
      if (widget.isUpdate) {
        await _nilaiRepo.updateNilai(Nilai.fromMap(entity));
      } else {
        await _nilaiRepo.createNilai(Nilai.fromMap(entity));
      }
      setState(() {
        _loading = false;
        Navigator.of(context).pop();
      });
    } else {
      Fluttertoast.showToast(msg: 'Ada data yang belum diisi');
    }
  }

  Future<void> _pressHapus() async {
    if (widget.nilai == null) return;
    setState(() {
      _loading = true;
    });
    await _nilaiRepo.deleteNilai(widget.nilai!);
    setState(() {
      _loading = false;
      Navigator.of(context).pop();
    });
  }

  List<InputModel> _generateModel() {
    return [
      InputModel(
        'Nama',
        InputType.text,
        readOnly: true,
        controller: TextEditingController(),
        field: 'nama',
        value: widget.mhs?.nama ?? widget.nilai?.mhs.nama ?? '',
      ),
      InputModel(
        'NIM',
        InputType.text,
        readOnly: true,
        controller: TextEditingController(),
        field: 'nim',
        value: widget.mhs?.nim ?? widget.nilai?.mhs.nim ?? '',
      ),
      InputModel(
        'Prodi',
        InputType.text,
        readOnly: true,
        controller: TextEditingController(),
        field: 'prodi',
        value: widget.mhs?.prodi ?? widget.nilai?.mhs.prodi ?? '',
      ),
      InputModel(
        'Nilai Absen',
        InputType.number,
        field: 'nilaiAbsen',
        controller: TextEditingController(),
        value: "${widget.nilai?.nilaiAbsen ?? ''}",
      ),
      InputModel(
        'Nilai Tugas/Praktikum',
        InputType.number,
        field: 'nilaiTugas',
        controller: TextEditingController(),
        value: "${widget.nilai?.nilaiTugas ?? ''}",
      ),
      InputModel(
        'Nilai UTS',
        InputType.number,
        field: 'nilaiUTS',
        controller: TextEditingController(),
        value: "${widget.nilai?.nilaiUTS ?? ''}",
      ),
      InputModel(
        'Nilai UAS',
        InputType.number,
        field: 'nilaiUAS',
        controller: TextEditingController(),
        value: "${widget.nilai?.nilaiUAS ?? ''}",
      ),
      InputModel(
        '',
        InputType.button,
        buttons: [
          widget.isUpdate ? 'Update' : 'Tambah',
          if (widget.isUpdate) 'Hapus',
        ],
      ),
    ];
  }

  Widget _buildItem() {
    List<Widget> model = _models.map((InputModel e) {
      return InputModelView(
        model: e,
        onButtonPressed: _pressButton,
      );
    }).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(children: model),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: _buildItem(),
            ),
    );
  }
}
