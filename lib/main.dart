import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Vòng Xoay Flutter Lớn Hơn')),
        body: Center(
          child: RotatingCircle(),
        ),
      ),
    );
  }
}

class RotatingCircle extends StatefulWidget {
  @override
  _RotatingCircleState createState() => _RotatingCircleState();
}

class _RotatingCircleState extends State<RotatingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startRotation() {
    if (_controller.isAnimating) return; // Tránh nhấn nhiều lần khi đang xoay
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    // --- THAY ĐỔI KÍCH THƯỚC Ở ĐÂY ---
    final double circleSize = 350.0; // Tăng kích thước vòng tròn

    return Container(
      width: circleSize,
      height: circleSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: _rotationAnimation.drive(Tween(begin: 0.0, end: 1.0)),
            child: CustomPaint(
              size: Size(circleSize, circleSize),
              // Truyền kích thước vào painter để tính toán vị trí số
              painter: YellowSectionsPainter(outerRadius: circleSize / 2),
            ),
          ),
          GestureDetector(
            onTap: _startRotation,
            child: CustomPaint(
              size: Size(circleSize, circleSize),
              painter: BlueSectionPainter(),
            ),
          ),
          CustomPaint(
            size: Size(circleSize / 3.5, circleSize / 3.5), // Điều chỉnh kích thước vòng tròn giữa nếu cần
            painter: CenterCirclePainter(),
          ),
        ],
      ),
    );
  }
}

// --- Custom Painters ---

class BlueSectionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue.shade700 // Màu xanh đậm hơn chút
      ..style = PaintingStyle.fill;
    final Paint borderPaint = Paint() // Viền cho phần xanh
      ..color = Colors.black54
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;


    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final double startAngle = -math.pi / 4;
    final double sweepAngle = math.pi / 2;

    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
    // Vẽ viền cho phần xanh
    canvas.drawArc(rect, startAngle, sweepAngle, true, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class YellowSectionsPainter extends CustomPainter {
  // Thêm outerRadius để tính vị trí số
  final double outerRadius;
  YellowSectionsPainter({required this.outerRadius});

  // Hàm helper để vẽ text
  void _paintText(Canvas canvas, Size size, String text, double angle, double radiusFraction) {
    final center = Offset(size.width / 2, size.height / 2);
    final textStyle = TextStyle(
      color: Colors.black87,
      fontSize: outerRadius * 0.15, // Kích thước chữ tỉ lệ với bán kính
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width);

    // Tính toán vị trí tâm của text
    final textRadius = outerRadius * radiusFraction; // Khoảng cách từ tâm đến text
    final textX = center.dx + textRadius * math.cos(angle);
    final textY = center.dy + textRadius * math.sin(angle);

    // Tính offset để vẽ text sao cho tâm text nằm đúng vị trí đã tính
    final offset = Offset(textX - textPainter.width / 2, textY - textPainter.height / 2);
    textPainter.paint(canvas, offset);
  }


  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.amber // Màu vàng amber đẹp hơn
      ..style = PaintingStyle.fill;
    final Paint linePaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2; // Chính là outerRadius

    final double blueStartAngle = -math.pi / 4;
    final double blueSweepAngle = math.pi / 2;
    final double yellowStartAngle = blueStartAngle + blueSweepAngle;
    final double yellowSweepAngle = math.pi * 3 / 2;
    final double singleYellowSweep = yellowSweepAngle / 3; // Góc của 1 phần vàng

    // Vẽ cung lớn màu vàng
    canvas.drawArc(rect, yellowStartAngle, yellowSweepAngle, true, paint);

    // Vẽ các đường kẻ chia phần màu vàng
    Offset p1_start = center + Offset.fromDirection(yellowStartAngle, radius);
    canvas.drawLine(center, p1_start, linePaint);

    Offset p2_mid1 = center + Offset.fromDirection(yellowStartAngle + singleYellowSweep, radius);
    canvas.drawLine(center, p2_mid1, linePaint);

    Offset p3_mid2 = center + Offset.fromDirection(yellowStartAngle + 2 * singleYellowSweep, radius);
    canvas.drawLine(center, p3_mid2, linePaint);

    // Vẽ lại đường viền cung lớn
    final Paint borderPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawArc(rect, yellowStartAngle, yellowSweepAngle, true, borderPaint);

    // --- VẼ SỐ 1, 2, 3 ---
    final double textRadiusFraction = 0.65; // Tỉ lệ khoảng cách từ tâm để đặt số (0.0 -> 1.0)

    // Góc giữa của từng phần vàng
    final double angle1 = yellowStartAngle + singleYellowSweep / 2;
    final double angle2 = yellowStartAngle + singleYellowSweep + singleYellowSweep / 2;
    final double angle3 = yellowStartAngle + 2 * singleYellowSweep + singleYellowSweep / 2;

    // Sử dụng hàm helper để vẽ số
    _paintText(canvas, size, "1", angle1, textRadiusFraction);
    _paintText(canvas, size, "2", angle2, textRadiusFraction);
    _paintText(canvas, size, "3", angle3, textRadiusFraction);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CenterCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.deepOrange // Màu cam đậm hơn
      ..style = PaintingStyle.fill;
    final Paint borderPaint = Paint() // Thêm viền cho đẹp
      ..color = Colors.black54
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;


    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width / 2,
        paint);
    canvas.drawCircle( // Vẽ thêm viền
        Offset(size.width / 2, size.height / 2),
        size.width / 2,
        borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}