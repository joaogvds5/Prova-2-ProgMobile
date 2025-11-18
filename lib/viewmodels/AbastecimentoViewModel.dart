import 'package:flutter/material.dart';
import '../models/abastecimento_Model.dart';
import '../repositorio/abastecimentoRepository.dart';
import 'dart:async';

class AbastecimentoViewmodel extends ChangeNotifier {
  final AbastecimentoRepository _repository;
  StreamSubscription<List<Abastecimento>>? _allAbastecimentosSubscription;
  List<Abastecimento> _allAbastecimentos = [];
  List<Abastecimento> get allAbastecimentos => _allAbastecimentos;

  AbastecimentoViewmodel({required AbastecimentoRepository repository})
    : _repository = repository {
    _listenToAllAbastecimentos();
  }

  void _listenToAllAbastecimentos() {
    _allAbastecimentosSubscription?.cancel();
    _allAbastecimentosSubscription = _repository
        .getAllAbastecimentosByUser()
        .listen(
          (abastecimentos) {
            _allAbastecimentos = abastecimentos;
            notifyListeners();
          },
          onError: (error) {
            _setError('Erro ao carregar histórico: $error');
          },
        );
  }

  @override
  void dispose() {
    _allAbastecimentosSubscription?.cancel();
    super.dispose();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> addAbastecimento({
    required String veiculoId,
    required DateTime data,
    required String litros,
    required String valorTotal,
    required String kmAtual,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final doubleLitros = double.tryParse(litros);
      final doubleValor = double.tryParse(valorTotal);
      final doubleKm = double.tryParse(kmAtual);

      if (doubleLitros == null || doubleValor == null || doubleKm == null) {
        _setError('Valores numéricos inválidos');
        _setLoading(false);
        return false;
      }

      final abastecimento = Abastecimento(
        data: data,
        litros: doubleLitros,
        valorTotal: doubleValor,
        kmAtual: doubleKm,
      );
      await _repository.addAbastecimento(veiculoId, abastecimento);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erro ao adicionar abastecimento: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> deleteAbastecimento(
    String veiculoId,
    String abastecimentoId,
  ) async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.deleteAbastecimento(veiculoId, abastecimentoId);
    } catch (e) {
      _setError('Erro ao deletar abastecimento: $e');
    } finally {
      _setLoading(false);
    }
  }
}
