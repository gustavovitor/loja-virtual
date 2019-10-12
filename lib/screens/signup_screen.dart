import 'package:flutter/material.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _globalFormKey = new GlobalKey<FormState>();

  final _nameController = new TextEditingController();
  final _emailController = new TextEditingController();
  final _passController = new TextEditingController();
  final _addressController = new TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Criar Conta'),
          centerTitle: true,
        ),
        body: ScopedModelDescendant<UserModel>(
          builder: (context, child, model) {
            if (model.isLoading) {
              return Center(child: CircularProgressIndicator());
            } else {
              return Form(
                key: _globalFormKey,
                child: ListView(
                  padding: EdgeInsets.all(16.0),
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      validator: (text) {
                        if (text.isEmpty) {
                          return 'O nome não pode ser vazio.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(hintText: 'Nome Completo'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    TextFormField(
                      controller: _emailController,
                      validator: (text) {
                        if (text.isEmpty) {
                          return 'O email não pode ser vazio.';
                        }
                        if (!text.contains('@')) {
                          return 'Email inválido.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(hintText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    TextFormField(
                      controller: _passController,
                      validator: (text) {
                        if (text.isEmpty) {
                          return 'A senha não pode ser vazia.';
                        }
                        return null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(hintText: 'Senha'),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    TextFormField(
                      controller: _addressController,
                      validator: (text) {
                        if (text.isEmpty) {
                          return 'O endereço não pode ser vazio';
                        }
                        return null;
                      },
                      decoration: InputDecoration(hintText: 'Endereço'),
                    ),
                    SizedBox(height: 16.0),
                    SizedBox(
                      height: 44.0,
                      child: RaisedButton(
                        child: Text("Criar Conta",
                            style: TextStyle(fontSize: 18.0)),
                        textColor: Colors.white,
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          if (_globalFormKey.currentState.validate()) {
                            Map<String, dynamic> userData = {
                              'name': _nameController.text,
                              'email': _emailController.text,
                              'address': _addressController.text
                            };

                            model.signUp(
                                userData: userData,
                                password: _passController.text,
                                onSuccess: _onSuccess,
                                onFail: _onFail);
                          }
                        },
                      ),
                    )
                  ],
                ),
              );
            }
          },
        ));
  }

  void _onSuccess() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Usuário criado com sucesso.'),
      backgroundColor: Theme.of(context).primaryColor,
      duration: Duration(seconds: 2),
    ));
    Future.delayed(Duration(seconds: 2)).then((_) {
      Navigator.of(context).pop();
    });
  }

  void _onFail() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Falha ao criar o usuário.'),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }
}
