import 'package:flutter/material.dart';

class MahasiswaHomePage extends StatefulWidget {
  const MahasiswaHomePage({super.key});

  @override
  State<MahasiswaHomePage> createState() => _MahasiswaHomePageState();
}

class _MahasiswaHomePageState extends State<MahasiswaHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text('Mahasiswa Home Page'));
  }
}
