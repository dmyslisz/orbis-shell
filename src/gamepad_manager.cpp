#include "gamepad_manager.h"
#include <QDebug>
#include <cmath>

GamepadManager::GamepadManager(QObject *parent)
    : QObject(parent)
{
    m_repeatTimer.setSingleShot(true);
    connect(&m_repeatTimer, &QTimer::timeout, this, &GamepadManager::onRepeatTimer);

    m_guideHoldTimer.setSingleShot(true);
    m_guideHoldTimer.setInterval(450); // 450ms hold to open Quick Menu
    connect(&m_guideHoldTimer, &QTimer::timeout, this, &GamepadManager::onGuideHoldTimeout);

#ifdef HAVE_SDL3
    if (SDL_InitSubSystem(SDL_INIT_GAMEPAD)) {
        qInfo() << "[GamepadManager] SDL3 Gamepad subsystem initialized successfully.";
        connect(&m_pollTimer, &QTimer::timeout, this, &GamepadManager::pollSdlEvents);
        m_pollTimer.start(8); // 120Hz polling
    } else {
        qWarning() << "[GamepadManager] SDL_InitSubSystem(SDL_INIT_GAMEPAD) failed:" << SDL_GetError();
    }
#endif
}

GamepadManager::~GamepadManager()
{
#ifdef HAVE_SDL3
    if (m_gamepad) {
        SDL_CloseGamepad(m_gamepad);
        m_gamepad = nullptr;
    }
    SDL_QuitSubSystem(SDL_INIT_GAMEPAD);
#endif
}

void GamepadManager::updateTunables(const QJsonObject &navTunables)
{
    if (navTunables.contains("keyRepeatInitialDelayMs")) {
        m_initialDelayMs = navTunables["keyRepeatInitialDelayMs"].toInt(250);
    }
    if (navTunables.contains("keyRepeatMinIntervalMs")) {
        m_minIntervalMs = navTunables["keyRepeatMinIntervalMs"].toInt(70);
    }
    if (navTunables.contains("keyRepeatAcceleration")) {
        m_accelerationFactor = navTunables["keyRepeatAcceleration"].toDouble(0.85);
    }
}

void GamepadManager::triggerDirection(Direction dir)
{
    emit navigate(dir);
    switch (dir) {
    case Left:  emit navigateLeft(); break;
    case Right: emit navigateRight(); break;
    case Up:    emit navigateUp(); break;
    case Down:  emit navigateDown(); break;
    default:    break;
    }
}

void GamepadManager::startRepeat(Direction dir)
{
    m_activeDirection = dir;
    m_currentIntervalMs = m_initialDelayMs;
    triggerDirection(dir);
    m_repeatTimer.start(m_currentIntervalMs);
}

void GamepadManager::stopRepeat()
{
    m_activeDirection = None;
    m_repeatTimer.stop();
}

void GamepadManager::onRepeatTimer()
{
    if (m_activeDirection == None) return;

    triggerDirection(m_activeDirection);

    m_currentIntervalMs = static_cast<int>(m_currentIntervalMs * m_accelerationFactor);
    if (m_currentIntervalMs < m_minIntervalMs) {
        m_currentIntervalMs = m_minIntervalMs;
    }

    m_repeatTimer.start(m_currentIntervalMs);
}

void GamepadManager::onGuideHoldTimeout()
{
    m_guideHeldTriggered = true;
    qInfo() << "[GamepadManager] PS Button Held: Opening Quick Menu";
    emit quickMenuRequested();
}

void GamepadManager::handleNavigationPress(Direction dir)
{
    if (m_activeDirection != dir) {
        startRepeat(dir);
    }
}

void GamepadManager::handleNavigationRelease(Direction dir)
{
    if (m_activeDirection == dir) {
        stopRepeat();
    }
}

#ifdef HAVE_SDL3
void GamepadManager::pollSdlEvents()
{
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
        switch (event.type) {
        case SDL_EVENT_GAMEPAD_ADDED: {
            if (!m_gamepad) {
                m_gamepad = SDL_OpenGamepad(event.gdevice.which);
                if (m_gamepad) {
                    m_gamepadId = event.gdevice.which;
                    m_gamepadConnected = true;
                    m_gamepadName = QString::fromUtf8(SDL_GetGamepadName(m_gamepad));
                    qInfo() << "[GamepadManager] Gamepad connected:" << m_gamepadName;
                    emit gamepadConnectedChanged();
                    emit gamepadNameChanged();
                }
            }
            break;
        }

        case SDL_EVENT_GAMEPAD_REMOVED: {
            if (m_gamepad && event.gdevice.which == m_gamepadId) {
                SDL_CloseGamepad(m_gamepad);
                m_gamepad = nullptr;
                m_gamepadId = 0;
                m_gamepadConnected = false;
                m_gamepadName.clear();
                stopRepeat();
                qInfo() << "[GamepadManager] Gamepad disconnected.";
                emit gamepadConnectedChanged();
                emit gamepadNameChanged();
            }
            break;
        }

        case SDL_EVENT_GAMEPAD_BUTTON_DOWN: {
            switch (event.gbutton.button) {
            case SDL_GAMEPAD_BUTTON_DPAD_LEFT:
                m_dpadDirection = Left;
                handleNavigationPress(Left);
                break;
            case SDL_GAMEPAD_BUTTON_DPAD_RIGHT:
                m_dpadDirection = Right;
                handleNavigationPress(Right);
                break;
            case SDL_GAMEPAD_BUTTON_DPAD_UP:
                m_dpadDirection = Up;
                handleNavigationPress(Up);
                break;
            case SDL_GAMEPAD_BUTTON_DPAD_DOWN:
                m_dpadDirection = Down;
                handleNavigationPress(Down);
                break;
            case SDL_GAMEPAD_BUTTON_SOUTH:
                emit confirmPressed();
                break;
            case SDL_GAMEPAD_BUTTON_EAST:
                emit backPressed();
                break;
            case SDL_GAMEPAD_BUTTON_WEST:
                emit squarePressed();
                break;
            case SDL_GAMEPAD_BUTTON_NORTH:
                emit trianglePressed();
                break;
            case SDL_GAMEPAD_BUTTON_START:
                emit optionsPressed();
                break;
            case SDL_GAMEPAD_BUTTON_LEFT_SHOULDER:
                emit shoulderLeftPressed();
                break;
            case SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER:
                emit shoulderRightPressed();
                break;
            case SDL_GAMEPAD_BUTTON_GUIDE:
                m_guideHeldTriggered = false;
                m_guideHoldTimer.start();
                break;
            }
            break;
        }

        case SDL_EVENT_GAMEPAD_BUTTON_UP: {
            switch (event.gbutton.button) {
            case SDL_GAMEPAD_BUTTON_DPAD_LEFT:
                if (m_dpadDirection == Left) {
                    m_dpadDirection = None;
                    handleNavigationRelease(Left);
                }
                break;
            case SDL_GAMEPAD_BUTTON_DPAD_RIGHT:
                if (m_dpadDirection == Right) {
                    m_dpadDirection = None;
                    handleNavigationRelease(Right);
                }
                break;
            case SDL_GAMEPAD_BUTTON_DPAD_UP:
                if (m_dpadDirection == Up) {
                    m_dpadDirection = None;
                    handleNavigationRelease(Up);
                }
                break;
            case SDL_GAMEPAD_BUTTON_DPAD_DOWN:
                if (m_dpadDirection == Down) {
                    m_dpadDirection = None;
                    handleNavigationRelease(Down);
                }
                break;
            case SDL_GAMEPAD_BUTTON_GUIDE:
                m_guideHoldTimer.stop();
                if (!m_guideHeldTriggered) {
                    emit homePressed();
                }
                m_guideHeldTriggered = false;
                break;
            }
            break;
        }

        case SDL_EVENT_GAMEPAD_AXIS_MOTION: {
            if (event.gaxis.axis == SDL_GAMEPAD_AXIS_LEFTX || event.gaxis.axis == SDL_GAMEPAD_AXIS_LEFTY) {
                Sint16 rawX = SDL_GetGamepadAxis(m_gamepad, SDL_GAMEPAD_AXIS_LEFTX);
                Sint16 rawY = SDL_GetGamepadAxis(m_gamepad, SDL_GAMEPAD_AXIS_LEFTY);

                float normX = rawX / 32767.0f;
                float normY = rawY / 32767.0f;

                Direction newDir = None;
                if (std::abs(normX) > std::abs(normY)) {
                    if (normX < -m_stickThreshold) newDir = Left;
                    else if (normX > m_stickThreshold) newDir = Right;
                } else {
                    if (normY < -m_stickThreshold) newDir = Up;
                    else if (normY > m_stickThreshold) newDir = Down;
                }

                if (newDir != m_stickDirection) {
                    if (m_stickDirection != None) {
                        handleNavigationRelease(m_stickDirection);
                    }
                    m_stickDirection = newDir;
                    if (m_stickDirection != None) {
                        handleNavigationPress(m_stickDirection);
                    }
                }
            }
            break;
        }
        }
    }
}
#else
void GamepadManager::pollSdlEvents() {}
#endif
