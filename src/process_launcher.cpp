#include "process_launcher.h"
#include <QDebug>
#include <QProcessEnvironment>

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

bool ProcessLauncher::launch(const QString &appName, const QString &commandLine)
{
    if (commandLine.trimmed().isEmpty()) {
        qWarning() << "[ProcessLauncher] No exec command provided for" << appName;
        return false;
    }

    qInfo() << "[ProcessLauncher] Launching application:" << appName << "cmd:" << commandLine;

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

    m_activeProcess->startCommand(commandLine.trimmed());

    if (!m_activeProcess->waitForStarted(2000)) {
        qWarning() << "[ProcessLauncher] Failed to start:" << commandLine << m_activeProcess->errorString();
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
        m_mainWindow->showFullScreen();
        m_mainWindow->raise();
        m_mainWindow->requestActivate();
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
