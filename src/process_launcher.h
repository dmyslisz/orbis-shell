#pragma once

#include <QObject>
#include <QProcess>
#include <QString>
#include <QQuickWindow>

class ProcessLauncher : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isAppRunning READ isAppRunning NOTIFY isAppRunningChanged)
    Q_PROPERTY(QString currentAppName READ currentAppName NOTIFY currentAppNameChanged)
    Q_PROPERTY(bool hasGamescope READ hasGamescope NOTIFY gamescopeStatusChanged)
    Q_PROPERTY(bool useGamescope READ useGamescope WRITE setUseGamescope NOTIFY useGamescopeChanged)

public:
    explicit ProcessLauncher(QObject *parent = nullptr);
    ~ProcessLauncher() override;

    bool isAppRunning() const { return m_isRunning; }
    QString currentAppName() const { return m_currentAppName; }
    bool hasGamescope() const;
    bool useGamescope() const { return m_useGamescope; }
    void setUseGamescope(bool use);

    void setMainWindow(QQuickWindow *window) { m_mainWindow = window; }
    void updateTunables(const QJsonObject &systemTunables);

    Q_INVOKABLE bool launch(const QString &appName, const QString &commandLine);
    Q_INVOKABLE void requestHome();
    Q_INVOKABLE void lowerToApp();
    Q_INVOKABLE void terminateCurrentApp();

signals:
    void isAppRunningChanged();
    void currentAppNameChanged();
    void gamescopeStatusChanged();
    void useGamescopeChanged();
    void appLaunched(const QString &name);
    void appExited(const QString &name, int exitCode);

private slots:
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    bool startProcess(const QString &appName, const QString &cmd, bool isGamescope);

    QProcess *m_activeProcess = nullptr;
    bool m_isRunning = false;
    bool m_useGamescope = true;
    bool m_wasLaunchedWithGamescope = false;
    qint64 m_launchTimeMs = 0;
    QString m_lastAppName;
    QString m_lastRawCmd;
    QString m_currentAppName;
    QQuickWindow *m_mainWindow = nullptr;
};
