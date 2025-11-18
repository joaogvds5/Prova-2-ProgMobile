import 'package:flutter/material.dart';
import '../models/veiculo_Model.dart';
import '../repositorio/veiculoRepository.dart';

class VeiculoViewModel extends ChangeNotifier {
  final VeiculoRepository _repository;

  VeiculoViewModel({required VeiculoRepository repository})
    : _repository = repository;

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

  Future<bool> addVeiculo({
    required String marca,
    required String modelo,
    required String ano,
    required String placa,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final intAno = int.tryParse(ano);
      if (intAno == null) {
        _setError('Ano inválido');
        _setLoading(false);
        return false;
      }

      final veiculo = Veiculo(
        marca: marca,
        modelo: modelo,
        ano: intAno,
        placa: placa,
      );
      await _repository.addVeiculo(veiculo);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erro ao adicionar veículo: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateVeiculo({
    required String id,
    required String marca,
    required String modelo,
    required String ano,
    required String placa,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final intAno = int.tryParse(ano);
      if (intAno == null) {
        _setError('Ano inválido');
        _setLoading(false);
        return false;
      }

      final veiculo = Veiculo(
        id: id,
        marca: marca,
        modelo: modelo,
        ano: intAno,
        placa: placa,
      );
      await _repository.updateVeiculo(veiculo);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erro ao atualizar veículo: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> deleteVeiculo(String veiculoId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.deleteVeiculo(veiculoId);
    } catch (e) {
      _setError('Erro ao deletar veículo: $e');
    } finally {
      _setLoading(false);
    }
  }
}
