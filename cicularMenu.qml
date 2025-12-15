import QtQuick
import QtQuick.Controls

// ریشه کامپوننت
ApplicationWindow {
    id: appWindow
    visible: true
    width: 640
    height: 480
    title: "منوی دایره‌ای QML با Canvas"

    // متغیرهای وضعیت و تنظیمات
    property bool menuOpen: false
    property real menuRadius: 100 // شعاع دایره برای آیتم‌های باز شده
    property int mainButtonSize: 50
    property int itemButtonSize: 40
    property var menuItemsData: [ // تعریف آیتم‌ها
        { label: "A", color: "#2ecc71" },
        { label: "B", color: "#f1c40f" },
        { label: "C", color: "#e74c3c" },
        { label: "D", color: "#3498db" },
        { label: "E", color: "#95a5a6" },
        { label: "T", color: "#95a5a6" },
        { label: "T", color: "#95a5a6" },
        { label: "T", color: "#95a5a6" },
        { label: "T", color: "#95a5a6" },
        { label: "T", color: "#95a5a6" }
    ]

    // کانتینر Canvas برای رسم
    Canvas {
        id: menuCanvas
        width: 300
        height: 300
        anchors.centerIn: parent

        // مرکز منو (نقطه مرجع برای رسم)
        property real centerX: width / 2
        property real centerY: height / 2

        // تابع کمکی برای محاسبه موقعیت آیتم‌ها روی دایره
        function calculatePosition(index) {
            var itemCount = menuItemsData.length;
            // شروع از 270 درجه (بالا)
            var angle = 270 + (index * (360 / itemCount));
            var angleRad = angle * Math.PI / 180; // تبدیل به رادیان
            return {
                x: centerX + menuRadius * Math.cos(angleRad),
                y: centerY + menuRadius * Math.sin(angleRad)
            };
        }

        // رندر کردن منو
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            // 1. رسم دکمه اصلی (Main Button)
            ctx.fillStyle = menuOpen ? "#c0392b" : "#2980b9"; // رنگ بر اساس وضعیت باز بودن
            ctx.beginPath();
            ctx.arc(centerX, centerY, mainButtonSize / 2, 0, 2 * Math.PI);
            ctx.shadowBlur = 10;
            ctx.shadowColor = "rgba(0, 0, 0, 0.4)";
            ctx.fill();
            ctx.shadowBlur = 0; // ریست کردن سایه برای متن

            // متن دکمه اصلی
            ctx.fillStyle = "white";
            ctx.font = "bold 24px Inter, sans-serif";
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            ctx.fillText(menuOpen ? "✕" : "+", centerX, centerY);


            // 2. رسم آیتم‌های فرعی (Sub-Buttons)
            if (menuOpen) {
                for (var i = 0; i < menuItemsData.length; i++) {
                    var pos = calculatePosition(i);
                    var item = menuItemsData[i];

                    // رسم دایره آیتم
                    ctx.fillStyle = item.color;
                    ctx.beginPath();
                    ctx.arc(pos.x, pos.y, itemButtonSize / 2, 0, 2 * Math.PI);
                    ctx.shadowBlur = 5;
                    ctx.shadowColor = "rgba(0, 0, 0, 0.3)";
                    ctx.fill();
                    ctx.shadowBlur = 0; // ریست کردن سایه برای متن

                    // متن/شماره آیتم
                    ctx.fillStyle = "white";
                    ctx.font = "bold 16px Inter, sans-serif";
                    // نمایش شماره آیتم (به جای آیکون)
                    ctx.fillText(menuItemsData[i].label, pos.x, pos.y);
                }
            }
        }

        // تشخیص کلیک (Hit-Testing)
        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => {
                var clickX = mouse.x;
                var clickY = mouse.y;

                // تابع کمکی برای بررسی برخورد دایره‌ای (فاصله مرکز تا نقطه کمتر از شعاع باشد)
                function isInsideCircle(cx, cy, radius, px, py) {
                    return Math.pow(px - cx, 2) + Math.pow(py - cy, 2) < Math.pow(radius, 2);
                }

                // A. بررسی کلیک روی آیتم‌های باز شده
                if (menuOpen) {
                    var itemClicked = false;
                    for (var i = 0; i < menuItemsData.length; i++) {
                        var pos = menuCanvas.calculatePosition(i);
                        if (isInsideCircle(pos.x, pos.y, itemButtonSize / 2, clickX, clickY)) {
                            // آیتم کلیک شد
                            console.log("Item Clicked: " + menuItemsData[i].label);
                            menuOpen = false; // بستن منو
                            itemClicked = true;
                            break;
                        }
                    }
                    if (itemClicked) {
                        menuCanvas.requestPaint(); // بازرسم Canvas
                        return;
                    }
                }

                // B. بررسی کلیک روی دکمه اصلی
                if (isInsideCircle(menuCanvas.centerX, menuCanvas.centerY, mainButtonSize / 2, clickX, clickY)) {
                    menuOpen = !menuOpen;
                    menuCanvas.requestPaint(); // بازرسم Canvas
                }
            }
        }

        // در صورت تغییر وضعیت منو، Canvas باید دوباره رسم شود
        // onMenuOpenChanged: {
        //     menuCanvas.requestPaint();
        // }
    }
}
