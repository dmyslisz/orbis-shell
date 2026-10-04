#include "steam_scanner.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QUrl>
#include <QDebug>
#include <QRegularExpression>

SteamScanner::SteamScanner(QObject *parent)
    : QObject(parent)
{
    scanSteamLibrary();
}

void SteamScanner::scanSteamLibrary()
{
    m_steamGames.clear();
    m_libraryPaths.clear();
    m_hasSteam = false;

    findSteamLibraries();

    for (const QString &lib : m_libraryPaths) {
        parseLibraryFolder(lib);
    }

    emit steamStatusChanged();
    emit gamesScanned();
    qInfo() << "[SteamScanner] Found" << m_steamGames.size() << "installed Steam games across" << m_libraryPaths.size() << "libraries.";
}

void SteamScanner::findSteamLibraries()
{
    QStringList candidates = {
        QDir::homePath() + "/.steam/steam",
        QDir::homePath() + "/.local/share/Steam",
        QDir::homePath() + "/.var/app/com.valvesoftware.Steam/.steam/steam"
    };

    for (const QString &cand : candidates) {
        if (QDir(cand).exists()) {
            m_steamRoot = cand;
            m_hasSteam = true;
            m_libraryPaths.append(cand);
            break;
        }
    }

    if (!m_hasSteam) return;

    // Parse libraryfolders.vdf
    QString vdfPath = m_steamRoot + "/steamapps/libraryfolders.vdf";
    QFile vdfFile(vdfPath);
    if (vdfFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&vdfFile);
        static QRegularExpression pathRegex("\"path\"\\s+\"([^\"]+)\"");
        while (!in.atEnd()) {
            QString line = in.readLine();
            auto match = pathRegex.match(line);
            if (match.hasMatch()) {
                QString path = match.captured(1);
                if (!m_libraryPaths.contains(path) && QDir(path).exists()) {
                    m_libraryPaths.append(path);
                }
            }
        }
        vdfFile.close();
    }
}

void SteamScanner::parseLibraryFolder(const QString &libraryPath)
{
    QDir steamapps(libraryPath + "/steamapps");
    if (!steamapps.exists()) return;

    QStringList manifests = steamapps.entryList({"appmanifest_*.acf"}, QDir::Files);
    for (const QString &m : manifests) {
        parseManifest(steamapps.filePath(m), libraryPath);
    }
}

void SteamScanner::parseManifest(const QString &manifestPath, const QString &libraryPath)
{
    Q_UNUSED(libraryPath);
    QFile file(manifestPath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return;

    QTextStream in(&file);
    QString appId, name, installdir;

    static QRegularExpression appidRegex("\"appid\"\\s+\"([^\"]+)\"");
    static QRegularExpression nameRegex("\"name\"\\s+\"([^\"]+)\"");
    static QRegularExpression installRegex("\"installdir\"\\s+\"([^\"]+)\"");

    while (!in.atEnd()) {
        QString line = in.readLine();
        auto mApp = appidRegex.match(line);
        if (mApp.hasMatch() && appId.isEmpty()) appId = mApp.captured(1);

        auto mName = nameRegex.match(line);
        if (mName.hasMatch() && name.isEmpty()) name = mName.captured(1);

        auto mDir = installRegex.match(line);
        if (mDir.hasMatch() && installdir.isEmpty()) installdir = mDir.captured(1);
    }
    file.close();

    // Skip Steamworks common redistributables or Proton runtimes from main game list
    if (appId.isEmpty() || name.isEmpty()) return;
    if (name.contains("Proton", Qt::CaseInsensitive) ||
        name.contains("Steam Linux Runtime", Qt::CaseInsensitive) ||
        name.contains("Steamworks Shared", Qt::CaseInsensitive)) {
        return;
    }

    QVariantMap game;
    game["id"] = "steam_" + appId;
    game["appId"] = appId;
    game["name"] = name;
    game["exec"] = QString("steam steam://rungameid/%1").arg(appId);
    game["category"] = "Games";
    game["isSteam"] = true;
    game["comment"] = QString("Steam Title (AppID %1)").arg(appId);

    QString cover = findGameCover(appId);
    game["icon"] = cover.isEmpty() ? "qrc:/assets/covers/steam.svg" : cover;

    m_steamGames.append(game);
}

QString SteamScanner::findGameCover(const QString &appId)
{
    if (m_steamRoot.isEmpty()) return QString();

    // Check userdata grid folder
    QDir userDir(m_steamRoot + "/userdata");
    if (userDir.exists()) {
        QStringList userIds = userDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
        for (const QString &uid : userIds) {
            QString gridPath = QString("%1/userdata/%2/config/grid/%3p.png").arg(m_steamRoot, uid, appId);
            if (QFile::exists(gridPath)) {
                return QUrl::fromLocalFile(gridPath).toString();
            }
            gridPath = QString("%1/userdata/%2/config/grid/%3.png").arg(m_steamRoot, uid, appId);
            if (QFile::exists(gridPath)) {
                return QUrl::fromLocalFile(gridPath).toString();
            }
        }
    }

    // Check appcache
    QString appCacheCover = QString("%1/appcache/appimages/%2/header.jpg").arg(m_steamRoot, appId);
    if (QFile::exists(appCacheCover)) {
        return QUrl::fromLocalFile(appCacheCover).toString();
    }

    return QString();
}
