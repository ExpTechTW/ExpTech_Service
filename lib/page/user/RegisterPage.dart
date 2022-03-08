import 'package:exptech_service/api/Data.dart' as globals;
import 'package:exptech_service/api/NetWork.dart';
import 'package:exptech_service/page/user/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

String alert = "";

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  GlobalKey _key = GlobalKey<FormState>();
  TextEditingController _user = TextEditingController();
  TextEditingController _pass = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _code = TextEditingController();

  FocusNode _u = FocusNode();
  FocusNode _p = FocusNode();
  FocusNode _e = FocusNode();
  FocusNode _c = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _user.dispose();
    _pass.dispose();
    _email.dispose();
    _code.dispose();
    _u.dispose();
    _p.dispose();
    _e.dispose();
    _c.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _key,
              child: Column(
                children: [
                  TextFormField(
                    focusNode: _u,
                    controller: _user,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.supervised_user_circle_outlined),
                      labelText: "用戶名稱",
                      hintText: "請輸入用戶名稱",
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "用戶名稱不為空";
                      } else if (v.length < 2) {
                        return "用戶名稱不能小於 2 位";
                      } else if (v.length > 32) {
                        return "用戶名稱不能大於 32 位";
                      }
                    },
                    onFieldSubmitted: (v) {},
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    focusNode: _p,
                    controller: _pass,
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.password),
                      labelText: "密碼",
                      hintText: "請輸入密碼",
                    ),
                    textInputAction: TextInputAction.send,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "密碼不為空";
                      } else if (v.length < 6) {
                        return "密碼不能小於 6 位";
                      }
                    },
                    onFieldSubmitted: (v) {},
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    focusNode: _e,
                    controller: _email,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined),
                      labelText: "電子郵件",
                      hintText: "請輸入電子郵件",
                    ),
                    textInputAction: TextInputAction.send,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "電子郵件不為空";
                      }
                    },
                    onFieldSubmitted: (v) {},
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    focusNode: _c,
                    controller: _code,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.code_outlined),
                      labelText: "驗證碼",
                      hintText: "請輸入驗證碼",
                    ),
                    textInputAction: TextInputAction.send,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "驗證碼不為空";
                      } else if (v.length < 6) {
                        return "驗證碼不能小於 6 位";
                      } else if (v.length > 6) {
                        return "驗證碼不能大於 6 位";
                      }
                    },
                    onFieldSubmitted: (v) {},
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: 36,
                        child: TextButton(
                          onPressed: () async {
                            var data = await NetWork(
                                '{"Type":"Mail","Address":"${_email.text}"}');
                            if (data["state"] == "Success") {
                              alert = "已成功發送 驗證碼\n請至 信箱 查看";
                              await showAlert(context);
                            } else {
                              alert = "此 電子郵件 已被註冊\n請使用 登入 功能";
                              await showAlert(context);
                            }
                          },
                          child: const Text("獲取驗證碼"),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            onPressed: () async {
                              if ((_key.currentState as FormState).validate()) {
                                var data = await NetWork(
                                    '{"Type":"register","user":"${_user.text}","pass":"${_pass.text}","email":"${_email.text}","code":"${_code.text}","DeviceID":"${globals.DeviceID}","Platform":"${globals.Platform}","DeviceINFO":"${globals.DeviceINFO}","FirebaseToken":"${globals.FirebaseToken}"}');
                                if (data["state"] == "Success") {
                                  var LocalData = Hive.box('LocalData');
                                  LocalData.put(
                                      "token", data["response"]["token"]);
                                  LocalData.put("UID", data["response"]["UID"]);
                                  globals.Token = data["response"]["Token"];
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                        maintainState: false,
                                        settings: const RouteSettings(
                                          arguments: "Register",
                                        ),
                                      ));
                                } else {
                                  alert = "驗證碼 驗證失敗\n請重新取得 驗證碼";
                                  await showAlert(context);
                                }
                              }
                            },
                            child: const Text("註冊"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> showAlert(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('通知!'),
        content: Text(alert),
        actions: <Widget>[
          TextButton(
            child: const Text('知道了'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
