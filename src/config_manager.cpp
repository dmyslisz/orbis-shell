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
#include <QRegularExpression>
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

bool ConfigManager::isAppOnHomeScreen(const QString &appId) const
{
    if (appId.isEmpty()) return false;
    for (const QVariant &v : m_baseApps) {
        QVariantMap m = v.toMap();
        if (m.value("id").toString() == appId || m.value("name").toString() == appId) {
            return true;
        }
    }
    return false;
}

void ConfigManager::addAppToHomeScreen(const QVariantMap &app)
{
    QString id = app.value("id").toString();
    if (id.isEmpty()) {
        id = app.value("name").toString().toLower();
        id.replace(QRegularExpression("[^a-z0-9]"), "_");
    }

    // Check if already in m_baseApps
    for (int i = 0; i < m_baseApps.size(); ++i) {
        QVariantMap m = m_baseApps[i].toMap();
        if (m.value("id").toString() == id || m.value("name").toString() == app.value("name").toString()) {
            return; // Already present
        }
    }

    QVariantMap newApp = app;
    newApp["id"] = id;
    if (!newApp.contains("isSystem")) {
        newApp["isSystem"] = false;
    }
    if (!newApp.contains("gradientStart") || newApp["gradientStart"].toString().isEmpty()) {
        newApp["gradientStart"] = "#0052D4";
        newApp["gradientEnd"] = "#102a6b";
    }
    if (!newApp.contains("context")) {
        QVariantMap ctx;
        ctx["headline"] = newApp["name"].toString();
        ctx["description"] = newApp.value("comment", "Application installed on Fedora Linux.").toString();
        ctx["playtime"] = "Application";
        ctx["patchNotes"] = "Installed Application";
        ctx["badge"] = "APP";
        newApp["context"] = ctx;
    }

    // Insert before "library" tile if library exists, otherwise at the end
    int insertIdx = m_baseApps.size();
    for (int i = 0; i < m_baseApps.size(); ++i) {
        if (m_baseApps[i].toMap().value("id").toString() == "library") {
            insertIdx = i;
            break;
        }
    }
    m_baseApps.insert(insertIdx, newApp);
    mergeScannedItems();

    // Persist to apps.json
    QString path = m_configDir + "/apps.json";
    QFile file(path);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QJsonArray arr;
        for (const auto &a : m_baseApps) {
            arr.append(QJsonObject::fromVariantMap(a.toMap()));
        }
        file.write(QJsonDocument(arr).toJson(QJsonDocument::Indented));
        file.close();
    }
}

void ConfigManager::removeAppFromHomeScreen(const QString &appId)
{
    if (appId.isEmpty() || appId == "library" || appId == "whats_new") return; // Protect core tiles
    for (int i = 0; i < m_baseApps.size(); ++i) {
        QVariantMap m = m_baseApps[i].toMap();
        if (m.value("id").toString() == appId || m.value("name").toString() == appId) {
            m_baseApps.removeAt(i);
            break;
        }
    }
    mergeScannedItems();

    QString path = m_configDir + "/apps.json";
    QFile file(path);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QJsonArray arr;
        for (const auto &a : m_baseApps) {
            arr.append(QJsonObject::fromVariantMap(a.toMap()));
        }
        file.write(QJsonDocument(arr).toJson(QJsonDocument::Indented));
        file.close();
    }
}

