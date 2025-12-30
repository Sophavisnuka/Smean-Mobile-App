import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/providers/language_provider.dart';
import 'package:smean_mobile_app/ui/screens/register_login_screen/login_screen.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  List<PageViewModel> _getListPagesViewModel(bool isKhmer) => [
    PageViewModel(
      title: isKhmer ? "ស្វាគមន៍" : "Welcome",
      body: isKhmer ? "សូមស្វាគមន៍មកកាន់កម្មវិធី SMEAN Mobile App" : "Welcome to SMEAN Mobile App",
      image: const Center(child: Icon(Icons.record_voice_over, size: 100.0)),
    ),
    PageViewModel(
      title: isKhmer ? "លក្ខណៈពិសេស_01" : "Features_01",
      body: isKhmer ? "SMEAN បម្លែងសំឡេងខ្មែររបស់អ្នកទៅជាអត្ថបទក្នុងរយៈពេលវេលាខ្លី។" : "SMEAN Convert Your Khmer Speech to Text Within Seconds.",
      image: const Center(child: Icon(Icons.text_fields_outlined, size: 100.0)),
    ),
    PageViewModel(
      title: isKhmer ? "លក្ខណៈពិសេស_02" : "Features_02",
      body: isKhmer
        ? "បង្កើតសេចក្តីសង្ខេបដែលមានអត្ថន័យពីការបកប្រែដែលបានបង្កើត។"
        : "Generate an insightful Summarization of your the generated transcription.",
      image: const Center(child: Icon(Icons.summarize, size: 100.0)),
    ),
    PageViewModel(
      title: isKhmer ? "លក្ខណៈពិសេស_03" : "Features_03",
      body: isKhmer
        ? "ផ្តល់ជូនមុខងារ Live Transcription ដើម្បីបង្កើតសំឡេងរបស់អ្នកភ្លាមៗ។"
        : "Provided a Live Transcription feature to generate you voice Instantly.",
      image: const Center(child: Icon(Icons.voice_chat, size: 100.0)),
    ),
    PageViewModel(
      title: isKhmer ? "ចាប់ផ្តើម" : "Get Started",
      body: isKhmer ? "ចាប់ផ្តើមដំណើរដ៏អស្ចារ្យរបស់អ្នកជាមួយ SMEAN!" : "Begin your wonderful journey with SMEAN!",
      image: const Center(child: Icon(Icons.rocket_launch, size: 100.0)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSwitcherButton()
          ),
        ],
      ),
      body: IntroductionScreen(
        pages: _getListPagesViewModel(isKhmer),
        showNextButton: true,
        showSkipButton: true,
        freeze: false,
        allowImplicitScrolling: true,
        next: const Icon(Icons.arrow_forward),
        skip: Text(isKhmer ? "រំលង" : "Skip", style: const TextStyle(fontWeight: FontWeight.w700)),
        done: Text(isKhmer ? "បញ្ចប់" : "Done", style: const TextStyle(fontWeight: FontWeight.w700)),
        onDone: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        },
        onSkip: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        },
        baseBtnStyle: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100.0)),
          ),
          fixedSize: const Size(60.0, 60.0),
          backgroundColor: const Color(0xFF1194b4),
        ),
        skipStyle: TextButton.styleFrom(foregroundColor: Colors.white),
        nextStyle: TextButton.styleFrom(foregroundColor: Colors.white),
        doneStyle: TextButton.styleFrom(foregroundColor: Colors.white),
        dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Theme.of(context).colorScheme.secondary,
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }
}
