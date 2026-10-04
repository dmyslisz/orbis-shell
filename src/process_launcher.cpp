#include "process_launcher.h"
#include <QDebug>
#include <QProcessEnvironment>
#include <QStandardPaths>
#include <QJsonObject>

ProcessLauncher::ProcessLauncher(QObject *parent)
    : QObject(parent)
{
}

ProcessLauncher::~ProcessLauncher()
{
    if (m_activeProcess) {
        m_activeProcess->kill();
        m_activeProcess->deleteLater();
    }
}

bool ProcessLauncher::hasGamescope() const
{
    return !QStandardPaths::findExecutable("gamescope").isEmpty();
}

void ProcessLauncher::setUseGamescope(bool use)
{
    if (m_useGamescope != use) {
        m_useGamescope = use;
        emit useGamescopeChanged();
    }
}

void ProcessLauncher::updateTunables(const QJsonObject &systemTunables)
{
    if (systemTunables.contains("useGamescope")) {
        setUseGamescope(systemTunables["useGamescope"].toBool(true));
    }
}

bool ProcessLauncher::launch(const QString &appName, const QString &commandLine)
{
    if (commandLine.trimmed().isEmpty()) {
        qWarning() << "[ProcessLauncher] No exec command provided for" << appName;
        return false;
    }

    QString rawCmd = commandLine.trimmed();
    QString finalCmd = rawCmd;

    if (m_useGamescope && hasGamescope()) {
        qInfo() << "[ProcessLauncher] Wrapping execution in Gamescope container (1920x1080 full-screen sandbox).";
        finalCmd = QString("gamescope -W 1920 -H 1080 -f -e -- sh -c \"exec %1\"").arg(rawCmd);
    }

    qInfo() << "[ProcessLauncher] Launching application:" << appName << "cmd:" << finalCmd;

    if (m_activeProcess) {
        disconnect(m_activeProcess, nullptr, this, nullptr);
        m_activeProcess->deleteLater();
        m_activeProcess = nullptr;
    }

    m_activeProcess = new QProcess(this);
    connect(m_activeProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &ProcessLauncher::onProcessFinished);

    // Forward system environment (WAYLAND_DISPLAY, DISPLAY, XDG_RUNTIME_DIR)
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("XDG_CURRENT_DESKTOP", "Orbis");
    m_activeProcess->setProcessEnvironment(env);

    m_activeProcess->startCommand(finalCmd);

    if (!m_activeProcess->waitForStarted(2000)) {
        qWarning() << "[ProcessLauncher] Failed to start:" << finalCmd << m_activeProcess->errorString();
        m_activeProcess->deleteLater();
        m_activeProcess = nullptr;
        return false;
    }

    m_isRunning = true;
    m_currentAppName = appName;
    emit isAppRunningChanged();
    emit currentAppNameChanged();
    emit appLaunched(appName);

    return true;
}

void ProcessLauncher::terminateCurrentApp()
{
    if (m_activeProcess && m_isRunning) {
        qInfo() << "[ProcessLauncher] Terminating running app:" << m_currentAppName;
        m_activeProcess->terminate();
        if (!m_activeProcess->waitForFinished(1500)) {
            m_activeProcess->kill();
        }
    }
}

void ProcessLauncher::requestHome()
{
    qInfo() << "[ProcessLauncher] Home requested. Bringing Orbis Shell to front.";
    if (m_mainWindow) {
        m_mainWindow->setFlag(Qt::WindowStaysOnTopHint, true);
        m_mainWindow->showFullScreen();
        m_mainWindow->raise();
        m_mainWindow->requestActivate();
    }
}

void ProcessLauncher::lowerToApp()
{
    qInfo() << "[ProcessLauncher] Returning to running app:" << m_currentAppName;
    if (m_mainWindow) {
        m_mainWindow->setFlag(Qt::WindowStaysOnTopHint, false);
        m_mainWindow->lower();
    }
}

void ProcessLauncher::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    Q_UNUSED(exitStatus);
    qInfo() << "[ProcessLauncher] Active process" << m_currentAppName << "finished with code" << exitCode;
    m_isRunning = false;
    QString finishedName = m_currentAppName;
    m_currentAppName.clear();

    emit isAppRunningChanged();
    emit currentAppNameChanged();
    emit appExited(finishedName, exitCode);

    requestHome();
}
