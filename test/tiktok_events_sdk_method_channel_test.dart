import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiktok_events_sdk/src/bridge/tiktok_events_sdk_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelTiktokEventsSdk plugin;
  late List<MethodCall> log;

  setUp(() {
    plugin = MethodChannelTiktokEventsSdk();
    log = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(plugin.methodChannel,
            (MethodCall call) async {
      log.add(call);
      return 'TikTok SDK initialized!';
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(plugin.methodChannel, null);
  });

  group('initSdk', () {
    test('passes a single TikTok App ID through unchanged', () async {
      await plugin.initSdk(
        androidAppId: 'com.app.id',
        tikTokAndroidId: ['1234567890111213141'],
        iosAppId: '1234567890',
        tiktokIosId: ['1234567890111213141'],
      );

      expect(log, hasLength(1));
      expect(log.first.method, 'initialize');
      expect(log.first.arguments['tiktokId'], '1234567890111213141');
    });

    test('joins multiple TikTok App IDs with commas', () async {
      await plugin.initSdk(
        androidAppId: 'com.app.id',
        tikTokAndroidId: ['111', '222', '333'],
        iosAppId: '1234567890',
        tiktokIosId: ['999'],
      );

      expect(log.first.arguments['tiktokId'], '111,222,333');
    });

    test('trims surrounding whitespace from each ID', () async {
      await plugin.initSdk(
        androidAppId: 'com.app.id',
        tikTokAndroidId: ['  111  ', '\t222\n', '333'],
        iosAppId: '1234567890',
        tiktokIosId: ['999'],
      );

      expect(log.first.arguments['tiktokId'], '111,222,333');
    });

    test('drops empty and whitespace-only entries', () async {
      await plugin.initSdk(
        androidAppId: 'com.app.id',
        tikTokAndroidId: ['111', '', '   ', '222'],
        iosAppId: '1234567890',
        tiktokIosId: ['999'],
      );

      expect(log.first.arguments['tiktokId'], '111,222');
    });

    test('throws ArgumentError when the list is empty', () async {
      await expectLater(
        plugin.initSdk(
          androidAppId: 'com.app.id',
          tikTokAndroidId: <String>[],
          iosAppId: '1234567890',
          tiktokIosId: ['999'],
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(log, isEmpty);
    });

    test('throws ArgumentError when every entry is empty or whitespace',
        () async {
      await expectLater(
        plugin.initSdk(
          androidAppId: 'com.app.id',
          tikTokAndroidId: ['', '   ', '\t'],
          iosAppId: '1234567890',
          tiktokIosId: ['999'],
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(log, isEmpty);
    });
  });
}
