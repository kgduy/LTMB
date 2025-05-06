import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../dtb/Databasehelper.dart'; // Thay đường dẫn nếu khác
import 'Login.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final DBHelper _dbHelper = DBHelper();

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _username = '';

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_password != _confirmPassword) {
        _showMessage("Mật khẩu không khớp");
        return;
      }

      final success = await _dbHelper.registerUser(
        id: Uuid().v4(),
        username: _username,
        email: _email,
        password: _password,
      );

      if (success) {
        _showMessage("Đăng ký thành công!", isSuccess: true);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      } else {
        _showMessage("Email hoặc tên người dùng đã tồn tại");
      }
    }
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đăng ký tài khoản")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Tên người dùng"),
                validator: (value) => value!.isEmpty ? "Vui lòng nhập tên người dùng" : null,
                onSaved: (value) => _username = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) => value!.isEmpty ? "Vui lòng nhập email" : null,
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Mật khẩu"),
                obscureText: true,
                validator: (value) => value!.length < 6 ? "Mật khẩu ít nhất 6 ký tự" : null,
                onSaved: (value) => _password = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Nhập lại mật khẩu"),
                obscureText: true,
                validator: (value) => value!.isEmpty ? "Vui lòng nhập lại mật khẩu" : null,
                onSaved: (value) => _confirmPassword = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: Text("Đăng ký")),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Đã có tài khoản? Đăng nhập"),
              )
            ],
          ),
        ),
      ),
    );
  }
}