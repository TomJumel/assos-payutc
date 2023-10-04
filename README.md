# 💰Payutc

The payutc app for the SiMDE UTC
[AppStore](https://apps.apple.com/fi/app/payutc/id1476933437)
[PlayStore](https://play.google.com/store/apps/details?id=com.simde.payutc&hl=ln&gl=US)
## Views
![](https://is1-ssl.mzstatic.com/image/thumb/Purple123/v4/da/ff/9a/daff9ae7-a265-4d18-3d4c-9612e7eaf4a7/97534aa5-e72b-4685-988d-14cae33fb2e4_Frame_10_apple.png/157x0w.webp)
![](https://is1-ssl.mzstatic.com/image/thumb/Purple113/v4/86/37/91/863791c4-613c-8c91-5a41-9f047df67f64/187c4f5f-832e-4c59-b83d-6c323562ff90_Frame_11_apple.png/157x0w.webp)
![](https://is1-ssl.mzstatic.com/image/thumb/Purple123/v4/ee/53/e8/ee53e882-b73f-9b5c-38f5-83cc40d5d5ad/2bf935dd-87ac-406c-af25-4c906058f93c_Frame_12_apple.png/157x0w.webp)
### Add env file

Add env.dart file in `lib/src/` with content

```dart

const String nemoPayUrl = "https://api.nemopay.net/";
const String payUrlCallback = "https://assos.utc.fr/pay_app_callback";
const String nemoPayAppId = "YOUR_APP_ID";
const String casUrl = "https://cas.utc.fr/cas/";
const String nemoPayKey = "YOUR_WEEZPAY_APPKEY";
const String gingerKey = "YOUR_GINGER_APPKEY";
const String sentryDsn = "YOUR_SENTRY_DSN";
```

### Run app

```shell
flutter run
```

### Build apk

```shell
flutter build apk
```

### Build ios

```shell
flutter build ipa
```

# Tests

## Prepare tests

**The tests use [mockito](https://pub.dev/packages/mockito)**

For the unit tests, you need to build mockito before running the tests.

```shell
flutter pub run build_runner build --delete-conflicting-outputs
```

## Run tests

```shell
flutter test
```

# Translation

Translation is managed by arb files. You can find them in `lib/src/l10n/`. The used package
is [intl](https://pub.dev/packages/intl).

## Generate arb files translations
We have made a script to generate new languages files from arb file source and locale of destination.
We are using google translate to translate the source arb file.
### Environment variables for the script
```dart
const translateClient = "YOUR_GOOGLE_TRANSLATE_CLIENT";
```
### Commands
📣 Be sure you are in the root of the project
```shell
dart ./translate/translate.dart <command> <local1,local2> <source_path>
```
Type `dart ./translate/translate.dart` to see all commands examples
#### To translate the app
```shell
dart ./translate/translate.dart arb en,es,it,de lib/l10n/intl_fr.arb
```

# Contribute
Before pushing your code, please run flutter analysis commands.
```shell
flutter analyze
flutter pub run import_sorter:main
dart format .
```
# Authors

- [Tom JUMEL](https://github.com/TomJumel)
