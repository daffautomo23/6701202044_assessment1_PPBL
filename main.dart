import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StockPage(),
    );
  }
}

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}


class _StockPageState extends State<StockPage> {
  String stockCode = "D"; //  kode saham Saya
  List<double> stockPrices = [];

  Future<void> fetchStockPrices() async {
    var apiKey = 'hXIfN6HgQAe7xSnXyUWzCtfHvIS71voV'; //  API key Anda
    var url =
        'https://api.polygon.io/v2/aggs/ticker/D/range/5/week/2022-01-23/2023-01-08?adjusted=true&sort=asc&limit=4999&apiKey=hXIfN6HgQAe7xSnXyUWzCtfHvIS71voV';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data); // Tambahkan ini untuk memeriksa data yang diterima
      List<dynamic> results = data['results'];
      setState(() {
        stockPrices = results.map((result) => double.parse(result['h'].toString())).toList();
      });
    }

    else {
      throw Exception('Failed to load data');
    }
  }


  @override
  void initState() {
    super.initState();
    fetchStockPrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Price Movement'),
      ),
      body: StockLayout(stockCode: stockCode, stockPrices: stockPrices),
    );
  }
}

class StockLayout extends StatelessWidget {
  final String stockCode;
  final List<double> stockPrices;

  StockLayout({required this.stockCode, required this.stockPrices});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Stock Code: $stockCode',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logika untuk memuat ulang data
              },
              child: Text('Refresh Data'),
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              height: 200,
              child: CustomPaint(
                painter: StockChartPainter(stockPrices),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StockChartPainter extends CustomPainter {
  final List<double> prices;

  StockChartPainter(this.prices);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    var path = Path();
    path.moveTo(0, size.height - prices[0]);
    for (var i = 1; i < prices.length; i++) {
      path.lineTo(i * size.width / (prices.length - 1), size.height - prices[i]);
    }

    canvas.drawPath(path, paint);

    for (var i = 0; i < prices.length; i++) {
      var point = Offset(i * size.width / (prices.length - 1), size.height - prices[i]);
      canvas.drawCircle(point, 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
