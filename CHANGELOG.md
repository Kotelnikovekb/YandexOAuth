## 0.0.3

* Added `YandexButton` Flutter widget for Yandex ID sign-in.
* Added named constructors: `YandexButton.main`, `YandexButton.additional`, `YandexButton.iconBg`, and `YandexButton.iconOnly`.
* Added button types: `main`, `additional`, `icon`, and `iconBg`.
* Added icon types: `ya` and `yaEng`.
* Added light and dark button theme support with automatic app theme detection.
* Added configurable button sizes, icon shapes, custom colors, and optional avatar for `additional` buttons.
* Added widget tests for the new button variants.
* Added Yandex SDK initialization guard in the example app to prevent login before SDK activation completes.
* Expanded error documentation with plugin error codes and Yandex iOS SDK error codes.
* Split documentation into English `README.md` and Russian `README_RU.md`.

## 0.0.2

* downgrade flutter version

## 0.0.1

* Initial release.
* Native authorization via Yandex ID (Android/iOS).
* SDK initialization, Login, Logout methods.
* Support for obtaining certificate fingerprint (Android).
* Documentation in English and Russian.
