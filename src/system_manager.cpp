#include "system_manager.h"
#include <QProcess>
#include <QFile>
#include <QDir>
#include <QTextStream>
#include <QDebug>
#include <QSysInfo>
#include <QStorageInfo>

#ifndef Q_OS_WIN
#include <sys/utsname.h>
#endif

SystemManager::SystemManager(QObject *parent)
    : QObject(parent)
{
    refreshSystemStatus();

    // Poll battery & network status every 5 seconds
    connect(&m_pollTimer, &QTimer::timeout, this, &SystemManager::refreshSystemStatus);
    m_pollTimer.start(5000);
}

void SystemManager::setSystemVolume(int vol)
{
    vol = qBound(0, vol, 100);
    if (m_systemVolume != vol) {
        m_systemVolume = vol;
        emit systemVolumeChanged();

#ifndef Q_OS_WIN
        QString percent = QString("%1%").arg(vol);
        float normalized = vol / 100.0f;
        // PipeWire wpctl
        QProcess::startDetached("wpctl", {"set-volume", "@DEFAULT_AUDIO_SINK@", percent});
        QProcess::startDetached("wpctl", {"set-volume", "@DEFAULT_AUDIO_SINK@", QString::number(normalized, 'f', 2)});
        // PulseAudio / PipeWire-Pulse fallback
        QProcess::startDetached("pactl", {"set-sink-volume", "@DEFAULT_SINK@", percent});
        // ALSA fallback
        QProcess::startDetached("amixer", {"-q", "set", "Master", percent});
#endif
    }
}

void SystemManager::setIsMuted(bool muted)
{
    if (m_isMuted != muted) {
        m_isMuted = muted;
        emit systemVolumeChanged();

#ifndef Q_OS_WIN
        QProcess::startDetached("wpctl", {"set-mute", "@DEFAULT_AUDIO_SINK@", muted ? "1" : "0"});
        QProcess::startDetached("pactl", {"set-sink-mute", "@DEFAULT_SINK@", muted ? "1" : "0"});
        QProcess::startDetached("amixer", {"-q", "set", "Master", muted ? "mute" : "unmute"});
#endif
    }
}

void SystemManager::refreshSystemStatus()
{
    readBattery();
    readNetwork();
    readVolume();
}

void SystemManager::readBattery()
{
#ifndef Q_OS_WIN
    QDir psDir("/sys/class/power_supply");
    if (psDir.exists()) {
        QStringList entries = psDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
        for (const QString &entry : entries) {
            if (entry.startsWith("BAT") || entry.contains("battery", Qt::CaseInsensitive)) {
                QFile capFile(psDir.filePath(entry + "/capacity"));
                if (capFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
                    m_batteryPercent = capFile.readAll().trimmed().toInt();
                    m_hasBattery = true;
                    capFile.close();
                }

                QFile statFile(psDir.filePath(entry + "/status"));
                if (statFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
                    QString status = QString::fromUtf8(statFile.readAll()).trimmed();
                    m_isCharging = (status == "Charging" || status == "Full");
                    statFile.close();
                }

                emit batteryChanged();
                return;
            }
        }
    }
#endif
}

void SystemManager::readNetwork()
{
#ifndef Q_OS_WIN
    QDir netDir("/sys/class/net");
    if (netDir.exists()) {
        QStringList ifaces = netDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
        bool online = false;
        QString type = "Offline";

        for (const QString &iface : ifaces) {
            if (iface == "lo") continue;
            QFile operState(netDir.filePath(iface + "/operstate"));
            if (operState.open(QIODevice::ReadOnly | QIODevice::Text)) {
                QString state = QString::fromUtf8(operState.readAll()).trimmed();
                operState.close();
                if (state == "up") {
                    online = true;
                    if (iface.startsWith("wl")) {
                        type = "Wi-Fi";
                    } else if (iface.startsWith("en") || iface.startsWith("eth")) {
                        type = "Ethernet";
                    } else {
                        type = "Connected";
                    }
                    break;
                }
            }
        }

        if (m_isOnline != online || m_networkType != type) {
            m_isOnline = online;
            m_networkType = type;
            emit networkChanged();
        }
    }
#endif
}

void SystemManager::readVolume()
{
#ifndef Q_OS_WIN
    QProcess proc;
    proc.start("wpctl", {"get-volume", "@DEFAULT_AUDIO_SINK@"});
    if (proc.waitForFinished(500)) {
        QString out = QString::fromUtf8(proc.readAllStandardOutput()).trimmed();
        // Format: "Volume: 0.65" or "Volume: 0.65 [MUTED]"
        if (out.startsWith("Volume:")) {
            QStringList parts = out.split(' ', Qt::SkipEmptyParts);
            if (parts.size() >= 2) {
                float vol = parts[1].toFloat();
                m_systemVolume = qBound(0, static_cast<int>(vol * 100), 100);
            }
            m_isMuted = out.contains("[MUTED]");
            emit systemVolumeChanged();
        }
    }
#endif
}

QVariantMap SystemManager::getSystemInfo()
{
    QVariantMap info;

    info["os"] = "Fedora Linux 44 (Orbis Edition)";
    info["kernel"] = QSysInfo::kernelVersion();
    info["arch"] = QSysInfo::currentCpuArchitecture();

#ifndef Q_OS_WIN
    struct utsname u;
    if (uname(&u) == 0) {
        info["kernel"] = QString("%1 %2").arg(u.sysname, u.release);
    }

    // CPU info
    QFile cpuinfo("/proc/cpuinfo");
    if (cpuinfo.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&cpuinfo);
        while (!in.atEnd()) {
            QString line = in.readLine();
            if (line.startsWith("model name")) {
                info["cpu"] = line.section(':', 1).trimmed();
                break;
            }
        }
        cpuinfo.close();
    }

    // RAM info
    QFile meminfo("/proc/meminfo");
    if (meminfo.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&meminfo);
        qint64 totalKb = 0;
        qint64 availKb = 0;
        while (!in.atEnd()) {
            QString line = in.readLine();
            if (line.startsWith("MemTotal:")) totalKb = line.split(' ', Qt::SkipEmptyParts).value(1).toLongLong();
            if (line.startsWith("MemAvailable:")) availKb = line.split(' ', Qt::SkipEmptyParts).value(1).toLongLong();
        }
        meminfo.close();

        if (totalKb > 0) {
            double totalGb = totalKb / (1024.0 * 1024.0);
            double usedGb = (totalKb - availKb) / (1024.0 * 1024.0);
            info["ramTotal"] = QString::asprintf("%.1f GB", totalGb);
            info["ramUsed"] = QString::asprintf("%.1f GB", usedGb);
        }
    }
#else
    info["cpu"] = "AMD x86_64 Processor";
    info["ramTotal"] = "16.0 GB";
    info["ramUsed"] = "4.2 GB";
#endif

    // Storage info
    QStorageInfo storage = QStorageInfo::root();
    if (storage.isValid() && storage.isReady()) {
        double totalGb = storage.bytesTotal() / (1024.0 * 1024.0 * 1024.0);
        double freeGb = storage.bytesAvailable() / (1024.0 * 1024.0 * 1024.0);
        info["storageTotal"] = QString::asprintf("%.1f GB", totalGb);
        info["storageFree"] = QString::asprintf("%.1f GB", freeGb);
    }

    return info;
}

void SystemManager::enterRestMode()
{
    qInfo() << "[SystemManager] Rest Mode (Suspend) requested.";
    emit powerActionRequested("suspend");
#ifndef Q_OS_WIN
    QProcess::startDetached("systemctl", {"suspend"});
#endif
}

void SystemManager::turnOff()
{
    qInfo() << "[SystemManager] Turn Off (PowerOff) requested.";
    emit powerActionRequested("poweroff");
#ifndef Q_OS_WIN
    QProcess::startDetached("systemctl", {"poweroff"});
#endif
}

void SystemManager::restart()
{
    qInfo() << "[SystemManager] Restart (Reboot) requested.";
    emit powerActionRequested("reboot");
#ifndef Q_OS_WIN
    QProcess::startDetached("systemctl", {"reboot"});
#endif
}

void SystemManager::logOut()
{
    qInfo() << "[SystemManager] Log Out requested.";
    emit powerActionRequested("logout");
#ifndef Q_OS_WIN
    QProcess::startDetached("loginctl", {"terminate-session", "self"});
#endif
}
