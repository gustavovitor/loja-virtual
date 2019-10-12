import 'package:flutter/material.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:loja_virtual/screens/signup_screen.dart';
import 'package:scoped_model/scoped_model.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _globalFormKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  final _emailController = new TextEditingController();
  final _passController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Entrar'),
          centerTitle: true,
          actions: <Widget>[
            FlatButton(
              child: Text(
                'CRIAR CONTA',
                style: TextStyle(fontSize: 15.0),
              ),
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()));
              },
            )
          ],
        ),
        body:
            ScopedModelDescendant<UserModel>(builder: (context, child, model) {
          if (model.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Form(
              key: _globalFormKey,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: <Widget>[
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: FlatButton(
                      onPressed: () {
                        if (_emailController.text.isEmpty) {
                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text('Insira um e-mail para recuperação.'),
                            backgroundColor: Colors.redAccent,
                            duration: Duration(seconds: 2),
                          ));
                        } else {
                          model.recoverPassword(_emailController.text);
                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text('Confira seu e-mail.'),
                            backgroundColor: Theme.of(context).primaryColor,
                            duration: Duration(seconds: 2),
                          ));
                        }
                      },
                      child: Text('Esqueceu sua senha?'),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  SizedBox(
                    height: 44.0,
                    child: RaisedButton(
                      child: Text("Entrar", style: TextStyle(fontSize: 18.0)),
                      textColor: Colors.white,
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        if (_globalFormKey.currentState.validate()) {
                          model.signIn(
                              email: _emailController.text,
                              pass: _passController.text,
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
        }));
  }

  void _onSuccess() {
    Navigator.of(context).pop();
  }

  void _onFail() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Falha ao entrar.'),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }
}
