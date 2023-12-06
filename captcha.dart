import 'dart:math';
import 'package:flutter/material.dart';

class Captcha extends StatefulWidget {
  double lebar, tinggi;
  int jumlahTitikMaks = 10;
  int jumlahBujurSangkarMaks = 5; // Jumlah maksimal bujursangkar
  int warnaBujurSangkar = 0; // 0: merah, 1: hijau, 2: hitam

  var stokWarna = {
    'merah': Color(0xa9ec1c1c),
    'hijau': Color(0xa922b900),
    'hitam': Color(0xa9000000),
  };
  var warnaTerpakai = {};
  String warnaYangDitanyakan = 'merah';

  Captcha(this.lebar, this.tinggi);

  @override
  State<StatefulWidget> createState() => _CaptchaState();

  bool benarkahJawaban(jawaban) {
    return false;
  }

  int jumlahBujurSangkar() {
    // Mengembalikan jumlah bujursangkar dengan warna tertentu
    return Random().nextInt(jumlahBujurSangkarMaks + 1);
  }
}

class _CaptchaState extends State<Captcha> {
  var random = Random();
  TextEditingController jawabanController = TextEditingController();
  bool isJawabanBenar = false;
  List<Rect> bujursangkarList = [];

  @override
  void initState() {
    super.initState();
    buatPertanyaan();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: widget.lebar,
            height: widget.tinggi,
            child: CustomPaint(
              painter: isJawabanBenar ? BenarPainter() : CaptchaPainter(widget, bujursangkarList),
            ),
          ),
          Text(
            'Berapa jumlah titik warna ${widget.warnaYangDitanyakan}?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, height: 2),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: jawabanController,
              keyboardType: TextInputType.number,
              enabled: !isJawabanBenar,
            ),
          ),
          ElevatedButton(
            onPressed: isJawabanBenar ? null : periksaJawaban,
            child: Text('Jawab'),
          ),
        ],
      ),
    );
  }

  void buatPertanyaan() {
    setState(() {
      isJawabanBenar = false;
      widget.warnaYangDitanyakan = widget.stokWarna.keys.elementAt(random.nextInt(3));
      widget.warnaBujurSangkar = random.nextInt(3); // 0: merah, 1: hijau, 2: hitam

      // Menambahkan logika untuk mengatur ulang daftar bujursangkar
      bujursangkarList.clear();
      for (var i = 0; i < widget.jumlahBujurSangkar(); i++) {
        double startX = random.nextDouble() * widget.lebar;
        double startY = random.nextDouble() * widget.tinggi;
        double endX = random.nextDouble() * widget.lebar;
        double endY = random.nextDouble() * widget.tinggi;

        bujursangkarList.add(Rect.fromPoints(Offset(startX, startY), Offset(endX, endY)));
      }
    });
  }

  void periksaJawaban() {
    int jawabanPengguna = int.tryParse(jawabanController.text) ?? 0;

    if (jawabanPengguna == widget.warnaTerpakai[widget.warnaYangDitanyakan] ||
        (widget.warnaBujurSangkar == 0 && jawabanPengguna == jumlahBujurSangkar())) {
      // Jawaban benar, tandai sebagai benar dan disable widget
      setState(() {
        isJawabanBenar = true;
      });
    } else {
      // Jawaban salah, acak ulang titik-titik dan buat pertanyaan baru
      setState(() {
        buatPertanyaan();
      });
    }
  }

  int jumlahBujurSangkar() {
    // Mengembalikan jumlah bujursangkar dengan warna tertentu
    return random.nextInt(widget.jumlahBujurSangkarMaks + 1);
  }
}

class CaptchaPainter extends CustomPainter {
  Captcha captcha;
  List<Rect> bujursangkarList;
  var random = Random();

  CaptchaPainter(this.captcha, this.bujursangkarList);

  @override
  void paint(Canvas canvas, Size size) {
    var catBingkai = Paint()
      ..color = Color(0xFF000000)
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Offset(0, 0) & Size(captcha.lebar, captcha.tinggi), catBingkai);

    captcha.stokWarna.forEach((key, value) {
      var jumlah = random.nextInt(captcha.jumlahTitikMaks + 1);
      if (jumlah == 0) jumlah = 1;
      captcha.warnaTerpakai[key] = jumlah;

      for (var i = 0; i < jumlah; i++) {
        var catTitik = Paint()
          ..color = value
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(
            random.nextDouble() * captcha.lebar,
            random.nextDouble() * captcha.tinggi),
            6, catTitik);
      }
    });

    // Menggambar bujursangkar dengan warna tertentu
    var catBujurSangkar = Paint()
      ..color = captcha.stokWarna.values.toList()[captcha.warnaBujurSangkar]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var bujursangkar in bujursangkarList) {
      canvas.drawRect(bujursangkar, catBujurSangkar);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BenarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    // Menampilkan kata "BENAR" pada painter
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: 'BENAR',
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(
        canvas, Offset((size.width - textPainter.width) / 2, size.height / 2));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
