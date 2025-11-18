import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/veiculo_Model.dart';
import '../models/abastecimento_Model.dart';
import '../repositorio/abastecimentoRepository.dart';
import '../viewmodels/AbastecimentoViewModel.dart';
import 'AbastecimentosTela.dart';

class ListagemAbastecimentosTela extends StatelessWidget {
  final Veiculo veiculo;

  const ListagemAbastecimentosTela({super.key, required this.veiculo});

  @override
  Widget build(BuildContext context) {
    final abastecimentoViewModel = context.read<AbastecimentoViewmodel>();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return StreamProvider<List<Abastecimento>>.value(
      value: context.read<AbastecimentoRepository>().getAbastecimentos(
        veiculo.id!,
      ),
      initialData: [],
      catchError: (_, error) => [],
      child: Scaffold(
        appBar: AppBar(
          title: Text(veiculo.modelo),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Abastecimentostela(veiculoId: veiculo.id!),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<List<Abastecimento>>(
          builder: (context, abastecimentos, child) {
            if (abastecimentos.isEmpty) {
              return const Center(
                child: Text('Nenhum abastecimento registrado.'),
              );
            }

            return ListView.builder(
              itemCount: abastecimentos.length,
              itemBuilder: (context, index) {
                final abastecimento = abastecimentos[index];
                return Dismissible(
                  key: Key(abastecimento.id!),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    abastecimentoViewModel.deleteAbastecimento(
                      veiculo.id!,
                      abastecimento.id!,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Abastecimento de ${dateFormat.format(abastecimento.data)} deletado',
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(
                      'Data: ${dateFormat.format(abastecimento.data)}',
                    ),
                    subtitle: Text(
                      '${currencyFormat.format(abastecimento.valorTotal)} (${abastecimento.litros} L) - KM: ${abastecimento.kmAtual}\n'
                      '${currencyFormat.format(abastecimento.valorPorLitro)}/L',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
