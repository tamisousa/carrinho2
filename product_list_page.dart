import 'package:cadastrocombanco/database/product_database.dart';
import 'package:cadastrocombanco/page/components/list_item.dart';
import 'package:flutter/material.dart';

import '../../model/produto.model.dart';
import 'product_form_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<ProdutoModel>> _futureProdutos;

  @override
  void initState() {
    super.initState();
    _futureProdutos = _carregarProdutos();
  }

  Future<List<ProdutoModel>> _carregarProdutos() async {
    final db = ProductDatabase();
    return await db.findAllProducts();
  }

  Future<void> _updateList() async {
    setState(() {
      _futureProdutos = _carregarProdutos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Produtos',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: const [
          IconButton(
            icon: Icon(Icons.list, color: Colors.white),
            onPressed: null,
          ),
        ],
      ),
      backgroundColor: Colors.deepPurple[100],
      body: FutureBuilder<List<ProdutoModel>>(
        future: _futureProdutos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.grey),
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar produtos'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum produto encontrado.'));
          }

          final listaProduto = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 75),
            itemCount: listaProduto.length,
            itemBuilder: (context, index) {
              final produto = listaProduto[index];
              return ListItem(product: produto, onUpdate: _updateList);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          ProdutoModel? produto = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormPage()),
          );
          if (produto != null) {
            final db = ProductDatabase();
            await db.insertProduct(produto);
            _updateList(); // Recarrega a lista após inserir
          }
        },
        label: const Text(
          'Adicionar Produto',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
