# Password Alarm (Flutter)

This project recreates the UI/flow from your screen recording:

- Home: Current time + list of alarms + floating `+`
- New Alarm modal: time picker, optional label, alarm sound picker, required dismiss password
- Alarm ringing screen: requires password to dismiss

## Quick start (generates platform folders)

Because this repo is UI-focused, you can generate the missing platform folders by running:

```bash
cd password_alarm_flutter
bash tool/bootstrap.sh
```

This will:
1) run `flutter create .` (only if needed)
2) restore this repo's `lib/` + `pubspec.yaml`
3) patch iOS to **not require code signing** (Simulator builds, CI builds)

Then:

```bash
flutter pub get
flutter run
```

## iOS code signing: disabled
The bootstrap script patches `ios/Runner.xcodeproj/project.pbxproj` and adds a Podfile `post_install`
hook to set:
- `CODE_SIGNING_ALLOWED = NO`
- `CODE_SIGNING_REQUIRED = NO`
- `CODE_SIGN_IDENTITY = ""`

> Note: Running on a physical iPhone still requires signing.
