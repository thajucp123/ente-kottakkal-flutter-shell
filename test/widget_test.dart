import 'package:ente_kottakkal_flutter_shell/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts with WebView shell', (tester) async {
    await tester.pumpWidget(const WebViewShellApp());

    expect(find.byType(WebViewShellApp), findsOneWidget);
  });
}
