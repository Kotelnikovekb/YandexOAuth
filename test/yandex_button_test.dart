import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yandexoauth/yandexoauth.dart';

final _avatarImage = MemoryImage(
  Uint8List.fromList(const [
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ]),
);

void main() {
  testWidgets('YandexButton uses configured size and handles taps', (
    WidgetTester tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: YandexButton.main(
              size: YandexButtonSize.xxl,
              onPressed: () => taps++,
            ),
          ),
        ),
      ),
    );

    final buttonFinder = find.byType(YandexButton);
    expect(tester.getSize(buttonFinder), const Size(260, 56));

    await tester.tap(buttonFinder);
    expect(taps, 1);
    expect(find.text('Войти с Яндекс ID'), findsOneWidget);
  });

  testWidgets('YandexButton.icon uses square dimensions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: YandexButton.iconBg(
              size: YandexButtonSize.m,
              iconStyle: YandexButtonIconStyle.circle,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(YandexButton)), const Size(44, 44));
  });

  testWidgets('YandexButton supports additional type with app theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.light),
        home: Scaffold(
          body: Center(
            child: YandexButton.additional(
              size: YandexButtonSize.m,
              text: 'Войти как Юрий',
              avatar: _avatarImage,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Войти как Юрий'), findsOneWidget);
    final buttonSize = tester.getSize(find.byType(YandexButton));
    expect(buttonSize.width, closeTo(204.28571428571428, 0.001));
    expect(buttonSize.height, 44);
  });

  testWidgets('YandexButton supports icon type without background', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: Scaffold(
          body: Center(
            child: YandexButton.iconOnly(
              iconType: YandexButtonIconType.yaEng,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(YandexButton)), const Size(44, 44));
  });
}
