// import
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/*  ************************************************************************  */

// class principal
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// class layout
class _HomeScreenState extends State<HomeScreen> {
  /*  **********************************************************************  */

  // global
  String _extension;

  File _file;

  /*  **********************************************************************  */

  // widget
  @override
  Widget build(BuildContext context) {
    /*  ********************************************************************  */

    // ativando o void, condição para valores nulos
    _getFile();

    if (_file == null || _file == File("")) {
      _file = File("");
    }
    if (_extension == null || _extension == "") {
      _extension = "";
    }

    /*  ********************************************************************  */

    // return
    return Scaffold(
        appBar: AppBar(
          /* com brightness você pode alterar o tema do seu status bar
          (a barra que fica a hora, sinal, wifi, notificação e etc) */
          brightness: Brightness.dark,
          title: Text("Firebase Storage"),
          centerTitle: true,
        ),
        body: Center(
          child: ElevatedButton(
            child: Text("Testar"),
            onPressed: () {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text("Arquivo"),
                  content: IconButton(
                      iconSize: 100.0,
                      icon: Icon(Icons.file_present_outlined),
                      onPressed: () async {
                        _uploadFile();
                        Navigator.pop(context);
                      }),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("Deletar"),
                      onPressed: () {
                        // diferente o download, o void funciona normal.
                        _deleteFile();
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: const Text("Download"),
                      onPressed: () {
                        // se você fiz upload, aconselho a não fazer download em seguida.
                        // depois e a tela atualiza, o void funciona normal.
                        _downloadFile();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ));
  }

  /*  **********************************************************************  */

  // void
  void _getFile() {
    // carregando o arquivo
    FirebaseStorage.instance
        .ref()
        .child("/collection/doc/file_name")
        .getDownloadURL()
        .then((value) {
      setState(() {
        _file = File(value);
      });
    }).catchError((value) {
      print("Error: $value");
    });
  }

  void _uploadFile() async {
    // abrindo o diretório externo do app
    FilePickerResult result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["png", "jpg", "jpeg", "pdf"]);

    // atualizando os campos
    if (result != null) {
      setState(() {
        _file = File(result.files.single.path);
        _extension = "${result.files.single.extension}";
      });

      // upload no firebase
      FirebaseStorage.instance
          .ref()
          .child("/collection/doc/file_name")
          .putFile(_file)
          .then((doc) {
        _onSucess("upload");
      }).catchError((doc) {
        print("Error: $doc");

        _onFail("upload");
      });
    }
  }

  void _deleteFile() {
    // carregando o arquivo e deletando
    FirebaseStorage.instance
        .ref()
        .child("/collection/doc/file_name")
        .delete()
        .then((value) {
      _onSucess("delete");
    }).catchError((value) {
      setState(() {
        _onFail("delete");
      });
    });
  }

  void _onSucess(String text) {
    // snackbar
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Sucesso ao fazer o $text."),
      backgroundColor: Colors.greenAccent,
      duration: Duration(seconds: 2),
    ));
  }

  void _onFail(String text) {
    // snackbar
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Falha ao fazer o $text."),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }

  /*  **********************************************************************  */

  // future
  Future<Null> _downloadFile() async {
    try {
      // diretório externo do app, referência do arquivo no firebase
      Directory directoryExt = await getExternalStorageDirectory();
      Reference reference = FirebaseStorage.instance.refFromURL(_file.path);

      // criação do diretório, condição
      Directory directory = Directory(directoryExt.path + "/Seu_Diretório/");
      if (!directory.existsSync()) {
        await directory.create(recursive: true);
      }

      if (_extension != "png" || _extension != "jpg" || _extension != "jpeg") {
        _extension = "pdf";
      }

      // criação do arquivo que será salvo
      File file = File(directory.path + reference.name + ".$_extension");

      // download do arquivo
      FirebaseStorage.instance
          .ref()
          .child("/collection/doc/file_name")
          .writeToFile(file);

      _onSucess("download");
    } catch (e) {
      // apenas para mostrar o erro caso ocorra
      print("Error: $e");

      _onFail("download");
    }
  }

  /*  **********************************************************************  */
}