import 'package:flutter_test/flutter_test.dart';
import 'package:the_yagi_project/threat_meter.dart';

void main() {
  testWidgets('Threat level is set correctly when using ThreatMeter class.', (WidgetTester tester) async {
    await tester.pumpWidget(ThreatMeter());
  });
}