import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart';
import 'bloc/gen_bloc.dart';
import 'models/gen_model.dart';

class GenScreen extends StatefulWidget {
  const GenScreen({super.key});

  static Widget builder(BuildContext context) {
    return BlocProvider<GenBloc>(
      create: (context) => GenBloc(GenState(
        genModelObj: GenModel(),
      ))
        ..add(GenInitialEvent()),
      child: const GenScreen(),
    );
  }

  @override
  _GenScreenState createState() => _GenScreenState();
}

class _GenScreenState extends State<GenScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: BlocBuilder<GenBloc, GenState>(
            builder: (context, state) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: EdgeInsets.all(16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTitleSection(),
                        SizedBox(height: 24.h),
                        _buildInputSection(context, state),
                        SizedBox(height: 16.h),
                        if (state.url.isNotEmpty) _buildResultSection(context, state),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: theme.colorScheme.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.logout, color: theme.colorScheme.primary),
        onPressed: () {
          context.read<GenBloc>().add(LogOutEvent());
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: theme.colorScheme.primary),
          onPressed: () {
            // TODO: Implement settings page
          },
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image Generation',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Create stunning images with AI-powered prompts',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection(BuildContext context, GenState state) {
    return Column(
      children: [
        CustomTextFormField(
          controller: state.textInputController ?? TextEditingController(),
          hintText: "Enter your image generation prompt",
          prefixIcon: Icon(Icons.text_fields, color: theme.colorScheme.primary),
          textInputAction: TextInputAction.done,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.h,
            vertical: 16.h,
          ),
          borderDecoration: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.h),
            borderSide: BorderSide(color: theme.colorScheme.secondary),
          ),
        ),
        SizedBox(height: 16.h),
        CustomElevatedButton(
          isDisabled: state.loading,
          onPressed: state.loading || state.textInputController == null
              ? null
              : () {
                  final prompt = state.textInputController!.text;
                  if (prompt.isNotEmpty) {
                    context.read<GenBloc>().add(GenerateEvent(prompt: prompt));
                  }
                },
          height: 56.h,
          text: state.loading ? "Generating..." : "Generate Image",
          buttonStyle: ElevatedButton.styleFrom(
            backgroundColor: state.loading ? Colors.grey : theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection(BuildContext context, GenState state) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.h),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.secondary.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.all(16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Generated Image URL',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () async {
              await launchUrlString(state.url);
            },
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: state.url));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('URL copied to clipboard',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
            },
            child: Text(
              state.url,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
