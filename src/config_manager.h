#pragma once

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QJsonObject>
#include <QFileSystemWatcher>

class AppScanner;
class SteamScanner;

class ConfigManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList apps READ apps NOTIFY appsChanged)
    Q_PROPERTY(QVariantList users READ users NOTIFY usersChanged)
    Q_PROPERTY(QVariantList trophies READ trophies NOTIFY trophiesChanged)
    Q_PROPERTY(QJsonObject tunables READ tunables NOTIFY tunablesChanged)
    Q_PROPERTY(QString activeUser READ activeUser WRITE setActiveUser NOTIFY activeUserChanged)

public:
    explicit ConfigManager(const QString &configDir = QString(), QObject *parent = nullptr);
    ~ConfigManager() override = default;

    QVariantList apps() const { return m_apps; }
    QVariantList users() const { return m_users; }
    QVariantList trophies() const { return m_trophies; }
    QJsonObject tunables() const { return m_tunables; }
    QString activeUser() const { return m_activeUser; }
    void setActiveUser(const QString &userName);

    void setScanners(AppScanner *appScanner, SteamScanner *steamScanner);

    Q_INVOKABLE void saveUser(const QVariantMap &user);
    Q_INVOKABLE void deleteUser(const QString &userId);
    Q_INVOKABLE void unlockTrophy(const QString &trophyId);
    Q_INVOKABLE void refreshCatalog();

signals:
    void appsChanged();
    void usersChanged();
    void trophiesChanged();
    void tunablesChanged();
    void activeUserChanged();
    void trophyUnlocked(const QVariantMap &trophy);

private slots:
    void onConfigFileChanged(const QString &path);
    void onAppsScanned();
    void onSteamGamesScanned();

private:
    void loadApps();
    void loadUsers();
    void loadTrophies();
    void loadTunables();
    void mergeScannedItems();

    QString m_configDir;
    QFileSystemWatcher *m_watcher = nullptr;

    QVariantList m_baseApps;
    QVariantList m_apps;
    QVariantList m_users;
    QVariantList m_trophies;
    QJsonObject m_tunables;
    QString m_activeUser;

    AppScanner *m_appScanner = nullptr;
    SteamScanner *m_steamScanner = nullptr;
};
