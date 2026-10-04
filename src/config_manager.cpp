#include "config_manager.h"
#include "app_scanner.h"
#include "steam_scanner.h"
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDateTime>
#include <QDebug>

ConfigManager::ConfigManager(const QString &configDir, QObject *parent)
    : QObject(parent)
{
    if (!configDir.isEmpty() && QDir(configDir).exists()) {
        m_configDir = configDir;
    } else {
        QString appDir = QCoreApplication::applicationDirPath();
        if (QDir(appDir + "/config").exists()) {
            m_configDir = appDir + "/config";
        } else if (QDir(appDir + "/../config").exists()) {
            m_configDir = appDir + "/../config";
        } else if (QDir("config").exists()) {
            m_configDir = "config";
        } else {
            m_configDir = ":/config";
        }
    }

    qInfo() << "[ConfigManager] Configuration directory:" << m_configDir;

    m_watcher = new QFileSystemWatcher(this);
    connect(m_watcher, &QFileSystemWatcher::fileChanged, this, &ConfigManager::onConfigFileChanged);

    loadTunables();
    loadApps();
    loadUsers();
    loadTrophies();
}

void ConfigManager::setScanners(AppScanner *appScanner, SteamScanner *steamScanner)
{
    m_appScanner = appScanner;
    m_steamScanner = steamScanner;

    if (m_appScanner) {
        connect(m_appScanner, &AppScanner::appsScanned, this, &ConfigManager::onAppsScanned);
    }
    if (m_steamScanner) {
        connect(m_steamScanner, &SteamScanner::gamesScanned, this, &ConfigManager::onSteamGamesScanned);
    }
    mergeScannedItems();
}

void ConfigManager::setActiveUser(const QString &userName)
{
    if (m_activeUser != userName) {
        m_activeUser = userName;
        emit activeUserChanged();
    }
}

void ConfigManager::refreshCatalog()
{
    if (m_appScanner) m_appScanner->scanApplications();
    if (m_steamScanner) m_steamScanner->scanSteamLibrary();
    mergeScannedItems();
}

void ConfigManager::onAppsScanned()
{
    mergeScannedItems();
}

void ConfigManager::onSteamGamesScanned()
{
    mergeScannedItems();
}

void ConfigManager::mergeScannedItems()
{
    m_apps = m_baseApps;

    // Insert Steam games before the Library tile
    if (m_steamScanner) {
        QVariantList steamGames = m_steamScanner->steamGames();
        int insertPos = qMax(0, m_apps.size() - 1); // Before Library tile
        for (const QVariant &g : steamGames) {
            QVariantMap gm = g.toMap();
            gm["gradientStart"] = "#1b2838";
            gm["gradientEnd"] = "#0d1217";
            QVariantMap ctx;
            ctx["headline"] = gm["name"].toString();
            ctx["description"] = "Installed Steam Game. Ready to launch with full controller support.";
            ctx["playtime"] = "Steam Game";
            ctx["patchNotes"] = "Steam Play (Proton / Native)";
            ctx["badge"] = "STEAM";
            gm["context"] = ctx;
            m_apps.insert(insertPos++, gm);
        }
    }

    emit appsChanged();
}

void ConfigManager::loadApps()
{
    QString path = m_configDir + "/apps.json";
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        path = ":/config/apps.json";
        file.setFileName(path);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (doc.isArray()) {
        m_baseApps.clear();
        QJsonArray arr = doc.array();
        for (const auto &v : arr) {
            m_baseApps.append(v.toObject().toVariantMap());
        }
        mergeScannedItems();
    }

    if (!path.startsWith(":") && QFile::exists(path)) {
        m_watcher->addPath(path);
    }
}

void ConfigManager::loadUsers()
{
    QString path = m_configDir + "/users.json";
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        path = ":/config/users.json";
        file.setFileName(path);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (doc.isArray()) {
        m_users.clear();
        QJsonArray arr = doc.array();
        for (const auto &v : arr) {
            QVariantMap userMap = v.toObject().toVariantMap();
            m_users.append(userMap);
            if (userMap.value("isCurrent", false).toBool() && m_activeUser.isEmpty()) {
                m_activeUser = userMap.value("name").toString();
                emit activeUserChanged();
            }
        }
        emit usersChanged();
    }

    if (!path.startsWith(":") && QFile::exists(path)) {
        m_watcher->addPath(path);
    }
}

void ConfigManager::loadTrophies()
{
    QString path = m_configDir + "/trophies.json";
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        path = ":/config/trophies.json";
        file.setFileName(path);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (doc.isArray()) {
        m_trophies.clear();
        QJsonArray arr = doc.array();
        for (const auto &v : arr) {
            m_trophies.append(v.toObject().toVariantMap());
        }
        emit trophiesChanged();
    }

    if (!path.startsWith(":") && QFile::exists(path)) {
        m_watcher->addPath(path);
    }
}

void ConfigManager::loadTunables()
{
    QString path = m_configDir + "/tunables.json";
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        path = ":/config/tunables.json";
        file.setFileName(path);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (doc.isObject()) {
        m_tunables = doc.object();
        emit tunablesChanged();
    }

    if (!path.startsWith(":") && QFile::exists(path)) {
        m_watcher->addPath(path);
    }
}

void ConfigManager::onConfigFileChanged(const QString &path)
{
    qInfo() << "[ConfigManager] Configuration file changed:" << path;
    if (path.endsWith("tunables.json")) {
        loadTunables();
    } else if (path.endsWith("apps.json")) {
        loadApps();
    } else if (path.endsWith("users.json")) {
        loadUsers();
    } else if (path.endsWith("trophies.json")) {
        loadTrophies();
    }

    // Re-add path to watcher if removed by atomic save
    if (QFile::exists(path) && !m_watcher->files().contains(path)) {
        m_watcher->addPath(path);
    }
}

void ConfigManager::saveUser(const QVariantMap &user)
{
    bool found = false;
    for (int i = 0; i < m_users.size(); ++i) {
        QVariantMap u = m_users[i].toMap();
        if (u["id"] == user["id"]) {
            m_users[i] = user;
            found = true;
            break;
        }
    }
    if (!found) {
        m_users.append(user);
    }
    emit usersChanged();

    // Persist to users.json
    QString path = m_configDir + "/users.json";
    QFile file(path);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QJsonArray arr;
        for (const auto &u : m_users) {
            arr.append(QJsonObject::fromVariantMap(u.toMap()));
        }
        file.write(QJsonDocument(arr).toJson(QJsonDocument::Indented));
        file.close();
    }
}

void ConfigManager::deleteUser(const QString &userId)
{
    for (int i = 0; i < m_users.size(); ++i) {
        if (m_users[i].toMap()["id"] == userId) {
            m_users.removeAt(i);
            break;
        }
    }
    emit usersChanged();
}

void ConfigManager::unlockTrophy(const QString &trophyId)
{
    for (int i = 0; i < m_trophies.size(); ++i) {
        QVariantMap t = m_trophies[i].toMap();
        if (t["id"] == trophyId && !t.value("unlocked", false).toBool()) {
            t["unlocked"] = true;
            t["unlockedDate"] = QDateTime::currentDateTime().toString("MM/dd/yyyy hh:mm");
            m_trophies[i] = t;
            emit trophiesChanged();
            emit trophyUnlocked(t);
            break;
        }
    }
}
