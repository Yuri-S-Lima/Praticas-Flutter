import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sales_manager/components/botao.dart';
import 'package:sales_manager/components/editar_dados.dart';
import 'package:sales_manager/screens/tap_bar_telas.dart';

class EditarCompra extends StatefulWidget {

  final String nome, data, idProduto, idCliente, idUsuario;
  final double preco, saldoDevedor;
  final int quantidadeAnterior;

  const EditarCompra({Key? key, required this.nome, required this.data, required this.idProduto, required this.idCliente, 
    required this.idUsuario, required this.preco, required this.quantidadeAnterior, required this.saldoDevedor}) : super(key: key);

  @override
  State<EditarCompra> createState() => _EditarCompraState();
}

class _EditarCompraState extends State<EditarCompra> {

  final _nomeControler = TextEditingController();
  final _dataControler = TextEditingController();
  final _precoControler = TextEditingController();
  final _quantidadeControler = TextEditingController();
  final db = FirebaseFirestore.instance;
  late double _aReceber, _totalVendido;

  @override
  initState() {
    super.initState();
    _recebeLucro();
  }

  _recebeLucro() async{
    late double val, vendido;

    await db.collection("Usuários").doc(widget.idUsuario).get().then((doc) => {
      if(doc.exists){
        val = (doc.data()!["A Receber"]) as double,
        vendido = (doc.data()!["Vendido"]) as double,
      }
    },);

    setState(() {
      _aReceber = val;
      _totalVendido = vendido;
    });

  }

  @override
  Widget build(BuildContext context) {

    void _proximaTela() async {

      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (BuildContext context) => 
          const PercorreTelas()
      ));
    }

    _editandoDados() async {
      final nome = _nomeControler.text;
      final data = _dataControler.text;
      final preco = double.tryParse(_precoControler.text);
      final quantidade = int.tryParse(_quantidadeControler.text);

      if(_nomeControler.text == '' && _dataControler.text == '' && _precoControler.text == '' && _quantidadeControler.text == ''){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Todos os campos vazios!"),
            backgroundColor: Colors.redAccent,
          ),
        );

        return;
      }

      if(_nomeControler.text == ''){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Campo nome vazio!"),
            backgroundColor: Colors.redAccent,
          ),
        );

        return;
      }

      if(_dataControler.text == ''){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Campo data vazio!"),
            backgroundColor: Colors.redAccent,
          ),
        );

        return;
      }

      if(_precoControler.text == ''){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Campo endereço vazio!"),
            backgroundColor: Colors.redAccent,
          ),
        );

        return;
      }

      if(_quantidadeControler.text == ''){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Campo quantidade vazio!"),
            backgroundColor: Colors.redAccent,
          ),
        );

        return;
      }

      db.collection("Usuários").doc(widget.idUsuario).collection("Clientes")
        .doc(widget.idCliente).collection("Produtos").doc(widget.idProduto).update({ // atualizando informações do produto no banco de dados
        "Nome": nome,
        "Data": data,
        "Endereço": preco,
        "Quantidade": quantidade,
      });

      db.collection("Usuários").doc(widget.idUsuario).collection("Clientes")
        .doc(widget.idCliente).update({
          "Saldo Devedor": (widget.saldoDevedor - widget.preco) + preco! * quantidade!,
      });

      db.collection("Usuários").doc(widget.idUsuario).update({
        "A Receber": (_aReceber - (widget.preco * widget.quantidadeAnterior)) + preco * quantidade,
        "Vendido": (_totalVendido  - (widget.preco * widget.quantidadeAnterior)) + preco * quantidade,
      });

      db.collection("Usuários").doc(widget.idUsuario).collection("Últimas Vendas").doc(widget.idCliente).update({
        "Produto": nome,
        "Preço": preco,
      });

      _proximaTela();
    }

    return Scaffold(

      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),

        child: Padding(
          padding: const EdgeInsets.all(20),
      
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              
              children: [
          
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                    const Text("Editar compra", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
          
                SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          
                Column(
                  
                  children: [
                    EditarDados(nome: widget.nome, texto: _nomeControler),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    EditarDados(nome: widget.data, texto: _dataControler),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    EditarDados(nome: widget.preco.toString(), texto: _precoControler),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    EditarDados(nome: widget.quantidadeAnterior.toString(), texto: _quantidadeControler),
                  ],
                ),
          
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          
                Botao(titulo: "Salvar", desempilha: true, funcaoGeral: _editandoDados)
              ],
            ),
          ),
        ),
      ),
    );
  }
}