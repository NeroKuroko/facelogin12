import 'package:face_login/locator.dart';
import 'package:face_login/pages/db/databse_helper.dart';
import 'package:face_login/pages/home.dart';
import 'package:face_login/pages/models/user.model.dart';
import 'package:face_login/pages/profile.dart';
import 'package:face_login/pages/widgets/app_button.dart';
import 'package:face_login/services/camera.service.dart';
import 'package:face_login/services/ml_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_text_field.dart';

class AuthActionButton extends StatefulWidget {
  const AuthActionButton(
      {Key? key,
      required this.onPressed,
      required this.isLogin,
      required this.reload});
  final Function onPressed;
  final bool isLogin;
  final Function reload;
  @override
  // ignore: library_private_types_in_public_api
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  final MLService _mlService = locator<MLService>();
  final CameraService _cameraService = locator<CameraService>();

  final TextEditingController _userTextEditingController =
      TextEditingController(text: '');
  final TextEditingController _passwordTextEditingController =
      TextEditingController(text: '');

  User? predictedUser;

  Future _signUp(context) async {
    DatabaseHelper databaseHelper = DatabaseHelper.instance;
    List predictedData = _mlService.predictedData;
    String user = _userTextEditingController.text;
    String password = _passwordTextEditingController.text;
    User userToSave = User(
      user: user,
      password: password,
      modelData: predictedData,
    );
    await databaseHelper.insert(userToSave);
    _mlService.setPredictedData([]);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const MyHomePage()));
  }

  Future _signIn(context) async {
    String password = _passwordTextEditingController.text;
    if (predictedUser!.password == password) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => Profile(
                    predictedUser!.user,
                    imagePath: _cameraService.imagePath!,
                  )));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Contraseña incorrecta!'),
          );
        },
      );
    }
  }

  Future<User?> _predictUser() async {
    User? userAndPass = await _mlService.predict();
    return userAndPass;
  }

  Future onTap() async {
    try {
      bool faceDetected = await widget.onPressed();
      if (faceDetected) {
        if (widget.isLogin) {
          var user = await _predictUser();
          if (user != null) {
            predictedUser = user;
          }
        }
        PersistentBottomSheetController bottomSheetController =
            // ignore: use_build_context_synchronously
            Scaffold.of(context)
                .showBottomSheet((context) => signSheet(context));
        bottomSheetController.closed.whenComplete(() => widget.reload());
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue[200],
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: 60,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Captura',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.camera_alt, color: Colors.white)
          ],
        ),
      ),
    );
  }

  signSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.isLogin && predictedUser != null
              ? Text(
                  'Bienvenido de vuelta, ${predictedUser!.user}.',
                  style: const TextStyle(fontSize: 20),
                )
              : widget.isLogin
                  ? const Text(
                      'Usuario no encontrado 😞',
                      style: TextStyle(fontSize: 20),
                    )
                  : Container(),
          Column(
            children: [
              !widget.isLogin
                  ? AppTextField(
                      controller: _userTextEditingController,
                      labelText: "Nombre",
                    )
                  : Container(),
              const SizedBox(height: 10),
              widget.isLogin && predictedUser == null
                  ? Container()
                  : AppTextField(
                      controller: _passwordTextEditingController,
                      labelText: "Contraseña",
                      isPassword: true,
                    ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              widget.isLogin && predictedUser != null
                  ? AppButton(
                      text: 'Inicio de sesión',
                      onPressed: () async {
                        _signIn(context);
                      },
                      icon: const Icon(
                        Icons.login,
                        color: Colors.white,
                      ),
                    )
                  : !widget.isLogin
                      ? AppButton(
                          text: 'Registro',
                          onPressed: () async {
                            await _signUp(context);
                          },
                          icon: const Icon(
                            Icons.person_add,
                            color: Colors.white,
                          ),
                        )
                      : Container(),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
