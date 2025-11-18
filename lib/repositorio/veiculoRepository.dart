import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/veiculo_Model.dart';
import 'package:rxdart/rxdart.dart';

class VeiculoRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  VeiculoRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _getVeiculoCollection() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    return _firestore.collection('users').doc(uid).collection('veiculos');
  }

  Stream<List<Veiculo>> getVeiculo() {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) {
        return Stream.value([]);
      } else {
        return _firestore
            .collection('users')
            .doc(user.uid)
            .collection('veiculos')
            .orderBy('marca')
            .snapshots()
            .map((snapshot) {
              return snapshot.docs
                  .map((doc) => Veiculo.fromSnapshot(doc))
                  .toList();
            });
      }
    });
  }

  Future<void> addVeiculo(Veiculo veiculo) async {
    try {
      await _getVeiculoCollection().add(veiculo.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateVeiculo(Veiculo veiculo) async {
    try {
      if (veiculo.id == null) throw Exception('ID do veículo é nulo');
      await _getVeiculoCollection().doc(veiculo.id).update(veiculo.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteVeiculo(String veiculoId) async {
    try {
      await _getVeiculoCollection().doc(veiculoId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
