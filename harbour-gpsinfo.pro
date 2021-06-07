TARGET = harbour-gpsinfo

CONFIG += sailfishapp
#CONFIG += sailfishapp_i18n

SOURCES += \
    src/gpsdatasource.cpp \
    src/qmlsettingswrapper.cpp \
    src/gpsinfosettings.cpp \
    src/app.cpp \
    src/harbour-gpsinfo.cpp

DISTFILES += qml/pages/CoverPage.qml \
    qml/components/AboutLabel.qml \
    qml/QChart/QChart.js \
    qml/QChart/QChart.qml \
    qml/QChart/qmldir \
    qml/components/MainMenu.qml \
    qml/pages/FirstPage.qml \
    qml/components/InfoField.qml \
    qml/pages/SatelliteBarchartPage.qml \
    qml/pages/SettingsPage.qml \
    qml/LocationFormatter.js \
    qml/components/Providers.qml \
    qml/components/DoubleSwitch.qml \
    qml/pages/AboutPage.qml \
    qml/pages/LicensePage.qml \
    rpm/harbour-gpsinfo.changes \
    rpm/harbour-gpsinfo.spec \
    harbour-gpsinfo.desktop \
    qml/harbour-gpsinfo.qml \
    qml/pages/SatelliteInfoPage.qml \
    images/coverbg.png \
    rpm/harbour-gpsinfo.yaml \
    translations/harbour-gpsinfo_de.ts \
    translations/harbour-gpsinfo_es.ts \
    translations/harbour-gpsinfo_fi.ts \
    translations/harbour-gpsinfo_fr.ts \
    translations/harbour-gpsinfo_hu.ts \
    translations/harbour-gpsinfo_nl.ts \
    translations/harbour-gpsinfo_pl.ts \
    translations/harbour-gpsinfo_ru.ts \
    translations/harbour-gpsinfo_sv.ts \
    translations/harbour-gpsinfo_zh_CN.ts

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172 256x256

HEADERS += \
    src/gpsdatasource.h \
    src/qmlsettingswrapper.h \
    src/gpsinfosettings.h \
    src/app.h

QT += positioning

TRANSLATIONS += \
    translations/harbour-gpsinfo_de.ts \
    translations/harbour-gpsinfo_es.ts \
    translations/harbour-gpsinfo_fi.ts \
    translations/harbour-gpsinfo_fr.ts \
    translations/harbour-gpsinfo_hu.ts \
    translations/harbour-gpsinfo_nl.ts \
    translations/harbour-gpsinfo_pl.ts \
    translations/harbour-gpsinfo_ru.ts \
    translations/harbour-gpsinfo_sv.ts \
    translations/harbour-gpsinfo_zh_CN.ts

# 1) Run lupdate from SDK menu
# 2) Run "lrelease harbour-gpsinfo.pro" from terminal (not SFDK)
# 3) Generate RPM packages for deployment
qmfiles.files = $$files(translations/*.qm)
qmfiles.path = /usr/share/$${TARGET}/translations
INSTALLS += qmfiles

images.files = \
    images/coverbg.png

images.path = /usr/share/harbour-gpsinfo/images

INSTALLS += images
