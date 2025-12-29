import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/providers/language_provider.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';

class CreateAudioScreen extends StatefulWidget {
  const CreateAudioScreen({super.key});

  @override
  State<CreateAudioScreen> createState() => _CreateAudioScreenState();
}

class _CreateAudioScreenState extends State<CreateAudioScreen> {
  final _titleController = TextEditingController();
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _titleController.text = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Audio'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSwitcherButton(),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          
        ),
      ),
    );
  }
}