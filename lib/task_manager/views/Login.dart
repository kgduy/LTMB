import 'package:flutter/material.dart';
import 'Register.dart';
import '../dtb/Databasehelper.dart';
import 'Tasklistsrceen.dart'; // thay bằng màn hình task chính

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final DBHelper _dbHelper = DBHelper();

  String _email = '';
  String _password = '';

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = await _dbHelper.loginUser(_email, _password);

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng nhập thành công"), backgroundColor: Colors.green),
        );

        // Chuyển sang màn hình TaskList, truyền user nếu cần
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(currentUser: user)), // hoặc không cần truyền nếu dùng shared state
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Email hoặc mật khẩu không đúng"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đăng nhập")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) => value!.isEmpty ? "Vui lòng nhập email" : null,
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Mật khẩu"),
                obscureText: true,
                validator: (value) => value!.length < 6 ? "Ít nhất 6 ký tự" : null,
                onSaved: (value) => _password = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: Text("Đăng nhập")),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen())),
                child: Text("Chưa có tài khoản? Đăng ký"),
              )
            ],
          ),
        ),
      ),
    );
  }
}