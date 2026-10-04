#pragma once

#include <QObject>
#include <QTimer>
#include <QElapsedTimer>
#include <QJsonObject>

#ifdef HAVE_SDL3
#include <SDL3/SDL.h>
#endif

class GamepadManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool gamepadConnected READ gamepadConnected NOTIFY gamepadConnectedChanged)
    Q_PROPERTY(QString gamepadName READ gamepadName NOTIFY gamepadNameChanged)

public:
    enum Direction {
        None = 0,
        Left,
        Right,
        Up,
        Down
    };
    Q_ENUM(Direction)

    explicit GamepadManager(QObject *parent = nullptr);
    ~GamepadManager() override;

    bool gamepadConnected() const { return m_gamepadConnected; }
    QString gamepadName() const { return m_gamepadName; }

    void updateTunables(const QJsonObject &navTunables);

    // Call from QML on key press / release so keyboard shares identical repeat acceleration
    Q_INVOKABLE void handleNavigationPress(Direction dir);
    Q_INVOKABLE void handleNavigationRelease(Direction dir);

signals:
    void gamepadConnectedChanged();
    void gamepadNameChanged();

    void navigate(Direction dir);
    void navigateLeft();
    void navigateRight();
    void navigateUp();
    void navigateDown();

    void confirmPressed();       // Cross / A
    void backPressed();          // Circle / B
    void squarePressed();        // Square / X
    void trianglePressed();      // Triangle / Y (Search)
    void optionsPressed();       // Options / Start
    void homePressed();          // Guide (Tap -> Home)
    void quickMenuRequested();   // Guide (Hold -> Quick Menu)
    void shoulderLeftPressed();  // L1
    void shoulderRightPressed(); // R1

private slots:
    void pollSdlEvents();
    void onRepeatTimer();
    void onGuideHoldTimeout();

private:
    void triggerDirection(Direction dir);
    void startRepeat(Direction dir);
    void stopRepeat();

    bool m_gamepadConnected = false;
    QString m_gamepadName;

    // Repeat parameters
    int m_initialDelayMs = 250;
    int m_minIntervalMs = 70;
    double m_accelerationFactor = 0.85;
    float m_stickThreshold = 0.50f;
    float m_stickDeadzone = 0.20f;

    Direction m_activeDirection = None;
    QTimer m_repeatTimer;
    int m_currentIntervalMs = 250;

    QTimer m_pollTimer;

    // Guide button hold tracking
    QTimer m_guideHoldTimer;
    bool m_guideHeldTriggered = false;

#ifdef HAVE_SDL3
    SDL_Gamepad *m_gamepad = nullptr;
    SDL_JoystickID m_gamepadId = 0;
    Direction m_stickDirection = None;
    Direction m_dpadDirection = None;
#endif
};
