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

public:
    explicit ProcessLauncher(QObject *parent = nullptr);
    ~ProcessLauncher() override;

    bool isAppRunning() const { return m_isRunning; }
    QString currentAppName() const { return m_currentAppName; }

    void setMainWindow(QQuickWindow *window) { m_mainWindow = window; }

    Q_INVOKABLE bool launch(const QString &appName, const QString &commandLine);
    Q_INVOKABLE void requestHome();
    Q_INVOKABLE void lowerToApp();
    Q_INVOKABLE void terminateCurrentApp();

signals:
    void isAppRunningChanged();
    void currentAppNameChanged();
    void appLaunched(const QString &name);
    void appExited(const QString &name, int exitCode);

private slots:
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    QProcess *m_activeProcess = nullptr;
    bool m_isRunning = false;
    QString m_currentAppName;
    QQuickWindow *m_mainWindow = nullptr;
};
