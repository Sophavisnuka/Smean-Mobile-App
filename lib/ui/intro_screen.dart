import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:smean_mobile_app/ui/home_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  List<PageViewModel> get listPagesViewModel => [
    PageViewModel(
      title: "Welcome",
      body: "Welcome to SMEAN Mobile App",
      image: const Center(child: Icon(Icons.record_voice_over, size: 100.0)),
    ),
    PageViewModel(
      title: "Features_01",
      body: "SMEAN Convert Your Khmer Speech to Text Within Seconds.",
      image: const Center(child: Icon(Icons.text_fields_outlined, size: 100.0)),
    ),
    PageViewModel(
      title: "Features_02",
      body:
          "Generate an insighful Summarization of your the generated transcription.",
      image: const Center(child: Icon(Icons.summarize, size: 100.0)),
    ),
    PageViewModel(
      title: "Features_03",
      body:
          "Provided a Live Transcription feature to generate you voice Instantly.",
      image: const Center(child: Icon(Icons.voice_chat, size: 100.0)),
    ),
    PageViewModel(
      title: "Get Started",
      body: "Begin your wonderful journey with SMEAN!",
      image: const Center(child: Icon(Icons.rocket_launch, size: 100.0)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: listPagesViewModel,
        showNextButton: true,
        showSkipButton: true,
        freeze: false,
        allowImplicitScrolling: true,
        next: const Icon(Icons.arrow_forward),
        skip: const Text("Skip", style: TextStyle(fontWeight: FontWeight.w700)),
        done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w700)),
        onDone: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        },
        onSkip: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        },
        baseBtnStyle: TextButton.styleFrom(
          shape: const CircleBorder(),
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
