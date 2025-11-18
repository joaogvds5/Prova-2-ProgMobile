import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/veiculo_Model.dart';
import '../viewmodels/VeiculoViewModel.dart';

class EditarVeiculoTela extends StatefulWidget {
  final Veiculo? veiculo;

  const EditarVeiculoTela({super.key, this.veiculo});

  @override
  State<EditarVeiculoTela> createState() => _EditarVeiculoTelaState();
}

class _EditarVeiculoTelaState extends State<EditarVeiculoTela> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _marcaController;
  late final TextEditingController _modeloController;
  late final TextEditingController _anoController;
  late final TextEditingController _placaController;

  bool get _isEditing => widget.veiculo != null;

  @override
  void initState() {
    super.initState();
    _marcaController = TextEditingController(text: widget.veiculo?.marca);
    _modeloController = TextEditingController(text: widget.veiculo?.modelo);
    _anoController = TextEditingController(
      text: widget.veiculo?.ano.toString(),
    );
    _placaController = TextEditingController(text: widget.veiculo?.placa);
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _anoController.dispose();
    _placaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final viewModel = context.read<VeiculoViewModel>();

      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      bool success;
      if (_isEditing) {
        success = await viewModel.updateVeiculo(
          id: widget.veiculo!.id!,
          marca: _marcaController.text,
          modelo: _modeloController.text,
          ano: _anoController.text,
          placa: _placaController.text,
        );
      } else {
        success = await viewModel.addVeiculo(
          marca: _marcaController.text,
          modelo: _modeloController.text,
          ano: _anoController.text,
          placa: _placaController.text,
        );
      }

      if (success) {
        navigator.pop();
      } else {
        if (viewModel.errorMessage != null) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VeiculoViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Veículo' : 'Adicionar Veículo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _marcaController,
                decoration: const InputDecoration(labelText: 'Marca'),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _modeloController,
                decoration: const InputDecoration(labelText: 'Modelo'),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _anoController,
                decoration: const InputDecoration(labelText: 'Ano'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _placaController,
                decoration: const InputDecoration(labelText: 'Placa'),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 20),
              if (viewModel.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(_isEditing ? 'Atualizar' : 'Salvar'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
