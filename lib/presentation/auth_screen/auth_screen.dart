import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_gen/core/environment/environment.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/app_export.dart';
import '../../core/constants/image_constant.dart';
import '../../core/utils/validation_functions.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart';
import 'bloc/auth_bloc.dart';
import 'models/auth_model.dart';

class AuthScreen extends StatefulWidget {
  final bool isInitialRoute;

  const AuthScreen({Key? key, this.isInitialRoute = true}) : super(key: key);

  static Widget builder(BuildContext context) {
    // Check if this is the initial route
    bool isInitialRoute = ModalRoute.of(context)?.settings.name == AppRoutes.initialRoute;
    
    return BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(
        AuthState(
          authModelObj: AuthModel(),
        ),
      ),
      child: AuthScreen(isInitialRoute: isInitialRoute),
    );
  }

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController login = TextEditingController();
  final TextEditingController password = TextEditingController();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Only create animations if it's the initial route
    if (widget.isInitialRoute) {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      );

      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuad,
      ));

      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ));

      _animationController.forward();
    }
  }

  @override
  void dispose() {
    if (widget.isInitialRoute) {
      _animationController.dispose();
    }
    login.dispose();
    password.dispose();
    super.dispose();
  }

  Widget _buildAnimatedContent(Widget child) {
    if (!widget.isInitialRoute) {
      return child;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedContent(_buildWelcomeSection()),
                    SizedBox(height: 32.h),
                    _buildAnimatedContent(_buildLoginSection()),
                    SizedBox(height: 24.h),
                    _buildAnimatedContent(_buildLoginButton()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        FlutterLogo(),
        SizedBox(height: 16.h),
        Text(
          "Welcome Back",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Log in to continue your creative journey",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginSection() {
    return Column(
      children: [
        Text(
          "Login: test@test.com",
          style: theme.textTheme.bodyMedium,
        ),
        CustomTextFormField(
          controller: login,
          hintText: "Username",
          prefixIcon: Icon(Icons.person, color: theme.colorScheme.primary),
          contentPadding: EdgeInsets.fromLTRB(8.h, 8.h, 8.h, 10.h),
        ),
        SizedBox(height: 16.h),
        Text(
          "Password: test123",
          style: theme.textTheme.bodyMedium,
        ),
        CustomTextFormField(
          controller: password,
          hintText: "Password",
          textInputType: TextInputType.visiblePassword,
          obscureText: true,
          prefixIcon: Icon(Icons.lock, color: theme.colorScheme.primary),
          contentPadding: EdgeInsets.fromLTRB(8.h, 8.h, 8.h, 10.h),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildLoginButton() {
    return CustomElevatedButton(
      text: "Log In",
      buttonStyle: CustomButtonStyles.fillPrimary,
      onPressed: () {
        if (login.text.isNotEmpty && password.text.isNotEmpty) {
          if (login.text != Environment.loginUsername ||
              password.text != Environment.loginPassword) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Wrong Authentication Data")),
            );
          } else {
            // Navigate to home or next screen
            context.read<AuthBloc>().add(AuthLoginEvent(
                  login: login.text,
                  password: password.text,
                ));
          }
        }
      },
    );
  }
}
