import 'package:flutter_multiselect/selection_modal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';

import 'package:flutter_multiselect/flutter_multiselect.dart';

void main() {
  List<Map<String, dynamic>> dataSource = [];

  setUp(() => {
        dataSource = List<Map<String, dynamic>>()
          ..addAll([
            {
              "display": "Australia",
              "subText": 'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.',
              "value": 1,
            },
            {
              "display": "Canada",
              "value": 2,
            },
            {
              "display": "India",
              "value": 3,
            },
            {
              "display": "United States",
              "value": 4,
            }
          ])
      });

  Widget getBasicMultiSelectApp(
      MultiSelect multiSelect, NavigatorObserver observer, GlobalKey<FormState> formKey) {
    return MaterialApp(
      home: MyAppToTest(multiSelect, formKey),
      navigatorObservers: [observer],
    );
  }

  testWidgets('Clicking on MultiSelect loads selection modal',
      (WidgetTester tester) async {
    final MockNavigatorObserver mockNavigatorObserver = MockNavigatorObserver();
    final multiSelect = MultiSelect(
      dataSource: dataSource,
      textField: 'display',
      valueField: 'value',
    );
    var app = getBasicMultiSelectApp(multiSelect, mockNavigatorObserver, new GlobalKey<FormState>());
    await tester.pumpWidget(app);
    Finder multiSelectFinder = find.byType(MultiSelect);
    expect(multiSelectFinder, findsOneWidget);
    await tester.tap(multiSelectFinder);
    await tester.pumpAndSettle();
    verify(mockNavigatorObserver.didPush(any, any));
    Finder selectionModalFinder = find.byType(SelectionModal);
    expect(selectionModalFinder, findsOneWidget);
  });

  testWidgets('Selection modal has all elements passed in',
      (WidgetTester tester) async {
    final MockNavigatorObserver mockNavigatorObserver = MockNavigatorObserver();
    final multiSelect = MultiSelect(
      dataSource: dataSource,
      textField: 'display',
      valueField: 'value',
    );
    var app = getBasicMultiSelectApp(multiSelect, mockNavigatorObserver, new GlobalKey<FormState>());
    await tester.pumpWidget(app);
    Finder multiSelectFinder = find.byType(MultiSelect);
    await tester.tap(multiSelectFinder);
    await tester.pumpAndSettle();
    Finder selectionModalFinder = find.byType(SelectionModal);
    Finder selectionOptionsFinder = find.descendant(
        of: selectionModalFinder, matching: find.byType(ListTile));
    expect(selectionOptionsFinder, findsNWidgets(dataSource.length));
  });

  testWidgets('Selection adds to selected option when option clicked',
      (WidgetTester tester) async {
    final MockNavigatorObserver mockNavigatorObserver = MockNavigatorObserver();
    final multiSelect = MultiSelect(
      dataSource: dataSource,
      textField: 'display',
      valueField: 'value',
    );
    var app = getBasicMultiSelectApp(multiSelect, mockNavigatorObserver, new GlobalKey<FormState>());
    await tester.pumpWidget(app);
    Finder multiSelectFinder = find.byType(MultiSelect);
    await tester.tap(multiSelectFinder);
    await tester.pumpAndSettle();
    Finder selectionModalFinder = find.byType(SelectionModal);
    Finder selectionOptionsFinder = find.descendant(
        of: selectionModalFinder, matching: find.byType(ListTile));
    await tester.tap(selectionOptionsFinder.first);
    await tester.pump();
    Finder optionsThatExistFinder = find.byType(Chip);
    expect(optionsThatExistFinder, findsOneWidget);
    Finder selectedOptionTextFinder = find.descendant(
        of: optionsThatExistFinder, matching: find.byType(Text));
    var selectedOptionText =
        selectedOptionTextFinder.evaluate().single.widget as Text;
    expect(dataSource.first[multiSelect.textField], selectedOptionText.data);
  });

  testWidgets('Selection has matching initialValuea passed in',
      (WidgetTester tester) async {
    final MockNavigatorObserver mockNavigatorObserver = MockNavigatorObserver();
    final indcesToUseForInitalValues = [1, 3];
    final initialMemebers  = List<Map<String, dynamic>>();
    final formKey = new GlobalKey<FormState>();
    for (var item in indcesToUseForInitalValues) {
      initialMemebers.add(dataSource.elementAt(item));
    }
    final List<dynamic> initialValues = initialMemebers.map((d) => d['value']).toList();
    final List<dynamic> initialDisplayNames = initialMemebers.map((d) => d['display']).toList();
    final multiSelect = MultiSelect(
      dataSource: dataSource,
      textField: 'display',
      valueField: 'value',
      initialValue: initialValues,
    );
    var app = getBasicMultiSelectApp(multiSelect, mockNavigatorObserver, formKey);
    await tester.pumpWidget(app);
    Finder multiSelectFinder = find.byType(MultiSelect);
    await tester.tap(multiSelectFinder);
    await tester.pumpAndSettle();
    Finder selectionModalFinder = find.byType(SelectionModal);
    Finder checkedOptionsFinder = find.descendant(
        of: selectionModalFinder, matching: find.byIcon(Icons.check_box));
    expect(checkedOptionsFinder, findsNWidgets(initialValues.length));
    Finder optionsThatExistFinder = find.byType(Chip);
    expect(optionsThatExistFinder, findsNWidgets(initialValues.length));
    Finder selectedOptionsTextFinder = find.descendant(
        of: optionsThatExistFinder, matching: find.byType(Text));
    var selectedOptionsText =
        selectedOptionsTextFinder.evaluate().map((e) => (e.widget as Text).data).toList();
    expect(selectedOptionsText.every((t) => initialDisplayNames.contains(t)), isTrue);
  });
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MyAppToTest extends StatelessWidget {
  final MultiSelect _multiSelect;
  final GlobalKey<FormState> _formKey;
  MyAppToTest(this._multiSelect, this._formKey,);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Something'),
      ),
      body: Center(
        child: new Form(key: _formKey, autovalidate: true, child: _multiSelect),
      ),
    );
  }
}
