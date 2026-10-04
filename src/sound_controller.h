#pragma once

#include <QObject>
#include <QVector>
#include <QJsonObject>
#include <QString>
#include <QTimer>

#ifdef HAVE_SDL3
#include <SDL3/SDL.h>
#else
#include <QSoundEffect>
#include <QMediaPlayer>
#include <QAudioOutput>
#endif

class SoundController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool soundEnabled READ soundEnabled WRITE setSoundEnabled NOTIFY soundEnabledChanged)
    Q_PROPERTY(bool bgmEnabled READ bgmEnabled WRITE setBgmEnabled NOTIFY bgmEnabledChanged)
    Q_PROPERTY(double masterVolume READ masterVolume WRITE setMasterVolume NOTIFY masterVolumeChanged)
    Q_PROPERTY(double sfxVolume READ sfxVolume WRITE setSfxVolume NOTIFY sfxVolumeChanged)
    Q_PROPERTY(double bgmVolume READ bgmVolume WRITE setBgmVolume NOTIFY bgmVolumeChanged)

public:
    explicit SoundController(const QString &baseAssetDir = QString(), QObject *parent = nullptr);
    ~SoundController() override;

    bool soundEnabled() const { return m_enabled; }
    void setSoundEnabled(bool enabled);

    bool bgmEnabled() const { return m_bgmEnabled; }
    void setBgmEnabled(bool enabled);

    double masterVolume() const { return m_masterVolume; }
    void setMasterVolume(double vol);

    double sfxVolume() const { return m_sfxVolume; }
    void setSfxVolume(double vol);

    double bgmVolume() const { return m_bgmVolume; }
    void setBgmVolume(double vol);

    void updateTunables(const QJsonObject &soundTunables);

    // Audio SFX triggers
    Q_INVOKABLE void playTick();
    Q_INVOKABLE void playConfirm();
    Q_INVOKABLE void playBack();
    Q_INVOKABLE void playOptions();
    Q_INVOKABLE void playBootChime();
    Q_INVOKABLE void stopBootChime();
    Q_INVOKABLE void playHomeScreenMusic();
    Q_INVOKABLE void stopHomeScreenMusic();
    Q_INVOKABLE void playLogin();
    Q_INVOKABLE void playLogout();
    Q_INVOKABLE void playNotification();
    Q_INVOKABLE void playTrophy();

    // Virtual Keyboard SFX triggers
    Q_INVOKABLE void playKeypress();
    Q_INVOKABLE void playCursorMove();
    Q_INVOKABLE void playBackspace();
    Q_INVOKABLE void playKeyError();

signals:
    void soundEnabledChanged();
    void bgmEnabledChanged();
    void masterVolumeChanged();
    void sfxVolumeChanged();
    void bgmVolumeChanged();

private:
    void initSounds();

    QString m_assetsDir;
    bool m_enabled = true;
    bool m_bgmEnabled = true;
    double m_masterVolume = 0.65;
    double m_sfxVolume = 0.70;
    double m_bgmVolume = 0.40;
    bool m_pitchVariation = true;
    bool m_homeScreenMusicPlaying = false;

    int m_lastTickIdx = 0;

#ifdef HAVE_SDL3
    struct SoundSample {
        Uint8 *data = nullptr;
        Uint32 length = 0;
        SDL_AudioSpec spec;
        SDL_AudioStream *stream = nullptr;
    };

    SDL_AudioDeviceID m_audioDevice = 0;
    bool m_sdlAudioReady = false;

    SoundSample loadSdlSample(const QString &relativeFilePath);
    void playSdlSample(SoundSample &sample, float volume, bool loop = false);
    void stopSdlSample(SoundSample &sample);
    void freeSdlSample(SoundSample &sample);

    QVector<SoundSample> m_sdlTickPool;
    SoundSample m_sdlConfirm;
    SoundSample m_sdlBack;
    SoundSample m_sdlOptions;
    SoundSample m_sdlBootChime;
    SoundSample m_sdlHomeScreenMusic;
    SoundSample m_sdlLogin;
    SoundSample m_sdlLogout;
    SoundSample m_sdlNotification;
    SoundSample m_sdlTrophy;

    SoundSample m_sdlKeyPress;
    SoundSample m_sdlCursorMove;
    SoundSample m_sdlKeyError;
    SoundSample m_sdlBackspace;
#else
    QVector<QSoundEffect*> m_tickPool;
    QSoundEffect *m_confirmSound = nullptr;
    QSoundEffect *m_backSound = nullptr;
    QSoundEffect *m_optionsSound = nullptr;
    QSoundEffect *m_bootChimeSound = nullptr;
    QSoundEffect *m_loginSound = nullptr;
    QSoundEffect *m_logoutSound = nullptr;
    QSoundEffect *m_notificationSound = nullptr;
    QSoundEffect *m_trophySound = nullptr;

    QSoundEffect *m_keyPressSound = nullptr;
    QSoundEffect *m_cursorMoveSound = nullptr;
    QSoundEffect *m_keyErrorSound = nullptr;
    QSoundEffect *m_backspaceSound = nullptr;

    QMediaPlayer *m_bgmPlayer = nullptr;
    QAudioOutput *m_bgmAudioOutput = nullptr;
#endif
};
