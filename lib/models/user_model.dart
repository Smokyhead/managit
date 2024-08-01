class UserData {
  String id = '';
  String nom = '';
  String prenom = '';
  String email = '';
  String role = '';
  int soldeConge = 0;
  int congePris = 0;
  double sanctions = 0;
  int soldeAnneePrec = 0;

  void fromMap(Map<String, dynamic> data) {
    id = data['id'] ?? '';
    nom = data['Nom'] ?? '';
    prenom = data['Prénom'] ?? '';
    email = data['Email'] ?? '';
    role = data['role'] ?? '';
    soldeConge = data['Solde congé'] ?? 0;
    congePris = data['Congé pris'] ?? 0;
    sanctions = data['Sanctions'] ?? 0;
    soldeAnneePrec = data['Solde congé année prec'] ?? 0;
  }
}
