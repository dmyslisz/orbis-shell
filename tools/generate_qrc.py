import os

def main():
    root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    qrc_path = os.path.join(root, "resources.qrc")

    qml_dir = os.path.join(root, "qml")
    assets_dir = os.path.join(root, "assets")
    config_dir = os.path.join(root, "config")

    files = []

    # QML files
    for f in sorted(os.listdir(qml_dir)):
        if f.endswith(".qml"):
            files.append(f"qml/{f}")

    # Config files
    for f in sorted(os.listdir(config_dir)):
        if f.endswith(".json"):
            files.append(f"config/{f}")

    # Assets (icons, covers, avatars, buttons, short sfx)
    for sub in ["icons", "covers", "avatars"]:
        sub_path = os.path.join(assets_dir, sub)
        if os.path.exists(sub_path):
            for r, d, fs in os.walk(sub_path):
                for f in sorted(fs):
                    rel = os.path.relpath(os.path.join(r, f), root).replace("\\", "/")
                    files.append(rel)

    # Sounds (include short SFX and keyboard, omit 90MB BGM from binary RCC)
    sounds_path = os.path.join(assets_dir, "sounds")
    if os.path.exists(sounds_path):
        for r, d, fs in os.walk(sounds_path):
            # Skip flac raw directory from binary RCC
            if "flac" in r:
                continue
            for f in sorted(fs):
                if f.endswith(".wav"):
                    # Check size: omit files > 10MB from embedding
                    full_p = os.path.join(r, f)
                    if os.path.getsize(full_p) < 15 * 1024 * 1024:
                        rel = os.path.relpath(full_p, root).replace("\\", "/")
                        files.append(rel)

    lines = ['<RCC>', '    <qresource prefix="/">']
    for f in files:
        lines.append(f'        <file>{f}</file>')
    lines.append('    </qresource>')
    lines.append('</RCC>')

    with open(qrc_path, "w", encoding="utf-8") as out:
        out.write("\n".join(lines) + "\n")

    print(f"resources.qrc generated successfully with {len(files)} files.")

if __name__ == "__main__":
    main()
