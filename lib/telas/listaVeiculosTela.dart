import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/veiculo_Model.dart';
import '../viewmodels/VeiculoViewModel.dart';
import 'EditarVeiculoTela.dart';
import 'listagemAbastecimentosTela.dart';
import '../drawer/app_drawer.dart';

class ListaVeiculos extends StatelessWidget {
  const ListaVeiculos({super.key});

  @override
  Widget build(BuildContext context) {
    final veiculoViewModel = context.read<VeiculoViewModel>();
    final veiculos = context.watch<List<Veiculo>>();

    return Scaffold(
      drawer: const AppDrawer(),

      appBar: AppBar(title: const Text('Meus Veículos')),

      body: ListView.builder(
        itemCount: veiculos.length,
        itemBuilder: (context, index) {
          final veiculo = veiculos[index];

          return Dismissible(
            key: Key(veiculo.id ?? index.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              if (veiculo.id != null) {
                veiculoViewModel.deleteVeiculo(veiculo.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${veiculo.modelo} deletado')),
                );
              }
            },
            child: ListTile(
              title: Text('${veiculo.marca} ${veiculo.modelo}'),
              subtitle: Text('Placa: ${veiculo.placa} - Ano: ${veiculo.ano}'),

              // Ao clicar no item, vai para a lista de abastecimentos
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ListagemAbastecimentosTela(veiculo: veiculo),
                  ),
                );
              },

              // Botão de "editar" no final
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditarVeiculoTela(veiculo: veiculo),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditarVeiculoTela()),
          );
        },
      ),
    );
  }
}
