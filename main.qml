import QtQuick
import QtQuick.Controls

// ریشه کامپوننت
ApplicationWindow {
    id: appWindow
    visible: true
    width: 640
    height: 480
    title: "Pie Menu (Animated & Hover)"
    color: "#393939"

    property bool menuOpen: false
    property real menuRadius: 120
    property real innerRadius: 40

    property string colorItem: "#95a5a6"
    property string colorHoverItem: "#7c898a"
    property var menuItemData: ["Home", "Setting", "Profile", "Info", "Exit"]
    // ----------------------------

    // ** (A) مدیریت انیمیشن باز و بسته شدن **
    onMenuOpenChanged: {
        if (menuOpen) {
            // 1. نمایش فوری منو با اندازه کامل
            menuCanvas.menuProgress = 1.0;

            // 2. تنظیم اولیه فاصله بین قطاع‌ها و فاصله از مرکز
            menuCanvas.separationFactor = 1.0;      // حداکثر فاصله
            menuCanvas.centerOffsetFactor = 0.0;    // حداکثر جابجایی از مرکز
            separationAnimation.start();
        } else {
            // بستن فوری منو
            menuCanvas.menuProgress = 0.0;
            menuCanvas.hoveredIndex = -1; // ریست کردن هایلایت
            separationAnimation.stop();
            // هنگام بسته شدن، فاکتور جابجایی را روی حالت نهایی (چسبیده) تنظیم می‌کنیم
            menuCanvas.centerOffsetFactor = 1.0;
        }
    }

    // ** (C) انیمیشن برای بستن شکاف و سپس حرکت به مرکز **
    SequentialAnimation {
        id: separationAnimation
        running: false

        // کمی مکث بعد از ظاهر شدن منو
        // PauseAnimation { duration: 50 }

        // Phase 1: بستن شکاف بین قطاع‌ها (separationFactor: 1.0 -> 0.0)
        NumberAnimation {
            target: menuCanvas
            property: "separationFactor"
            to: 0.0
            duration: 10 // مدت زمان چسبیدن قطاع ها بهم دیگر
            easing.type: Easing.OutCubic
        }

        // Phase 2: حرکت قطاع‌ها به سمت مرکز (centerOffsetFactor: 0.0 -> 1.0)
        NumberAnimation {
            target: menuCanvas
            property: "centerOffsetFactor"
            to: 1.0
            duration: 350 // مدت زمان حرکت به مرکز
            easing.type: Easing.OutQuint
        }
    }

    Canvas {
        id: menuCanvas
        width: 300
        height: 300

        // ** (B) متغیرهای انیمیشن و هاور **
        property real menuProgress: 0.0 // 0.0 بسته، 1.0 باز کامل
        property int hoveredIndex: -1 // نگهداری ایندکس قطاعی که ماوس روی آن است

        // عامل جداسازی (1.0 = حداکثر فاصله، 0.0 = بدون فاصله)
        property real separationFactor: 0.0

        // NEW: عامل فاصله از مرکز
        // 0.0 = حداکثر جابجایی (دور از مرکز)، 1.0 = بدون جابجایی (چسبیده به مرکز)
        property real centerOffsetFactor: 1.0
        property real maxCenterOffset: 15 // حداکثر جابجایی از مرکز به پیکسل

        // هر زمان که هر یک از فاکتورهای انیمیشن تغییر کند، بازرسم شود
        onMenuProgressChanged: menuCanvas.requestPaint()
        onHoveredIndexChanged: menuCanvas.requestPaint()
        onSeparationFactorChanged: menuCanvas.requestPaint()
        onCenterOffsetFactorChanged: menuCanvas.requestPaint()


        // مرکز منو (نقطه مرجع برای رسم) - محلی و ثابت (150, 150)
        property real centerX: width / 2
        property real centerY: height / 2

        // تابع کمکی برای محاسبه زوایای شروع و پایان یک قطاع
        function calculateSectorAngles(index) {
            var itemCount = menuItemData.length;
            var angleStep = 360 / itemCount;

            // مقدار حداکثر جداسازی زاویه‌ای (مثلاً 2 درجه شکاف کلی برای هر قطاع)
            var maxGapAngle = 2.0;

            // محاسبه شکاف فعلی بر اساس separationFactor (0.0 تا maxGapAngle)
            var currentGap = maxGapAngle * separationFactor;

            // شروع از 270 درجه (بالا)
            var nominalStartAngle = 270 + (index * angleStep);

            // اعمال نصف شکاف در ابتدا و نصف دیگر در انتهای هر قطاع
            var startAngle = nominalStartAngle + currentGap / 2;
            var endAngle = nominalStartAngle + angleStep - currentGap / 2;

            // تبدیل به رادیان
            var startRad = startAngle * Math.PI / 180;
            var endRad = endAngle * Math.PI / 180;

            return { start: startRad, end: endRad, center: (startRad + endRad) / 2 };
        }

        // رندر کردن منو
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            if (menuProgress > 0) { // فقط زمانی رسم شود که منو باز است

                // شعاع‌های کامل (بدون انیمیشن شعاع)
                var currentRadius = menuRadius;
                var currentInnerRadius = innerRadius;

                // شفافیت متحرک
                ctx.globalAlpha = menuProgress;

                // محاسبه جابجایی فعلی از مرکز بر اساس centerOffsetFactor
                // اگر centerOffsetFactor = 0.0 باشد، جابجایی حداکثر است (maxCenterOffset)
                // اگر centerOffsetFactor = 1.0 باشد، جابجایی صفر است (چسبیده به مرکز)
                var currentOffsetDistance = maxCenterOffset * (1.0 - centerOffsetFactor);

                // 1. رسم قطاع‌های دایره‌ای (Pie Slices)
                for (var i = 0; i < menuItemData.length; i++) {
                    var angles = calculateSectorAngles(i);
                    var label = menuItemData[i];

                    // محاسبه جهت جابجایی (بردار واحد)
                    var directionX = Math.cos(angles.center);
                    var directionY = Math.sin(angles.center);

                    // محاسبه مرکز واقعی قطاع در اثر جابجایی
                    var offsetX = centerX + directionX * currentOffsetDistance;
                    var offsetY = centerY + directionY * currentOffsetDistance;

                    if (i === hoveredIndex) {
                        ctx.fillStyle = colorHoverItem;
                    } else {
                        ctx.fillStyle = colorItem;
                    }

                    ctx.shadowBlur = 8;
                    ctx.shadowColor = "rgba(0, 0, 0, 0.4)";
                    ctx.beginPath();
                    // استفاده از offsetX و offsetY به عنوان مرکز کمان
                    ctx.moveTo(offsetX, offsetY);
                    ctx.arc(offsetX, offsetY, currentRadius, angles.start, angles.end);
                    ctx.lineTo(offsetX, offsetY);

                    ctx.fill();
                    ctx.shadowBlur = 0; // ریست کردن سایه برای متن

                    // اضافه کردن متن در مرکز قطاع
                    var middleRadius = (currentInnerRadius + currentRadius) / 2;

                    // محاسبه موقعیت متن: مرکز واقعی + جابجایی در جهت قطاع
                    var textX = centerX + directionX * (middleRadius + currentOffsetDistance);
                    var textY = centerY + directionY * (middleRadius + currentOffsetDistance);

                    ctx.fillStyle = "white";
                    ctx.font = "bold 14px Inter, sans-serif";
                    ctx.textAlign = "center";
                    ctx.textBaseline = "middle";
                    ctx.fillText(label, textX, textY);
                }

                // 2. رسم دایره داخلی (خالی)
                // این دایره باید در مرکز ثابت (centerX, centerY) رسم شود و جابجا نشود.
                ctx.fillStyle = appWindow.color;
                ctx.beginPath();
                ctx.arc(centerX, centerY, currentInnerRadius, 0, 2 * Math.PI);
                ctx.fill();
            }

            ctx.globalAlpha = 1.0; // ریست کردن شفافیت کلی
        }
    }

    // ناحیه تشخیص کلیک که تمام پنجره را پوشش می‌دهد
    MouseArea {
        id: rootMouseArea
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        hoverEnabled: true

        // تابع کمکی برای محاسبه فاصله (اصلاح شده)
        function getDistance(x1, y1, x2, y2) {
            return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
        }

        // تابع کمکی برای تشخیص قطاع بر اساس مختصات محلی
        function detectSector(localClickX, localClickY) {
            // در منطق تشخیص کلیک، فاصله از مرکز ثابت را استفاده می‌کنیم تا ناحیه فعال ثابت باشد
            var dist = getDistance(menuCanvas.centerX, menuCanvas.centerY, localClickX, localClickY);

            // بررسی فاصله (بین شعاع داخلی و شعاع بیرونی)
            if (dist >= innerRadius && dist <= menuRadius) {
                var angle = Math.atan2(localClickY - menuCanvas.centerY, localClickX - menuCanvas.centerX) * 180 / Math.PI;
                if (angle < 0) angle += 360; // 0-360

                // تنظیم زاویه بر اساس شروع 270 درجه (بالا)
                var adjustedAngle = (angle - 270 + 360) % 360;

                var itemCount = menuItemData.length;
                var angleStep = 360 / itemCount;

                return Math.floor(adjustedAngle / angleStep);
            }
            return -1; // خارج از محدوده قطاع‌ها
        }

        // ** (E) منطق تشخیص Mouse Hover **
        onPositionChanged: (mouse) => {
            if (menuOpen) {
                // تبدیل مختصات جهانی به محلی Canvas
                var localX = mouse.x - menuCanvas.x;
                var localY = mouse.y - menuCanvas.y;
                // به‌روزرسانی hoveredIndex و در نتیجه فراخوانی requestPaint
                menuCanvas.hoveredIndex = detectSector(localX, localY);
            }
        }

        onExited: {
            // وقتی ماوس از کل پنجره خارج می‌شود، هایلایت را ریست کن
            menuCanvas.hoveredIndex = -1;
        }

        onClicked: (mouse) => {
            var clickX = mouse.x;
            var clickY = mouse.y;

            // ************************************************
            // ** 1. منطق کلیک راست (باز کردن منو در محل کلیک) **
            // ************************************************
            if (mouse.button === Qt.RightButton) {
                if (!menuOpen) {
                    // محاسبه موقعیت Canvas برای مرکز شدن آن روی محل کلیک
                    menuCanvas.x = clickX - menuCanvas.width / 2;
                    menuCanvas.y = clickY - menuCanvas.height / 2;
                }
                menuOpen = !menuOpen;
                mouse.accepted = true;
                return;
            }

            // ************************************************
            // ** 2. منطق کلیک چپ (انتخاب قطاع) **
            // ************************************************
            if (menuOpen && mouse.button === Qt.LeftButton) {
                // تبدیل مختصات جهانی به محلی Canvas
                var localClickX = clickX - menuCanvas.x;
                var localClickY = clickY - menuCanvas.y;

                var dist = getDistance(menuCanvas.centerX, menuCanvas.centerY, localClickX, localClickY);
                var clickedIndex = detectSector(localClickX, localClickY);

                if (clickedIndex !== -1) {
                    console.log("Pie Sector Clicked: " + menuItemData[clickedIndex]);
                    menuOpen = false; // بستن منو پس از انتخاب
                } else if (dist < innerRadius) {
                    // اگر کلیک در فضای خالی وسط باشد، منو بسته می‌شود
                    menuOpen = false;
                } else {
                    // اگر کلیک خارج از محدوده منو باشد، منو بسته می‌شود
                    menuOpen = false;
                }
            }
        }
    }
}
