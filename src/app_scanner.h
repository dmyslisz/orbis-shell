#pragma once

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QStringList>

class AppScanner : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList installedApps READ installedApps NOTIFY appsScanned)
    Q_PROPERTY(bool isScanning READ isScanning NOTIFY scanningChanged)

public:
    explicit AppScanner(QObject *parent = nullptr);
    ~AppScanner() override = default;

    QVariantList installedApps() const { return m_installedApps; }
    bool isScanning() const { return m_isScanning; }

    Q_INVOKABLE void scanApplications();
    Q_INVOKABLE QString resolveIconPath(const QString &iconName);

signals:
    void appsScanned();
    void scanningChanged();

private:
    void parseDesktopFile(const QString &filePath);

    QVariantList m_installedApps;
    bool m_isScanning = false;
    QStringList m_iconSearchPaths;
};
