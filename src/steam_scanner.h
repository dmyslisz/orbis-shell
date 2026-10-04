#pragma once

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QStringList>

class SteamScanner : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList steamGames READ steamGames NOTIFY gamesScanned)
    Q_PROPERTY(bool hasSteam READ hasSteam NOTIFY steamStatusChanged)

public:
    explicit SteamScanner(QObject *parent = nullptr);
    ~SteamScanner() override = default;

    QVariantList steamGames() const { return m_steamGames; }
    bool hasSteam() const { return m_hasSteam; }

    Q_INVOKABLE void scanSteamLibrary();

signals:
    void gamesScanned();
    void steamStatusChanged();

private:
    void findSteamLibraries();
    void parseLibraryFolder(const QString &libraryPath);
    void parseManifest(const QString &manifestPath, const QString &libraryPath);
    QString findGameCover(const QString &appId);

    QVariantList m_steamGames;
    QStringList m_libraryPaths;
    QString m_steamRoot;
    bool m_hasSteam = false;
};
