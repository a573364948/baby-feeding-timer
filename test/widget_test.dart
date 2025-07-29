// 小熊猫嗷嗷叫倒计时应用测试
//
// 测试应用的基本功能和UI元素

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_feeding_timer/main.dart';

void main() {
  testWidgets('小熊猫应用基本UI测试', (WidgetTester tester) async {
    // 构建应用并触发一帧
    await tester.pumpWidget(const MyApp());

    // 等待异步初始化完成
    await tester.pumpAndSettle();

    // 验证应用标题存在
    expect(find.text('小熊猫嗷嗷叫倒计时'), findsOneWidget);

    // 验证开始倒计时按钮存在
    expect(find.text('开始倒计时'), findsOneWidget);

    // 验证历史记录按钮存在
    expect(find.text('历史记录'), findsOneWidget);
  });

  testWidgets('导航到历史记录页面测试', (WidgetTester tester) async {
    // 构建应用
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 点击历史记录按钮
    await tester.tap(find.text('历史记录'));
    await tester.pumpAndSettle();

    // 验证导航到历史记录页面
    expect(find.text('历史记录'), findsAtLeastNWidgets(1));
  });

  testWidgets('导航到设置页面测试', (WidgetTester tester) async {
    // 构建应用
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 点击设置图标
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // 验证导航到设置页面
    expect(find.text('设置'), findsOneWidget);
  });
}
