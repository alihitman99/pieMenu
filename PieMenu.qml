import QtQuick
import QtQuick.Controls

// ریشه کامپوننت
ApplicationWindow {
    id: appWindow
    visible: true
    width: 640
    height: 480
    title: "منوی پای (Pie Menu) QML با Canvas و متن"
    color: "#393939"

    // متغیرهای وضعیت و تنظیمات
    property bool menuOpen: false
    property real menuRadius: 120 // شعاع بزرگتر برای نمایش قطاع‌ها
    property real innerRadius: 40 // شعاع داخلی برای فضای خالی
    // اندازه دکمه اصلی حذف شد
    property var menuItemsData: [ // تعریف آیتم‌ها
        { label: "خانه", color: "#95a5a6" }, // سبز
        { label: "تنظیمات", color: "#95a5a6" }, // زرد
        { label: "پروفایل", color: "#95a5a6" }, // قرمز
        { label: "اطلاعیه‌ها", color: "#95a5a6" }, // آبی
        { label: "خروج", color: "#95a5a6" } // خاکستری
    ]

    // کانتینر Canvas برای رسم
    Canvas {
        id: menuCanvas
        width: 300 // فضای کافی برای نمایش منوی با شعاع 120
        height: 300
        // anchors.centerIn: parent

        // مرکز منو (نقطه مرجع برای رسم)
        property real centerX: width / 2
        property real centerY: height / 2

        // تابع کمکی برای محاسبه زوایای شروع و پایان یک قطاع
        function calculateSectorAngles(index) {
            var itemCount = menuItemsData.length;
            var angleStep = 360 / itemCount;

            // شروع از 270 درجه (بالا)
            var startAngle = 270 + (index * angleStep);
            var endAngle = startAngle + angleStep;

            // تبدیل به رادیان
            var startRad = startAngle * Math.PI / 180;
            var endRad = endAngle * Math.PI / 180;

            return { start: startRad, end: endRad, center: (startRad + endRad) / 2 };
        }

        // رندر کردن منو
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            // 1. رسم قطاع‌های دایره‌ای (Pie Slices)
            if (menuOpen) {
                // رسم یک دایره بیرونی شفاف به عنوان پس‌زمینه
                ctx.fillStyle = "rgba(0, 0, 0, 0.05)";
                ctx.beginPath();
                ctx.arc(centerX, centerY, menuRadius, 0, 2 * Math.PI);
                ctx.fill();

                for (var i = 0; i < menuItemsData.length; i++) {
                    var angles = calculateSectorAngles(i);
                    var item = menuItemsData[i];

                    // رسم قطاع
                    ctx.fillStyle = item.color;
                    ctx.beginPath();

                    // از نقطه مرکزی شروع کنید
                    ctx.moveTo(centerX, centerY);

                    // رسم کمان بیرونی (شعاع بزرگتر)
                    ctx.arc(centerX, centerY, menuRadius, angles.start, angles.end);

                    // رسم خط داخلی به مرکز (برای تکمیل قطاع)
                    ctx.lineTo(centerX, centerY);

                    ctx.shadowBlur = 8;
                    ctx.shadowColor = "rgba(0, 0, 0, 0.3)";
                    ctx.fill();
                    ctx.shadowBlur = 0;

                    // اضافه کردن متن در مرکز قطاع
                    // موقعیت متن در نیمه راه بین innerRadius و menuRadius
                    var textRadius = (innerRadius + menuRadius) / 2;
                    var textX = centerX + textRadius * Math.cos(angles.center);
                    var textY = centerY + textRadius * Math.sin(angles.center);

                    ctx.fillStyle = "white";
                    ctx.font = "bold 14px Inter, sans-serif";
                    ctx.textAlign = "center";
                    ctx.textBaseline = "middle";
                    ctx.fillText(item.label, textX, textY);
                }

                // رسم دایره داخلی سفید برای ایجاد سوراخ (ایجاد جلوه حلقه)
                ctx.fillStyle = appWindow.color;
                ctx.beginPath();
                ctx.arc(centerX, centerY, innerRadius, 0, 2 * Math.PI);
                ctx.fill();
            }

        }

        // تشخیص کلیک (Hit-Testing)

        // در صورت تغییر وضعیت منو، Canvas باید دوباره رسم شود
        // onMenuOpenChanged: {
        //     menuCanvas.requestPaint();
        // }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        onClicked: (mouse) => {
            var clickX = mouse.x;
            var clickY = mouse.y;

            // تابع کمکی برای بررسی برخورد دایره‌ای (فاصله مرکز تا نقطه کمتر از شعاع باشد)
            function getDistance(x1, y1, x2, y2) {
                return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
            }

            // محاسبه فاصله نقطه کلیک تا مرکز منو
            // var dist = getDistance(menuCanvas.centerX, menuCanvas.centerY, clickX, clickY);

            // اگر کلیک راست باشد (برای باز/بسته کردن منو)
            if (mouse.button === Qt.RightButton) {
                if (!menuOpen) {
                    menuCanvas.x = clickX - menuCanvas.width / 2;
                    menuCanvas.y = clickY - menuCanvas.height / 2;
                }
                menuOpen = !menuOpen;
                menuCanvas.requestPaint();
                // جلوگیری از نمایش منوی کانتکست پیش‌فرض
                mouse.accepted = true;
                return;
            }

            // اگر کلیک چپ باشد و منو باز باشد
            if (menuOpen && mouse.button === Qt.LeftButton) {

                // === اصلاح کلیدی: تبدیل مختصات جهانی به محلی Canvas ===
                var localClickX = clickX - menuCanvas.x;
                var localClickY = clickY - menuCanvas.y;

                // محاسبه فاصله نقطه کلیک تا مرکز محلی Canvas (centerX, centerY)
                var dist = getDistance(menuCanvas.centerX, menuCanvas.centerY, localClickX, localClickY);
                // بررسی کلیک روی قطاع‌ها (اگر کلیک بین innerRadius و menuRadius باشد)
                if (dist >= innerRadius && dist <= menuRadius) {
                    // محاسبه زاویه نقطه کلیک با استفاده از مختصات محلی
                    var angle = Math.atan2(localClickY - menuCanvas.centerY, localClickX - menuCanvas.centerX) * 180 / Math.PI;

                    // تبدیل زاویه به محدوده 0 تا 360 درجه
                    if (angle < 0) angle += 360;

                    // تنظیم زاویه بر اساس نقطه شروع رسم (270 درجه)
                    var adjustedAngle = (angle - 270 + 360) % 360;

                    var itemCount = menuItemsData.length;
                    var angleStep = 360 / itemCount;

                    // تشخیص قطاع
                    var clickedIndex = Math.floor(adjustedAngle / angleStep);

                    if (clickedIndex >= 0 && clickedIndex < itemCount) {
                        console.log("Pie Sector Clicked: " + menuItemsData[clickedIndex].label);
                        menuOpen = false; // بستن منو پس از انتخاب
                        menuCanvas.requestPaint();
                    }
                } else if (dist < innerRadius) {
                    // اگر کلیک در فضای خالی وسط باشد، منو بسته می‌شود
                    menuOpen = false;
                    menuCanvas.requestPaint();
                } else {
                    // اگر کلیک خارج از محدوده منو باشد، منو بسته می‌شود
                    menuOpen = false;
                    menuCanvas.requestPaint();
                }
            }
        }
    }

}


/*import QtQuick
import QtQuick.Controls

// ریشه کامپوننت
ApplicationWindow {
    id: appWindow
    visible: true
    width: 640
    height: 480
    title: "Pie Menu (Animated & Hover)"
    color: "#393939" // رنگ پس‌زمینه تیره

    // متغیرهای وضعیت و تنظیمات
    property bool menuOpen: false
    property real menuRadius: 120 // شعاع بزرگتر برای نمایش قطاع‌ها
    property real innerRadius: 40 // شعاع داخلی برای فضای خالی

    property string colorItem: "#95a5a6"
    property string colorHoverItem: "#7c898a"
    property var menuItemData: ["Home", "Setting", "Profile", "Info", "Exit"]
    // -----------------------------------------------------------

    // ** (A) مدیریت انیمیشن باز و بسته شدن **
    onMenuOpenChanged: {
        if (menuOpen) {
            menuCanvas.menuProgress = 1.0;
        } else {
            menuCanvas.menuProgress = 0.0;
            menuCanvas.hoveredIndex = -1; // ریست کردن هایلایت هنگام بسته شدن
        }
    }

    // کانتینر Canvas برای رسم
    Canvas {
        id: menuCanvas
        width: 300 // فضای کافی برای نمایش منوی با شعاع 120
        height: 300

        // ** (B) متغیرهای انیمیشن و هاور **
        property real menuProgress: 0.0 // 0.0 بسته، 1.0 باز کامل
        property int hoveredIndex: -1 // نگهداری ایندکس قطاعی که ماوس روی آن است

        // ** (C) Behaviors برای اجرای انیمیشن **
        Behavior on menuProgress {
            NumberAnimation {
                duration: 200 // مدت زمان انیمیشن باز و بسته شدن
                // افکت جهشی هنگام باز شدن برای زیبایی
                easing.type: appWindow.menuOpen ? Easing.OutBack : Easing.InQuad
            }
        }

        // هر زمان که menuProgress (انیمیشن) تغییر کند، بازرسم شود
        onMenuProgressChanged: {
            menuCanvas.requestPaint();
        }

        // هر زمان که hoveredIndex (هاور) تغییر کند، بازرسم شود
        onHoveredIndexChanged: {
            menuCanvas.requestPaint(); // بازرسم برای نمایش هایلایت جدید
        }

        // مرکز منو (نقطه مرجع برای رسم) - محلی و ثابت (150, 150)
        property real centerX: width / 2
        property real centerY: height / 2

        // تابع کمکی برای محاسبه زوایای شروع و پایان یک قطاع
        function calculateSectorAngles(index) {
            var itemCount = menuItemData.length;
            var angleStep = 360 / itemCount;

            // شروع از 270 درجه (بالا)
            var startAngle = 270 + (index * angleStep);
            var endAngle = startAngle + angleStep;

            // تبدیل به رادیان
            var startRad = startAngle * Math.PI / 180;
            var endRad = endAngle * Math.PI / 180;

            return { start: startRad, end: endRad, center: (startRad + endRad) / 2 };
        }

        // رندر کردن منو
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            if (menuProgress > 0) { // فقط زمانی رسم شود که منو در حال باز شدن/باز است

                // شعاع‌های متحرک بر اساس پیشرفت انیمیشن
                var currentRadius = menuRadius * menuProgress;
                var currentInnerRadius = innerRadius * menuProgress;

                // شفافیت متحرک
                ctx.globalAlpha = menuProgress;

                // 1. رسم قطاع‌های دایره‌ای (Pie Slices)
                for (var i = 0; i < menuItemData.length; i++) { // استفاده از menuItemData
                    var angles = calculateSectorAngles(i);
                    var label = menuItemData[i]; // دریافت برچسب مستقیماً از آرایه

                    // ** (D) منطق هایلایت: تغییر رنگ و سایه **
                    if (i === hoveredIndex) {
                        // در حالت هاور، از رنگ colorHoverItem استفاده می‌کنیم
                        ctx.fillStyle = colorHoverItem;
                    } else {
                        // حالت عادی، از رنگ colorItem استفاده می‌کنیم
                        ctx.fillStyle = colorItem;
                    }

                    ctx.shadowBlur = 8;
                    ctx.shadowColor = "rgba(0, 0, 0, 0.4)";
                    ctx.beginPath();
                    ctx.moveTo(centerX, centerY);
                    ctx.arc(centerX, centerY, currentRadius, angles.start, angles.end);
                    ctx.lineTo(centerX, centerY);

                    ctx.fill();
                    ctx.shadowBlur = 0; // ریست کردن سایه برای متن

                    // اضافه کردن متن در مرکز قطاع
                    var textRadius = (currentInnerRadius + currentRadius) / 2;
                    var textX = centerX + textRadius * Math.cos(angles.center);
                    var textY = centerY + textRadius * Math.sin(angles.center);

                    ctx.fillStyle = "white";
                    ctx.font = "bold 14px Inter, sans-serif";
                    ctx.textAlign = "center";
                    ctx.textBaseline = "middle";
                    ctx.fillText(label, textX, textY); // استفاده از متغیر label
                }

                // 2. رسم دایره داخلی (خالی)
                // این دایره با رنگ پس‌زمینه پنجره پر می‌شود تا جلوه حلقه ایجاد شود
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
            var dist = getDistance(menuCanvas.centerX, menuCanvas.centerY, localClickX, localClickY);

            // بررسی فاصله (بین شعاع داخلی و شعاع بیرونی)
            if (dist >= innerRadius && dist <= menuRadius) {
                var angle = Math.atan2(localClickY - menuCanvas.centerY, localClickX - menuCanvas.centerX) * 180 / Math.PI;
                if (angle < 0) angle += 360; // 0-360

                // تنظیم زاویه بر اساس شروع 270 درجه (بالا)
                var adjustedAngle = (angle - 270 + 360) % 360;

                var itemCount = menuItemData.length; // استفاده از menuItemData
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
                // انیمیشن و requestPaint توسط onMenuOpenChanged و onMenuProgressChanged مدیریت می‌شود
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
                    console.log("Pie Sector Clicked: " + menuItemData[clickedIndex]); // استفاده از menuItemData
                    menuOpen = false; // بستن منو پس از انتخاب
                    // انیمیشن توسط onMenuOpenChanged مدیریت می‌شود
                } else if (dist < innerRadius) {
                    // اگر کلیک در فضای خالی وسط باشد، منو بسته می‌شود
                    menuOpen = false;
                } else {
                    // اگر کلیک خارج از محدوده منو باشد، منو بسته می‌شود
                    menuOpen = false;
                }
                // نیازی به requestPaint در اینجا نیست
            }
        }
    }
}*/


/*Button{
    id: changePositionPieMenu
    text: "change Absolute Position"
    onClicked: {
        var localX = 300 - menuCanvas.x;
        var localY = 300 - menuCanvas.y;
        pieMenu.absolutePositioinPieMenu(localX, localY);
    }
}

Connections{
    target: pieMenu
    function onAbsolutePosition(x, y){
        // console.log(x, y)
        menuCanvas.x = x
        menuCanvas.y = y
    }
}*/
