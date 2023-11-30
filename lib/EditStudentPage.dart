import 'package:flutter/material.dart';
import 'package:flutter_project/main.dart';

class EditStudentPage extends StatefulWidget {
  final Etudiant etudiant;
  final Function(Etudiant) updateEtudiant;

  EditStudentPage({
    required this.etudiant,
    required this.updateEtudiant,
  });

  @override
  _EditStudentPageState createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  TextEditingController nomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nomController.text = widget.etudiant.nom;
    prenomController.text = widget.etudiant.prenom;
    ageController.text = widget.etudiant.age.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier Étudiant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nomController,
              decoration: InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: prenomController,
              decoration: InputDecoration(labelText: 'Prénom'),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: 'Âge'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedEtudiant = Etudiant(
                  id: widget.etudiant.id,
                  nom: nomController.text,
                  prenom: prenomController.text,
                  age: int.parse(ageController.text),
                  imageUrl: widget.etudiant
                      .imageUrl, // Assurez-vous de fournir l'URL de l'image.
                );

                // Appeler la fonction de mise à jour passée en paramètre
                widget.updateEtudiant(updatedEtudiant);
              },
              child: Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
