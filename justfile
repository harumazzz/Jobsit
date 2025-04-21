set shell := ["powershell.exe", "-c"]

build:
    dart run build_runner build --delete-conflicting-outputs
generate:
    flutter gen-l10n
run:
    flutter run
build-android:
    flutter build apk
download:
    flutter pub get
analyze:
    flutter analyze
format:
    flutter format .
clean:
    flutter clean
backend:
    java -jar "C:\Users\Admin\Documents\GitHub\jobsit\backend\jobsit.jar"
fix:
    dart fix --apply