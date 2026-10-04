#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QDir>
#include <QFileInfo>
#include <QDebug>

#include "config_manager.h"
#include "gamepad_manager.h"
#include "process_launcher.h"
#include "sound_controller.h"
#include "app_scanner.h"
#include "steam_scanner.h"
#include "system_manager.h"

int main(int argc, char *argv[])
{
    // Use Wayland by default on Linux if available, with X11 fallback
    if (qEnvironmentVariableIsEmpty("QT_QPA_PLATFORM")) {
        qputenv("QT_QPA_PLATFORM", "wayland;xcb");
    }

    // Set console desktop identification
    qputenv("XDG_CURRENT_DESKTOP", "Orbis");

    QGuiApplication app(argc, argv);
    app.setApplicationName("orbis-shell");
    app.setOrganizationName("OrbisOS");
    app.setApplicationVersion("1.0.0");

    qInfo() << "=======================================================";
    qInfo() << " Orbis OS Shell (Desktop Environment Session)";
    qInfo() << " Target: Fedora Linux 44 / Wayland / X11";
    qInfo() << "=======================================================";

    // Detect asset directory
    QString appDir = QGuiApplication::applicationDirPath();
    QString assetDir;
    if (QDir(appDir + "/assets").exists()) {
        assetDir = appDir + "/assets";
    } else if (QDir(appDir + "/../assets").exists()) {
        assetDir = appDir + "/../assets";
    } else if (QDir("assets").exists()) {
        assetDir = "assets";
    }

    // Detect config directory
    QString configDir;
    if (QDir(appDir + "/config").exists()) {
        configDir = appDir + "/config";
    } else if (QDir(appDir + "/../config").exists()) {
        configDir = appDir + "/../config";
    } else if (QDir("config").exists()) {
        configDir = "config";
    }

    GamepadManager gamepadManager;
    SoundController soundController(assetDir.isEmpty() ? QString() : assetDir + "/sounds");
    ProcessLauncher processLauncher;
    AppScanner appScanner;
    SteamScanner steamScanner;
    SystemManager systemManager;
    ConfigManager configManager(configDir);

    configManager.setScanners(&appScanner, &steamScanner);

    // Watch tunables and propagate
    QObject::connect(&configManager, &ConfigManager::tunablesChanged, [&]() {
        QJsonObject tunables = configManager.tunables();
        if (tunables.contains("sound")) {
            soundController.updateTunables(tunables["sound"].toObject());
        }
        if (tunables.contains("navigation")) {
            gamepadManager.updateTunables(tunables["navigation"].toObject());
        }
        if (tunables.contains("system")) {
            processLauncher.updateTunables(tunables["system"].toObject());
        }
    });

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("gamepadManager", &gamepadManager);
    engine.rootContext()->setContextProperty("soundController", &soundController);
    engine.rootContext()->setContextProperty("processLauncher", &processLauncher);
    engine.rootContext()->setContextProperty("appScanner", &appScanner);
    engine.rootContext()->setContextProperty("steamScanner", &steamScanner);
    engine.rootContext()->setContextProperty("systemManager", &systemManager);
    engine.rootContext()->setContextProperty("configManager", &configManager);

    const QUrl url(QStringLiteral("qrc:/qml/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url, &processLauncher](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            qCritical() << "[Main] Failed to load root QML component.";
            QCoreApplication::exit(-1);
        } else if (obj) {
            auto *window = qobject_cast<QQuickWindow*>(obj);
            if (window) {
                processLauncher.setMainWindow(window);
            }
        }
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
