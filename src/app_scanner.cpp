#include "app_scanner.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QStandardPaths>
#include <QDebug>

AppScanner::AppScanner(QObject *parent)
    : QObject(parent)
{
    // Common icon theme directories on Linux
    m_iconSearchPaths << "/usr/share/pixmaps"
                      << "/usr/share/icons/hicolor/256x256/apps"
                      << "/usr/share/icons/hicolor/128x128/apps"
                      << "/usr/share/icons/hicolor/scalable/apps"
                      << "/usr/share/icons/hicolor/48x48/apps"
                      << QDir::homePath() + "/.local/share/icons/hicolor/256x256/apps"
                      << QDir::homePath() + "/.local/share/icons/hicolor/scalable/apps";

    scanApplications();
}

void AppScanner::scanApplications()
{
    m_isScanning = true;
    emit scanningChanged();
    m_installedApps.clear();

    QStringList appDirs;
    appDirs << "/usr/share/applications"
            << "/usr/local/share/applications"
            << QDir::homePath() + "/.local/share/applications"
            << "/var/lib/flatpak/exports/share/applications"
            << QDir::homePath() + "/.local/share/flatpak/exports/share/applications";

    QStringList seenExecs;

    for (const QString &dirPath : appDirs) {
        QDir dir(dirPath);
        if (!dir.exists()) continue;

        QStringList entries = dir.entryList({"*.desktop"}, QDir::Files);
        for (const QString &file : entries) {
            parseDesktopFile(dir.filePath(file));
        }
    }

    m_isScanning = false;
    emit scanningChanged();
    emit appsScanned();
    qInfo() << "[AppScanner] Total installed apps scanned:" << m_installedApps.size();
}

void AppScanner::parseDesktopFile(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return;

    QTextStream in(&file);
    bool inDesktopEntry = false;
    QString name, exec, icon, comment, categories;
    bool noDisplay = false;
    bool isTerminal = false;

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line == "[Desktop Entry]") {
            inDesktopEntry = true;
            continue;
        } else if (line.startsWith("[") && inDesktopEntry) {
            break; // Finished [Desktop Entry] section
        }

        if (!inDesktopEntry || line.startsWith("#")) continue;

        if (line.startsWith("Name=") && name.isEmpty()) {
            name = line.mid(5).trimmed();
        } else if (line.startsWith("Exec=") && exec.isEmpty()) {
            exec = line.mid(5).trimmed();
        } else if (line.startsWith("Icon=") && icon.isEmpty()) {
            icon = line.mid(5).trimmed();
        } else if (line.startsWith("Comment=") && comment.isEmpty()) {
            comment = line.mid(8).trimmed();
        } else if (line.startsWith("Categories=") && categories.isEmpty()) {
            categories = line.mid(11).trimmed();
        } else if (line.startsWith("NoDisplay=")) {
            noDisplay = (line.mid(10).trimmed().toLower() == "true");
        } else if (line.startsWith("Terminal=")) {
            isTerminal = (line.mid(9).trimmed().toLower() == "true");
        }
    }
    file.close();

    if (noDisplay || name.isEmpty() || exec.isEmpty()) return;

    // Clean up Exec argument specifiers (%f, %u, etc.)
    QString cleanExec = exec;
    cleanExec.remove(QRegularExpression("%[a-zA-Z]")).trimmed();

    // Map to category
    QString category = "Applications";
    if (categories.contains("Game", Qt::CaseInsensitive)) {
        category = "Games";
    } else if (categories.contains("Audio", Qt::CaseInsensitive) || categories.contains("Video", Qt::CaseInsensitive)) {
        category = "Media";
    } else if (categories.contains("System", Qt::CaseInsensitive) || categories.contains("Settings", Qt::CaseInsensitive)) {
        category = "System";
    }

    // Resolve icon
    QString resolvedIcon = resolveIconPath(icon);
    if (resolvedIcon.isEmpty()) {
        if (category == "Games") resolvedIcon = "qrc:/assets/icons/gamepad.svg";
        else if (category == "Media") resolvedIcon = "qrc:/assets/icons/media.svg";
        else if (category == "System") resolvedIcon = "qrc:/assets/icons/settings.svg";
        else resolvedIcon = "qrc:/assets/icons/browser.svg";
    }

    QVariantMap app;
    app["id"] = QFileInfo(filePath).baseName();
    app["name"] = name;
    app["exec"] = cleanExec;
    app["icon"] = resolvedIcon;
    app["comment"] = comment.isEmpty() ? name : comment;
    app["category"] = category;
    app["isTerminal"] = isTerminal;
    app["isSteam"] = false;

    m_installedApps.append(app);
}

QString AppScanner::resolveIconPath(const QString &iconName)
{
    if (iconName.isEmpty()) return QString();

    if (QFile::exists(iconName)) {
        return QUrl::fromLocalFile(iconName).toString();
    }

    for (const QString &dir : m_iconSearchPaths) {
        QStringList candidates = {
            QString("%1/%2.svg").arg(dir, iconName),
            QString("%1/%2.png").arg(dir, iconName),
            QString("%1/%2").arg(dir, iconName)
        };
        for (const QString &c : candidates) {
            if (QFile::exists(c)) {
                return QUrl::fromLocalFile(c).toString();
            }
        }
    }

    return QString();
}
