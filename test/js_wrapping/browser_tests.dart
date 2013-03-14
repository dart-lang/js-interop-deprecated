library tests;

import 'dart:html';
import 'dart:json';

import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as jsw;
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';

abstract class _Person {
  String firstname;

  String sayHello();
}
class PersonMP extends jsw.MagicProxy implements _Person {
  PersonMP(String firstname,  String lastname) :
      super(js.context.Person, [firstname, lastname]);
  PersonMP.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);
}

class PersonTP extends jsw.TypedProxy {
  PersonTP(String firstname,  String lastname) :
      super(js.context.Person, [firstname, lastname]);
  PersonTP.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);

  set firstname(String firstname) => $unsafe.firstname = firstname;
  String get firstname => $unsafe.firstname;

  String sayHello() => $unsafe.sayHello();
}

class Color implements js.Serializable<String> {
  static final RED = new Color._("red");
  static final BLUE = new Color._("blue");

  final String _value;

  Color._(this._value);

  String toJs() => this._value;
  operator ==(Color other) => this._value == other._value;
}

main() {
  useHtmlConfiguration();

  test('TypedProxy', () {
    js.scoped(() {
      final john = new PersonTP('John', 'Doe');
      expect(john.firstname, equals('John'));
      john.firstname = 'Joe';
      expect(john.firstname, equals('Joe'));
    });
  });

  test('MagicProxy', () {
    js.scoped(() {
      final john = new PersonMP('John', 'Doe');
      expect(john.firstname, equals('John'));
      expect(john['firstname'], equals('John'));
      john.firstname = 'Joe';
      expect(john.firstname, equals('Joe'));
      expect(john['firstname'], equals('Joe'));
      john['firstname'] = 'John';
      expect(john.firstname, equals('John'));
      expect(john['firstname'], equals('John'));
    });
  });

  test('function call', () {
    js.scoped(() {
      final john = new PersonTP('John', 'Doe');
      expect(john.sayHello(), equals("Hello, I'm John Doe"));
    });
  });

  test('JsDateToDateTimeAdapter', () {
    js.scoped(() {
      final date = new DateTime.now();
      final jsDate = new jsw.JsDateToDateTimeAdapter(date);
      expect(jsDate.millisecondsSinceEpoch,
          equals(date.millisecondsSinceEpoch));
      jsDate.$unsafe.setFullYear(2000);
      expect(jsDate.year, equals(2000));
    });
  });

  group('JsArrayToListAdapter', () {
    test('iterator', () {
      js.scoped(() {
        final m = new jsw.JsArrayToListAdapter<String>.fromProxy(
            js.array(["e0", "e1", "e2"]));

        final iterator = m.iterator;
        iterator.moveNext();
        expect(iterator.current, equals("e0"));
        iterator.moveNext();
        expect(iterator.current, equals("e1"));
        iterator.moveNext();
        expect(iterator.current, equals("e2"));
      });
    });
    test('get length', () {
      js.scoped(() {
        final m1 = new jsw.JsArrayToListAdapter<String>.fromProxy(js.array([]));
        expect(m1.length, equals(0));
        final m2 = new jsw.JsArrayToListAdapter<String>.fromProxy(
            js.array(["a", "b"]));
        expect(m2.length, equals(2));
      });
    });
    test('add', () {
      js.scoped(() {
        final m = new jsw.JsArrayToListAdapter<String>.fromProxy(js.array([]));
        expect(m.length, equals(0));
        m.add("a");
        expect(m.length, equals(1));
        expect(m[0], equals("a"));
        m.add("b");
        expect(m.length, equals(2));
        expect(m[0], equals("a"));
        expect(m[1], equals("b"));
      });
    });
    test('clear', () {
      js.scoped(() {
        final m = new jsw.JsArrayToListAdapter<String>.fromProxy(
            js.array(["a", "b"]));
        expect(m.length, equals(2));
        m.clear();
        expect(m.length, equals(0));
      });
    });
    test('remove', () {
      js.scoped(() {
        final m = new jsw.JsArrayToListAdapter<String>.fromProxy(
            js.array(["a", "b"]));
        expect(m.length, equals(2));
        m.remove("a");
        expect(m.length, equals(1));
        expect(m[0], equals("b"));
      });
    });
    test('operator []', () {
      js.scoped(() {
        final m = new jsw.JsArrayToListAdapter<String>.fromProxy(
            js.array(["a", "b"]));
        expect(() => m[-1], throwsA(isRangeError));
        expect(() => m[2], throwsA(isRangeError));
        expect(m[0], equals("a"));
        expect(m[1], equals("b"));
      });
    });
    test('operator []=', () {
      js.scoped(() {
        final m = new jsw.JsArrayToListAdapter<String>.fromProxy(
            js.array(["a", "b"]));
        expect(() => m[-1] = "c", throwsA(isRangeError));
        expect(() => m[2] = "c", throwsA(isRangeError));
        m[0] = "d";
        m[1] = "e";
        expect(m[0], equals("d"));
        expect(m[1], equals("e"));
      });
    });
    test('set length', () {
      js.scoped(() {
        final m = new jsw.JsArrayToListAdapter<String>.fromProxy(
            js.array(["a", "b"]));
        m.length = 10;
        expect(m.length, equals(10));
        expect(m[5], equals(null));
        m.length = 1;
        expect(m.length, equals(1));
        expect(m[0], equals("a"));
      });
    });
    test('sort', () {
      js.scoped(() {
        final m = new jsw.JsArrayToListAdapter<String>.fromProxy(
            js.array(["c", "a", "b"]));
        m.sort();
        expect(m.length, equals(3));
        expect(m[0], equals("a"));
        expect(m[1], equals("b"));
        expect(m[2], equals("c"));
      });
    });
    test('removeAt', () {
      js.scoped(() {
        final m = new jsw.JsArrayToListAdapter<String>.fromProxy(
            js.array(["a", "b", "c"]));
        expect(m.removeAt(1), equals("b"));
        expect(m.length, equals(2));
        expect(m[0], equals("a"));
        expect(m[1], equals("c"));
        expect(() => m.removeAt(2), throwsA(isRangeError));
      });
    });
    test('removeLast', () {
      js.scoped(() {
        final m = new jsw.JsArrayToListAdapter<String>.fromProxy(
            js.array(["a", "b", "c", null]));
        expect(m.removeLast(), isNull);
        expect(m.removeLast(), equals("c"));
        expect(m.removeLast(), equals("b"));
        expect(m.removeLast(), equals("a"));
        expect(m.length, equals(0));
      });
    });
    test('getRange', () {
      js.scoped(() {
        final m = new jsw.JsArrayToListAdapter<String>.fromProxy(
            js.array(["a", "b", "c", null]));
        final r1 = m.getRange(1, 2);
        expect(r1.length, equals(2));
        expect(r1[0], equals("b"));
        expect(r1[1], equals("c"));
        final r2 = m.getRange(1, 0);
        expect(r2.length, equals(0));
        final r3 = m.getRange(3, 1);
        expect(r3.length, equals(1));
        expect(r3[0], isNull);
      });
    });
    test('setRange', () {
      js.scoped(() {
        final m = new jsw.JsArrayToListAdapter<String>.fromProxy(
            js.array(["a", "b", "c", null]));
        m.setRange(1, 2, [null, null]);
        expect(m.length, equals(4));
        expect(m[0], equals("a"));
        expect(m[1], isNull);
        expect(m[2], isNull);
        expect(m[3], isNull);
        m.setRange(3, 1, [null, "c", null], 1);
        expect(m[0], equals("a"));
        expect(m[1], isNull);
        expect(m[2], isNull);
        expect(m[3], equals("c"));
      });
    });
    test('removeRange', () {
      js.scoped(() {
        final m = new jsw.JsArrayToListAdapter<String>.fromProxy(
            js.array(["a", "b", "c", null]));
        m.removeRange(1, 2);
        expect(m.length, equals(2));
        expect(m[0], equals("a"));
        expect(m[1], isNull);
      });
    });
    test('insertRange', () {
      js.scoped(() {
        final m = new jsw.JsArrayToListAdapter<String>.fromProxy(
            js.array(["a", null]));
        m.insertRange(1, 2, "b");
        expect(m.length, equals(4));
        expect(m[0], equals("a"));
        expect(m[1], equals("b"));
        expect(m[2], equals("b"));
        expect(m[3], isNull);
      });
    });

    test('bidirectionnal serialization of Proxy', () {
      js.scoped(() {
        js.context.myArray = js.array([]);
        final myList = new jsw.JsArrayToListAdapter<PersonTP>.fromProxy(
            js.context.myArray, new jsw.TranslatorForProxy<PersonTP>((p) =>
                new PersonTP.fromProxy(p)));

        myList.add(new PersonTP('John', 'Doe'));
        myList.add(null);
        expect(myList[0].firstname, 'John');
        expect(myList[1], isNull);
      });
    });

    test('bidirectionnal serialization of Serializable', () {
      js.scoped(() {
        js.context.myArray = js.array([]);
        final myList = new jsw.JsArrayToListAdapter<Color>.fromProxy(
            js.context.myArray,
            new jsw.Translator<Color>(
                (e) => e != null ? new Color._(e) : null,
                (e) => e != null ? e.toJs() : null
            )
        );

        myList.add(Color.BLUE);
        myList.add(null);
        expect(myList[0], Color.BLUE);
        expect(myList[1], isNull);
      });
    });
  });

  test('retain/release', () {
    PersonTP john;
    js.scoped(() {
      john = new PersonTP('John', 'Doe');
    });
    js.scoped((){
      expect(() => john.sayHello(), throws);
    });
    js.scoped(() {
      john = new PersonTP('John', 'Doe');
      js.retain(john);
    });
    js.scoped((){
      expect(() => john.sayHello(), returnsNormally);
      js.release(john);
    });
    js.scoped((){
      expect(() => john.sayHello(), throws);
    });
  });
}
