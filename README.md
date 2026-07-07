# Mijoz App (Flutter)

Taksi/xizmatlar ilovasining mijozlar tomoni — Flutter (Dart) asosida.

## Fayllar tuzilishi

```
lib/main.dart                 - ilova kirish nuqtasi, pastki tablar
lib/screens/home_screen.dart  - bosh sahifa
lib/screens/services_screen.dart - "Barcha xizmatlar" sahifasi
lib/widgets/service_item.dart - bitta xizmat kartochkasi
lib/widgets/banner_card.dart  - banner kartochkasi
lib/data/services.dart        - barcha xizmatlar ro'yxati (shu yerga qo'shib boring)
assets/                       - banner rasmlari
.github/workflows/build-apk.yml - GitHub Actions: har push'da avtomatik APK yig'adi
```

## APK qanday olinadi

Bu repo GitHub Actions bilan sozlangan — kod push qilinganda avtomatik ravishda
APK yig'iladi. Buning uchun kompyuter yoki Flutter SDK kerak emas.

1. Repository'dagi **Actions** bo'limiga o'ting
2. **Build APK** workflow tugashini kuting (~10-15 daqiqa)
3. Workflow sahifasi pastida **Artifacts** bo'limidan `mijoz-app-apk` ni yuklab oling
4. Zip'ni oching, ichidagi `.apk` faylni telefoningizga o'rnating

## Yangi xizmat qo'shish

`lib/data/services.dart` faylidagi `kServices` ro'yxatiga yangi `ServiceInfo` qatorini
qo'shsangiz bo'ldi — u avtomatik ravishda ekranlarda chiqadi.
