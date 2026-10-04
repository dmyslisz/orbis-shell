import QtQuick
import QtQuick.Controls

Item {
    id: root
    anchors.fill: parent

    property color baseColor1: "#001640"
    property color baseColor2: "#003791"
    property color baseColor3: "#000d28"
    property color accentTint: "#00000000"

    property real driftSpeed: 0.00045
    property real phase: 0.0

    // Deep PlayStation royal blue gradient background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.baseColor1 }
            GradientStop { position: 0.42; color: root.baseColor2 }
            GradientStop { position: 1.0; color: root.baseColor3 }
        }
    }

    // Dynamic accent cross-fade layer on item change
    Rectangle {
        id: accentLayer
        anchors.fill: parent
        opacity: 0.0
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.50; color: root.accentTint }
            GradientStop { position: 1.0; color: "#50001030" }
        }

        Behavior on opacity {
            NumberAnimation { duration: 240; easing.type: Easing.OutQuad }
        }
    }

    // Canvas drawing flowing Orbis OS ribbons & glowing sweeps
    Canvas {
        id: ribbonCanvas
        anchors.fill: parent
        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Threaded

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var w = width;
            var h = height;

            // Main broad sweeping glowing ribbon (arching across bottom-middle)
            var grad1 = ctx.createLinearGradient(0, h * 0.35, w, h);
            grad1.addColorStop(0.0, "rgba(0, 110, 240, 0.0)");
            grad1.addColorStop(0.38, "rgba(0, 140, 255, 0.24)");
            grad1.addColorStop(0.70, "rgba(0, 80, 220, 0.16)");
            grad1.addColorStop(1.0, "rgba(0, 40, 150, 0.0)");

            ctx.beginPath();
            ctx.moveTo(0, h * 0.96);
            var cp1x = w * 0.35 + Math.sin(root.phase * 0.8) * 45;
            var cp1y = h * 0.52 + Math.cos(root.phase * 0.6) * 32;
            var cp2x = w * 0.74 + Math.cos(root.phase * 0.7) * 38;
            var cp2y = h * 0.70 + Math.sin(root.phase * 0.5) * 28;
            ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, w, h * 0.78);
            ctx.lineTo(w, h);
            ctx.lineTo(0, h);
            ctx.closePath();
            ctx.fillStyle = grad1;
            ctx.fill();

            // Ribbon top highlight edge
            ctx.beginPath();
            ctx.moveTo(0, h * 0.94);
            ctx.bezierCurveTo(cp1x, cp1y - 14, cp2x, cp2y - 10, w, h * 0.76);
            ctx.strokeStyle = "rgba(120, 205, 255, 0.32)";
            ctx.lineWidth = 3.2;
            ctx.stroke();

            // Floating delicate ribbon arcs
            var ribbons = [
                { yStart: h * 0.84, yEnd: h * 0.66, amp: 38, freq: 0.0015, speed: 0.9, color: "rgba(80, 170, 255, 0.20)", lw: 2.2 },
                { yStart: h * 0.89, yEnd: h * 0.73, amp: 48, freq: 0.0011, speed: 1.1, color: "rgba(120, 210, 255, 0.16)", lw: 1.8 },
                { yStart: h * 0.74, yEnd: h * 0.60, amp: 30, freq: 0.0019, speed: 0.7, color: "rgba(50, 140, 245, 0.14)", lw: 2.0 }
            ];

            for (var r = 0; r < ribbons.length; ++r) {
                var rib = ribbons[r];
                var t = root.phase * rib.speed;

                ctx.beginPath();
                ctx.strokeStyle = rib.color;
                ctx.lineWidth = rib.lw;

                var step = 20;
                for (var x = 0; x <= w + step; x += step) {
                    var norm = x / w;
                    var y = rib.yStart + (rib.yEnd - rib.yStart) * norm
                          + Math.sin(x * rib.freq + t) * rib.amp
                          + Math.cos(norm * 3.1415 - t * 0.5) * 16;
                    if (x === 0) ctx.moveTo(x, y);
                    else ctx.lineTo(x, y);
                }
                ctx.stroke();
            }
        }
    }

    // Ambient floating PlayStation glyphs: △ ◯ ✕ ▢
    Item {
        anchors.fill: parent

        Repeater {
            model: [
                { glyph: "△", x: 920, y: 740, size: 22, driftX: 20, driftY: 28, speed: 0.6, baseOp: 0.38 },
                { glyph: "◯", x: 970, y: 750, size: 20, driftX: -18, driftY: 22, speed: 0.8, baseOp: 0.32 },
                { glyph: "▢", x: 1020, y: 735, size: 20, driftX: 22, driftY: -20, speed: 0.7, baseOp: 0.35 },
                { glyph: "✕", x: 950, y: 780, size: 22, driftX: -16, driftY: -24, speed: 0.9, baseOp: 0.30 },
                { glyph: "△", x: 1400, y: 620, size: 18, driftX: 26, driftY: 22, speed: 0.5, baseOp: 0.25 },
                { glyph: "◯", x: 1480, y: 650, size: 16, driftX: -20, driftY: 18, speed: 0.75, baseOp: 0.22 },
                { glyph: "▢", x: 420, y: 800, size: 18, driftX: 18, driftY: -22, speed: 0.65, baseOp: 0.24 },
                { glyph: "✕", x: 490, y: 830, size: 17, driftX: -22, driftY: 19, speed: 0.85, baseOp: 0.20 }
            ]

            Text {
                required property var modelData
                text: modelData.glyph
                font.pixelSize: modelData.size
                font.weight: Font.Normal
                color: "#ffffff"
                opacity: modelData.baseOp + Math.sin(root.phase * modelData.speed * 2.0) * 0.12
                x: modelData.x + Math.sin(root.phase * modelData.speed) * modelData.driftX
                y: modelData.y + Math.cos(root.phase * modelData.speed * 0.8) * modelData.driftY
            }
        }
    }

    // 60 FPS animation ticker
    FrameAnimation {
        running: true
        onTriggered: {
            root.phase += root.driftSpeed * 16.666;
            ribbonCanvas.requestPaint();
        }
    }

    function setAccent(colorStr) {
        if (!colorStr || colorStr === "") {
            accentLayer.opacity = 0.0;
        } else {
            root.accentTint = colorStr;
            accentLayer.opacity = 0.38;
        }
    }
}
