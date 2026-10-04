#include "sound_controller.h"
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QDebug>
#include <QRandomGenerator>

SoundController::SoundController(const QString &baseAssetDir, QObject *parent)
    : QObject(parent)
{
    if (!baseAssetDir.isEmpty() && QDir(baseAssetDir).exists()) {
        m_assetsDir = baseAssetDir;
    } else {
        QString appDir = QCoreApplication::applicationDirPath();
        if (QDir(appDir + "/assets/sounds").exists()) {
            m_assetsDir = appDir + "/assets/sounds";
        } else if (QDir(appDir + "/../assets/sounds").exists()) {
            m_assetsDir = appDir + "/../assets/sounds";
        } else if (QDir("assets/sounds").exists()) {
            m_assetsDir = "assets/sounds";
        } else {
            m_assetsDir = ":/assets/sounds";
        }
    }

    qInfo() << "[SoundController] Audio assets directory:" << m_assetsDir;
    initSounds();
}

SoundController::~SoundController()
{
#ifdef HAVE_SDL3
    for (auto &s : m_sdlTickPool) freeSdlSample(s);
    freeSdlSample(m_sdlConfirm);
    freeSdlSample(m_sdlBack);
    freeSdlSample(m_sdlOptions);
    freeSdlSample(m_sdlBootChime);
    freeSdlSample(m_sdlHomeScreenMusic);
    freeSdlSample(m_sdlLogin);
    freeSdlSample(m_sdlLogout);
    freeSdlSample(m_sdlNotification);
    freeSdlSample(m_sdlTrophy);
    freeSdlSample(m_sdlKeyPress);
    freeSdlSample(m_sdlCursorMove);
    freeSdlSample(m_sdlKeyError);
    freeSdlSample(m_sdlBackspace);

    if (m_audioDevice) {
        SDL_CloseAudioDevice(m_audioDevice);
        m_audioDevice = 0;
    }
#else
    if (m_bgmPlayer) {
        m_bgmPlayer->stop();
    }
#endif
}

void SoundController::setSoundEnabled(bool enabled)
{
    if (m_enabled != enabled) {
        m_enabled = enabled;
        emit soundEnabledChanged();
        if (!m_enabled) {
            stopHomeScreenMusic();
        } else if (m_homeScreenMusicPlaying && m_bgmEnabled) {
            playHomeScreenMusic();
        }
    }
}

void SoundController::setBgmEnabled(bool enabled)
{
    if (m_bgmEnabled != enabled) {
        m_bgmEnabled = enabled;
        emit bgmEnabledChanged();
        if (!m_bgmEnabled) {
            stopHomeScreenMusic();
        } else if (m_homeScreenMusicPlaying && m_enabled) {
            playHomeScreenMusic();
        }
    }
}

void SoundController::setMasterVolume(double vol)
{
    m_masterVolume = qBound(0.0, vol, 1.0);
    emit masterVolumeChanged();
#ifndef HAVE_SDL3
    if (m_bgmAudioOutput) {
        m_bgmAudioOutput->setVolume(static_cast<float>(m_masterVolume * m_bgmVolume));
    }
#endif
}

void SoundController::setSfxVolume(double vol)
{
    m_sfxVolume = qBound(0.0, vol, 1.0);
    emit sfxVolumeChanged();
}

void SoundController::setBgmVolume(double vol)
{
    m_bgmVolume = qBound(0.0, vol, 1.0);
    emit bgmVolumeChanged();
#ifndef HAVE_SDL3
    if (m_bgmAudioOutput) {
        m_bgmAudioOutput->setVolume(static_cast<float>(m_masterVolume * m_bgmVolume));
    }
#endif
}

void SoundController::updateTunables(const QJsonObject &soundTunables)
{
    if (soundTunables.contains("masterVolume")) {
        setMasterVolume(soundTunables["masterVolume"].toDouble(0.65));
    }
    if (soundTunables.contains("sfxVolume")) {
        setSfxVolume(soundTunables["sfxVolume"].toDouble(0.70));
    }
    if (soundTunables.contains("bgmVolume")) {
        setBgmVolume(soundTunables["bgmVolume"].toDouble(0.40));
    }
    if (soundTunables.contains("bgmEnabled")) {
        setBgmEnabled(soundTunables["bgmEnabled"].toBool(true));
    }
    if (soundTunables.contains("pitchVariation")) {
        m_pitchVariation = soundTunables["pitchVariation"].toBool(true);
    }
}

#ifdef HAVE_SDL3

SoundController::SoundSample SoundController::loadSdlSample(const QString &relativeFilePath)
{
    SoundSample sample;
    QString path = QString("%1/%2").arg(m_assetsDir, relativeFilePath);
    QByteArray pathUtf8 = QFile::encodeName(QFileInfo(path).absoluteFilePath());

    if (!SDL_LoadWAV(pathUtf8.constData(), &sample.spec, &sample.data, &sample.length)) {
        qWarning() << "[SoundController] SDL_LoadWAV failed for" << relativeFilePath << ":" << SDL_GetError();
        return sample;
    }

    sample.stream = SDL_CreateAudioStream(&sample.spec, nullptr);
    if (!sample.stream) {
        qWarning() << "[SoundController] SDL_CreateAudioStream failed:" << SDL_GetError();
        return sample;
    }

    if (!SDL_BindAudioStream(m_audioDevice, sample.stream)) {
        qWarning() << "[SoundController] SDL_BindAudioStream failed:" << SDL_GetError();
    }

    return sample;
}

void SoundController::playSdlSample(SoundSample &sample, float volume, bool loop)
{
    if (!m_enabled || !m_sdlAudioReady || !sample.stream || !sample.data) return;

    SDL_SetAudioStreamGain(sample.stream, qBound(0.0f, volume, 1.0f));
    SDL_ClearAudioStream(sample.stream);
    SDL_PutAudioStreamData(sample.stream, sample.data, sample.length);
    SDL_FlushAudioStream(sample.stream);
}

void SoundController::stopSdlSample(SoundSample &sample)
{
    if (sample.stream) {
        SDL_ClearAudioStream(sample.stream);
    }
}

void SoundController::freeSdlSample(SoundSample &sample)
{
    if (sample.stream) {
        SDL_DestroyAudioStream(sample.stream);
        sample.stream = nullptr;
    }
    if (sample.data) {
        SDL_free(sample.data);
        sample.data = nullptr;
    }
    sample.length = 0;
}

void SoundController::initSounds()
{
    if (SDL_InitSubSystem(SDL_INIT_AUDIO)) {
        m_audioDevice = SDL_OpenAudioDevice(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, nullptr);
        if (m_audioDevice) {
            SDL_ResumeAudioDevice(m_audioDevice);
            m_sdlAudioReady = true;
            qInfo() << "[SoundController] SDL3 Native Audio ready on device ID" << m_audioDevice;
        } else {
            qWarning() << "[SoundController] SDL_OpenAudioDevice failed:" << SDL_GetError();
        }
    } else {
        qWarning() << "[SoundController] SDL_InitSubSystem(SDL_INIT_AUDIO) failed:" << SDL_GetError();
    }

    if (!m_sdlAudioReady) return;

    // Load tick pool
    m_sdlTickPool.append(loadSdlSample("nav_tick.wav"));

    m_sdlConfirm = loadSdlSample("confirm.wav");
    m_sdlBack = loadSdlSample("back.wav");
    m_sdlOptions = loadSdlSample("options.wav");
    m_sdlBootChime = loadSdlSample("boot_chime.wav");
    m_sdlHomeScreenMusic = loadSdlSample("home_screen_music.wav");
    m_sdlLogin = loadSdlSample("login.wav");
    m_sdlLogout = loadSdlSample("logout.wav");
    m_sdlNotification = loadSdlSample("notification.wav");
    m_sdlTrophy = loadSdlSample("trophy.wav");

    m_sdlKeyPress = loadSdlSample("keyboard/key_press.wav");
    m_sdlCursorMove = loadSdlSample("keyboard/cursor_move.wav");
    m_sdlKeyError = loadSdlSample("keyboard/key_error.wav");
    m_sdlBackspace = loadSdlSample("keyboard/backspace.wav");
}

void SoundController::playTick()
{
    if (!m_enabled || m_sdlTickPool.isEmpty()) return;
    float gain = static_cast<float>(m_masterVolume * m_sfxVolume);
    playSdlSample(m_sdlTickPool[0], gain);
}

void SoundController::playConfirm()
{
    playSdlSample(m_sdlConfirm, static_cast<float>(m_masterVolume * m_sfxVolume));
}

void SoundController::playBack()
{
    playSdlSample(m_sdlBack, static_cast<float>(m_masterVolume * m_sfxVolume));
}

void SoundController::playOptions()
{
    playSdlSample(m_sdlOptions, static_cast<float>(m_masterVolume * m_sfxVolume));
}

void SoundController::playBootChime()
{
    playSdlSample(m_sdlBootChime, static_cast<float>(m_masterVolume * 0.75f));
}

void SoundController::stopBootChime()
{
    stopSdlSample(m_sdlBootChime);
}

void SoundController::playHomeScreenMusic()
{
    m_homeScreenMusicPlaying = true;
    if (!m_enabled || !m_bgmEnabled) return;
    playSdlSample(m_sdlHomeScreenMusic, static_cast<float>(m_masterVolume * m_bgmVolume), true);
}

void SoundController::stopHomeScreenMusic()
{
    m_homeScreenMusicPlaying = false;
    stopSdlSample(m_sdlHomeScreenMusic);
}

void SoundController::playLogin()
{
    playSdlSample(m_sdlLogin, static_cast<float>(m_masterVolume * m_sfxVolume));
}

void SoundController::playLogout()
{
    playSdlSample(m_sdlLogout, static_cast<float>(m_masterVolume * m_sfxVolume));
}

void SoundController::playNotification()
{
    playSdlSample(m_sdlNotification, static_cast<float>(m_masterVolume * m_sfxVolume));
}

void SoundController::playTrophy()
{
    playSdlSample(m_sdlTrophy, static_cast<float>(m_masterVolume * m_sfxVolume));
}

void SoundController::playKeypress()
{
    playSdlSample(m_sdlKeyPress, static_cast<float>(m_masterVolume * m_sfxVolume * 0.75f));
}

void SoundController::playCursorMove()
{
    playSdlSample(m_sdlCursorMove, static_cast<float>(m_masterVolume * m_sfxVolume * 0.70f));
}

void SoundController::playBackspace()
{
    playSdlSample(m_sdlBackspace, static_cast<float>(m_masterVolume * m_sfxVolume * 0.75f));
}

void SoundController::playKeyError()
{
    playSdlSample(m_sdlKeyError, static_cast<float>(m_masterVolume * m_sfxVolume * 0.80f));
}

#else

// Qt Multimedia Implementation
void SoundController::initSounds()
{
    auto loadEffect = [this](const QString &file) -> QSoundEffect* {
        QString path = QString("%1/%2").arg(m_assetsDir, file);
        if (QFile::exists(path)) {
            auto *effect = new QSoundEffect(this);
            effect->setSource(QUrl::fromLocalFile(QFileInfo(path).absoluteFilePath()));
            effect->setVolume(static_cast<float>(m_masterVolume * m_sfxVolume));
            return effect;
        }
        return nullptr;
    };

    auto *tick = loadEffect("nav_tick.wav");
    if (tick) m_tickPool.append(tick);

    m_confirmSound = loadEffect("confirm.wav");
    m_backSound = loadEffect("back.wav");
    m_optionsSound = loadEffect("options.wav");
    m_bootChimeSound = loadEffect("boot_chime.wav");
    m_loginSound = loadEffect("login.wav");
    m_logoutSound = loadEffect("logout.wav");
    m_notificationSound = loadEffect("notification.wav");
    m_trophySound = loadEffect("trophy.wav");

    m_keyPressSound = loadEffect("keyboard/key_press.wav");
    m_cursorMoveSound = loadEffect("keyboard/cursor_move.wav");
    m_keyErrorSound = loadEffect("keyboard/key_error.wav");
    m_backspaceSound = loadEffect("keyboard/backspace.wav");

    // Initialize BGM Player
    m_bgmPlayer = new QMediaPlayer(this);
    m_bgmAudioOutput = new QAudioOutput(this);
    m_bgmPlayer->setAudioOutput(m_bgmAudioOutput);
    m_bgmAudioOutput->setVolume(static_cast<float>(m_masterVolume * m_bgmVolume));
    m_bgmPlayer->setLoops(QMediaPlayer::Infinite);

    QString bgmPath = QString("%1/home_screen_music.wav").arg(m_assetsDir);
    if (!QFile::exists(bgmPath)) {
        bgmPath = QString("%1/flac/home_screen_music.flac").arg(m_assetsDir);
    }
    if (QFile::exists(bgmPath)) {
        m_bgmPlayer->setSource(QUrl::fromLocalFile(QFileInfo(bgmPath).absoluteFilePath()));
    }
}

void SoundController::playTick()
{
    if (!m_enabled || m_tickPool.isEmpty()) return;
    m_tickPool[0]->setVolume(static_cast<float>(m_masterVolume * m_sfxVolume));
    m_tickPool[0]->play();
}

void SoundController::playConfirm()
{
    if (m_enabled && m_confirmSound) {
        m_confirmSound->setVolume(static_cast<float>(m_masterVolume * m_sfxVolume));
        m_confirmSound->play();
    }
}

void SoundController::playBack()
{
    if (m_enabled && m_backSound) {
        m_backSound->setVolume(static_cast<float>(m_masterVolume * m_sfxVolume));
        m_backSound->play();
    }
}

void SoundController::playOptions()
{
    if (m_enabled && m_optionsSound) {
        m_optionsSound->setVolume(static_cast<float>(m_masterVolume * m_sfxVolume));
        m_optionsSound->play();
    }
}

void SoundController::playBootChime()
{
    if (m_enabled && m_bootChimeSound) {
        m_bootChimeSound->setVolume(static_cast<float>(m_masterVolume * 0.75));
        m_bootChimeSound->play();
    }
}

void SoundController::stopBootChime()
{
    if (m_bootChimeSound) {
        m_bootChimeSound->stop();
    }
}

void SoundController::playHomeScreenMusic()
{
    m_homeScreenMusicPlaying = true;
    if (m_enabled && m_bgmEnabled && m_bgmPlayer) {
        m_bgmAudioOutput->setVolume(static_cast<float>(m_masterVolume * m_bgmVolume));
        m_bgmPlayer->play();
    }
}

void SoundController::stopHomeScreenMusic()
{
    m_homeScreenMusicPlaying = false;
    if (m_bgmPlayer) {
        m_bgmPlayer->stop();
    }
}

void SoundController::playLogin()
{
    if (m_enabled && m_loginSound) {
        m_loginSound->setVolume(static_cast<float>(m_masterVolume * m_sfxVolume));
        m_loginSound->play();
    }
}

void SoundController::playLogout()
{
    if (m_enabled && m_logoutSound) {
        m_logoutSound->setVolume(static_cast<float>(m_masterVolume * m_sfxVolume));
        m_logoutSound->play();
    }
}

void SoundController::playNotification()
{
    if (m_enabled && m_notificationSound) {
        m_notificationSound->setVolume(static_cast<float>(m_masterVolume * m_sfxVolume));
        m_notificationSound->play();
    }
}

void SoundController::playTrophy()
{
    if (m_enabled && m_trophySound) {
        m_trophySound->setVolume(static_cast<float>(m_masterVolume * m_sfxVolume));
        m_trophySound->play();
    }
}

void SoundController::playKeypress()
{
    if (m_enabled && m_keyPressSound) {
        m_keyPressSound->setVolume(static_cast<float>(m_masterVolume * m_sfxVolume * 0.75));
        m_keyPressSound->play();
    }
}

void SoundController::playCursorMove()
{
    if (m_enabled && m_cursorMoveSound) {
        m_cursorMoveSound->setVolume(static_cast<float>(m_masterVolume * m_sfxVolume * 0.70));
        m_cursorMoveSound->play();
    }
}

void SoundController::playBackspace()
{
    if (m_enabled && m_backspaceSound) {
        m_backspaceSound->setVolume(static_cast<float>(m_masterVolume * m_sfxVolume * 0.75));
        m_backspaceSound->play();
    }
}

void SoundController::playKeyError()
{
    if (m_enabled && m_keyErrorSound) {
        m_keyErrorSound->setVolume(static_cast<float>(m_masterVolume * m_sfxVolume * 0.80));
        m_keyErrorSound->play();
    }
}

#endif
