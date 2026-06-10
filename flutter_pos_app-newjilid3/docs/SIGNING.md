# Release Signing — POS Cafe

Production builds uploaded to Google Play Console must be signed with a
release keystore. The keystore itself **never** lives in this repo — each
release-capable machine generates or imports its own copy.

The Gradle config (`android/app/build.gradle`) reads keystore details from
`android/key.properties`. That file (and any `*.jks` / `*.keystore`) is
gitignored. If `key.properties` is missing on a dev machine, release builds
fall back to debug signing so `flutter run --release` keeps working — but
those APKs **cannot** be uploaded to Play.

## 1. Generate the keystore (one-time, on the release machine)

```bash
# Adjust -dname to match the legal entity that owns the app on Play Console.
keytool -genkey -v \
  -keystore android/keystore/poscafe-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias poscafe \
  -dname "CN=POS Cafe, O=JagoFullstack, L=Jakarta, C=ID"
```

You will be prompted for two passwords:

1. The **store** password (encrypts the file itself).
2. The **key** password (encrypts the single key entry inside; can be the
   same as the store password, often is).

**Back up the .jks file + both passwords in your password manager.** If
the keystore is lost, you cannot ship updates under the same signing
identity — Google Play will refuse the upload, and the only path forward is
re-publishing under a new package name with a fresh keystore. Treat this
file like a production database backup.

> If you opt in to **Play App Signing** in the Play Console (recommended),
> Google holds the production signing key for you and you only need to
> keep this _upload_ key safe. Lost upload keys can be reset via the Play
> Console — lost full signing keys cannot.

## 2. Create `android/key.properties`

```properties
storeFile=../keystore/poscafe-release.jks
storePassword=<the store password from step 1>
keyAlias=poscafe
keyPassword=<the key password from step 1>
```

Path is relative to `android/app/` (where `build.gradle` lives). If you put
the keystore somewhere else, update `storeFile` accordingly — absolute
paths also work.

`android/key.properties.example` is committed as a template; copy it:

```bash
cp android/key.properties.example android/key.properties
# edit android/key.properties with real values
```

## 3. Build a signed release

```bash
# AAB for Play Console upload (preferred):
flutter build appbundle --release \
  --dart-define=BASE_URL=https://poscafe.jagofullstack.com

# APK for sideload / testing:
flutter build apk --release \
  --dart-define=BASE_URL=https://poscafe.jagofullstack.com
```

Output locations:

- AAB: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-release.apk`

## 4. Verify the build is correctly signed

```bash
# Should show your release key (CN=POS Cafe, O=JagoFullstack, ...)
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
```

If you see `CN=Android Debug, O=Android, C=US`, the build fell back to
debug signing — check that `android/key.properties` exists and that the
paths/passwords inside it are correct, then rebuild.

## 5. First upload to Play Console

1. Create app in [Play Console](https://play.google.com/console).
2. Set **app name** = "POS Cafe", **default language** = Bahasa Indonesia.
3. Under **Setup → App signing**: enable **Play App Signing**, then upload
   this AAB as your **upload key**. Google will generate the actual
   production signing key on their side.
4. Under **App content**, fill out:
   - **Privacy Policy URL**: `https://poscafe.jagofullstack.com/api/privacy`
   - **App access**: provide a demo login for the review team.
   - **Ads**: No.
   - **Content rating**: complete the IARC questionnaire (expect "Everyone").
   - **Target audience**: 18+ (POS for business owners).
   - **Data safety**: see the data declarations in `docs/PLAY_LISTING.md`.
   - **Government apps**: No.
   - **News**: No.
5. Upload AAB under **Production → Create release**, attach release notes
   in Bahasa Indonesia, and submit for review.

## 6. Subsequent updates

Every update must bump `pubspec.yaml`'s version:

```yaml
version: 1.0.1+2   # 1.0.1 is versionName (semver); 2 is versionCode (monotonic int)
```

`versionCode` must always increase. `versionName` follows semver.

## 7. CI / multi-machine workflow

If you build releases from CI:

1. Store the keystore as a base64-encoded secret (e.g. GitHub Actions
   `KEYSTORE_BASE64`).
2. Store all passwords as separate secrets.
3. Decode the keystore + write `android/key.properties` from secrets in a
   pre-build step. Never echo the passwords to logs.

Sample GitHub Actions step:

```yaml
- name: Decode keystore
  run: |
    echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/keystore/poscafe-release.jks
    cat > android/key.properties <<EOF
    storeFile=../keystore/poscafe-release.jks
    storePassword=${{ secrets.KEYSTORE_PASSWORD }}
    keyAlias=poscafe
    keyPassword=${{ secrets.KEY_PASSWORD }}
    EOF
```
