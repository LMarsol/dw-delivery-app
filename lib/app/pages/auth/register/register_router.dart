import 'package:dw9_delivery_app/app/pages/auth/register/register_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'register_controller.dart';

class RegisterRouter {
  RegisterRouter._();

  static Widget get page => MultiProvider(
        providers: [
          Provider<RegisterController>(
            create: (context) => RegisterController(
              context.read(),
            ),
          ),
        ],
        child: const RegisterPage(),
      );
}
