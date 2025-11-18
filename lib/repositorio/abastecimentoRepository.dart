import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/abastecimento_Model.dart';
import 'package:rxdart/rxdart.dart';

class AbastecimentoRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AbastecimentoRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _getAbastecimentoCollection(
    String veiculoId,
  ) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('veiculos')
        .doc(veiculoId)
        .collection('abastecimentos');
  }

  Stream<List<Abastecimento>> getAbastecimentos(String veiculoId) {
    return _getAbastecimentoCollection(
      veiculoId,
    ).orderBy('data', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Abastecimento.fromSnapshot(doc))
          .toList();
    });
  }

  Future<void> addAbastecimento(
    String veiculoId,
    Abastecimento abastecimento,
  ) async {
    try {
      await _getAbastecimentoCollection(veiculoId).add(abastecimento.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAbastecimento(
    String veiculoId,
    String abastecimentoId,
  ) async {
    try {
      await _getAbastecimentoCollection(
        veiculoId,
      ).doc(abastecimentoId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Abastecimento>> getAllAbastecimentosByUser() {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) {
        return Stream.value([]);
      } else {
        return _firestore
            .collection('users')
            .doc(user.uid)
            .collection('veiculos')
            .snapshots()
            .switchMap((veiculoSnapshot) {
              if (veiculoSnapshot.docs.isEmpty) {
                return Stream.value([]);
              }
              final List<Stream<List<Abastecimento>>> abastecimentosStreams =
                  veiculoSnapshot.docs.map((veiculoDoc) {
                    return _firestore
                        .collection('users')
                        .doc(user.uid)
                        .collection('veiculos')
                        .doc(veiculoDoc.id)
                        .collection('abastecimentos')
                        .orderBy('data', descending: true)
                        .snapshots()
                        .map(
                          (abastecimentoSubSnapshot) => abastecimentoSubSnapshot
                              .docs
                              .map(
                                (abastecimentoDoc) =>
                                    Abastecimento.fromSnapshot(
                                      abastecimentoDoc,
                                    ),
                              )
                              .toList(),
                        );
                  }).toList();

              return Rx.combineLatestList(abastecimentosStreams).map((
                listOfLists,
              ) {
                return listOfLists.expand((list) => list).toList()
                  ..sort((a, b) => b.data.compareTo(a.data));
              });
            });
      }
    });
  }
}
