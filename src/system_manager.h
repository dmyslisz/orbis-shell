#pragma once

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QTimer>

class SystemManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int batteryPercent READ batteryPercent NOTIFY batteryChanged)
    Q_PROPERTY(bool isCharging READ isCharging NOTIFY batteryChanged)
    Q_PROPERTY(bool hasBattery READ hasBattery NOTIFY batteryChanged)
    Q_PROPERTY(int systemVolume READ systemVolume WRITE setSystemVolume NOTIFY systemVolumeChanged)
    Q_PROPERTY(bool isMuted READ isMuted WRITE setIsMuted NOTIFY systemVolumeChanged)
    Q_PROPERTY(bool isOnline READ isOnline NOTIFY networkChanged)
    Q_PROPERTY(QString networkType READ networkType NOTIFY networkChanged)

public:
    explicit SystemManager(QObject *parent = nullptr);
    ~SystemManager() override = default;

    int batteryPercent() const { return m_batteryPercent; }
    bool isCharging() const { return m_isCharging; }
    bool hasBattery() const { return m_hasBattery; }

    int systemVolume() const { return m_systemVolume; }
    void setSystemVolume(int vol);

    bool isMuted() const { return m_isMuted; }
    void setIsMuted(bool muted);

    bool isOnline() const { return m_isOnline; }
    QString networkType() const { return m_networkType; }

    // System Information
    Q_INVOKABLE QVariantMap getSystemInfo();

    // Power Actions
    Q_INVOKABLE void enterRestMode(); // Suspend
    Q_INVOKABLE void turnOff();       // PowerOff
    Q_INVOKABLE void restart();       // Reboot
    Q_INVOKABLE void logOut();        // Terminate session

signals:
    void batteryChanged();
    void systemVolumeChanged();
    void networkChanged();
    void powerActionRequested(const QString &action);

private slots:
    void refreshSystemStatus();

private:
    void readBattery();
    void readNetwork();
    void readVolume();

    int m_batteryPercent = 100;
    bool m_isCharging = false;
    bool m_hasBattery = true;

    int m_systemVolume = 80;
    bool m_isMuted = false;

    bool m_isOnline = true;
    QString m_networkType = "Wi-Fi";

    QTimer m_pollTimer;
};
