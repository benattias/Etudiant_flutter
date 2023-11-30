import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/EditStudentPage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Etudiant> etudiants = [];
  TextEditingController nomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  File? _imageFile; // Stocke le fichier image sélectionné

  @override
  void initState() {
    super.initState();
    fetchEtudiants();
  }

  Future<void> createEtudiant() async {
    final newEtudiant = Etudiant(
      id: 0, // Vous devrez générer un ID approprié, car il s'agit d'une création.
      nom: nomController.text,
      prenom: prenomController.text,
      age: int.parse(ageController.text),
      imageUrl: _imageFile
          ?.path, // Utilisez le chemin du fichier image (_imageFile) s'il est sélectionné
    );

    final response = await http.post(
      Uri.parse('http://192.168.56.1:8000/etudiants'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(newEtudiant.toJson()),
    );

    if (response.statusCode == 201) {
      final responseBody = json.decode(response.body);
      final newStudentID = responseBody['id'];
      nomController.clear();
      prenomController.clear();
      ageController.clear();
      _imageFile = null; // Réinitialisez l'image après la création
      fetchEtudiants();
    }
  }

  Future<void> deleteEtudiant(int etudiantId) async {
    final response = await http
        .delete(Uri.parse('http://192.168.56.1:8000/etudiants/$etudiantId'));

    if (response.statusCode == 200) {
      fetchEtudiants();
    }
  }

  Future<void> updateEtudiant(Etudiant etudiant) async {
    final response = await http.put(
      Uri.parse('http://192.168.56.1:8000/etudiants/${etudiant.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(etudiant.toJson()),
    );

    if (response.statusCode == 200) {
      fetchEtudiants();
      Navigator.of(context).pop();
    } else {
      throw Exception('Échec de la mise à jour de l\'étudiant');
    }
  }

  Future<void> fetchEtudiants() async {
    final response =
        await http.get(Uri.parse('http://192.168.56.1:8000/etudiants'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        etudiants =
            data.map((etudiant) => Etudiant.fromJson(etudiant)).toList();
      });
    } else {
      throw Exception('Échec de chargement des étudiants');
    }
  }

  // Méthode pour sélectionner une image
  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Étudiants'),
      ),
      body: ListView.builder(
        itemCount: etudiants.length,
        itemBuilder: (context, index) {
          final etudiant = etudiants[index];
          return Card(
            child: ListTile(
              title: DataTable(
                columns: [
                  DataColumn(label: Text('Nom')),
                  DataColumn(label: Text('Prénom')),
                  DataColumn(label: Text('Âge')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Text(etudiant.nom)),
                    DataCell(Text(etudiant.prenom)),
                    DataCell(Text(etudiant.age.toString())),
                    DataCell(Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: etudiant.imageUrl != null
                              ? NetworkImage(etudiant.imageUrl!)
                              : null,
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditStudentPage(
                                  etudiant: etudiant,
                                  updateEtudiant: (updatedEtudiant) {
                                    updateEtudiant(updatedEtudiant);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteEtudiant(etudiant.id);
                          },
                        ),
                      ],
                    )),
                  ]),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nomController,
                  decoration: InputDecoration(labelText: 'Nom'),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: prenomController,
                  decoration: InputDecoration(labelText: 'Prénom'),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: ageController,
                  decoration: InputDecoration(labelText: 'Âge'),
                ),
              ),
              TextButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.camera),
                label: Text('Ajouter Image'),
              ),
              ElevatedButton(
                onPressed: createEtudiant,
                child: Text('Ajouter Étudiant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Etudiant {
  final int id;
  final String nom;
  final String prenom;
  final int age;
  final String? imageUrl; // Modifiez le type en String?

  Etudiant({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.age,
    this.imageUrl,
  });

  factory Etudiant.fromJson(Map<String, dynamic> json) {
    return Etudiant(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      age: json['age'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'age': age,
      'imageUrl': imageUrl,
    };
  }
}
