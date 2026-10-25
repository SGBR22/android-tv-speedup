# ⚡ Android TV Speedup & Ultra-Minimal Setup

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android%20TV%20%7C%20Google%20TV-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Platform" />
  <img src="https://img.shields.io/badge/Tested%20On-Android%209%20--%2014-007ACC?style=for-the-badge&logo=android&logoColor=white" alt="Android Version" />
  <img src="https://img.shields.io/badge/Shell-PowerShell%205.1%2B-5391FE?style=for-the-badge&logo=powershell&logoColor=white" alt="Shell" />
  <img src="https://img.shields.io/badge/License-MIT-brightgreen?style=for-the-badge" alt="License" />
</p>

<p align="center">
  <b>Универсальный инструмент глубокой оптимизации, ускорения запуска приложений и очистки оперативной памяти для Android TV и Google TV.</b><br>
  <b>Universal toolkit for deep optimization, app launch speedup, and RAM reclamation on Android TV and Google TV devices.</b>
</p>

---

<p align="center">
  <a href="#-русская-версия">🇷🇺 <b>Русская версия</b></a> | 
  <a href="#-english-version">🇬🇧 <b>English Version</b></a>
</p>

---

## 🇷🇺 Русская версия

### 📖 О проекте
Большинство телевизоров и ТВ-приставок (Xiaomi Mi TV, TCL, Sony, Realme, Haier, Яндекс ТВ и ноунейм Android-боксы) оснащены слабыми процессорами (Cortex-A53) и всего **1–2 ГБ оперативной памяти**. 

Со временем они начинают мучительно тормозить по трем фундаментальным причинам:
1. **Перегруженный стоковый лаунчер** (Google TV LauncherX или PatchWall): непрерывно подгружает в фоне рекламные видеоролики, трейлеры и рекомендации, отъедая до **400 МБ ОЗУ**.
2. **Переполнение файла подкачки ZRAM и буксование памяти (Memory Thrashing)**: виртуальная память ZRAM забивается до 100%, вынуждая ядро Linux непрерывно сбрасывать системные страницы на медленный eMMC-накопитель при каждом запуске приложений.
3. **Отсутствие AOT-компиляции (Ahead-Of-Time)**: официальные приложения (YouTube, видеоплееры, медиасервисы) запускаются через медленный JIT-интерпретатор, заставляя 4 слабых ядра процессора пыхтеть над компиляцией байт-кода на лету.

Данный проект решает эти проблемы **аппаратно и системно**, не нарушая оригинальность приложений.

---

### ✨ Ключевые возможности

* 🖥️ **Ультраминималистичный лаунчер [Luncher](https://github.com/CVasilakis/luncher) (194 КБ):**
  * На экране **ТОЛЬКО аккуратная сетка ваших приложений и значок Настроек**.
  * Нулевая реклама, отсутствие лишних рядов и рекомендаций.
  * Потребляет всего **~12 МБ ОЗУ** (в 30 раз легче стока) и работает полностью офлайн (в манифесте даже нет разрешения на Интернет).
* ⚡ **Аппаратная AOT-компиляция в машинный код (`speed`):**
  * Принудительно компилирует YouTube, системный WebView и медиаприложения напрямую в бинарные инструкции процессора (`cmd package compile -m speed`).
  * Приложения распахиваются в 2–3 раза быстрее без подвисаний и дропов кадров.
* 🛡️ **Укрощение фоновых пожирателей ОЗУ через AppOps:**
  * Запрещает Google Play Маркету и фоновым трекерам будить процессор во время просмотра видео (`RUN_IN_BACKGROUND ignore`, `WAKE_LOCK ignore`).
* 🧹 **Безопасный деблоат без риска окирпичивания:**
  * Замораживает рекламные каналы, телеметрию вендоров и китайский PatchWall без безвозвратного удаления (`pm disable-user --user 0`).
* 🚀 **Мгновенные анимации (0.0x scale):**
  * Полное отключение задержек отрисовки окон — мгновенный отклик на пульт.
* 🔄 **Мгновенный откат в 1 клик:**
  * Возможность вернуть все заводские настройки и стоковый лаунчер за 5 секунд.

---

### 📋 Требования
* Телевизор или ТВ-приставка на базе **Android TV 9.0 – 14.0** (или Google TV).
* Компьютер с **Windows 10 / 11** и PowerShell 5.1+ (или PowerShell 7+).
* Телевизор и компьютер подключены к **одной домашней сети Wi-Fi** (или кабелем к одному роутеру).

---

### 🚀 Пошаговая инструкция по установке

#### Шаг 1. Включение отладки по USB на телевизоре
1. На пульте телевизора откройте **Настройки (Шестерёнка)** $\to$ **Настройки устройства** (Device Preferences) $\to$ **Об устройстве** (About).
2. Пролистайте в самый низ до пункта **«Сборка»** (Build) и нажмите центральную кнопку **`OK` на пульте 7 раз подряд** (появится надпись: *«Вы стали разработчиком!»*).
3. Нажмите кнопку «Назад» $\to$ в самом низу меню откройте появившийся пункт **«Для разработчиков»** (Developer Options).
4. Найдите и включите тумблер **«Отладка по USB»** (USB Debugging).
   > *Примечание для Xiaomi Mi TV:* включение отладки по USB на телевизорах автоматически открывает отладку по локальной сети по порту `5555`. Никаких проводов не требуется!

#### Шаг 2. Узнайте IP-адрес телевизора
* Откройте **Настройки** $\to$ **Сеть и интернет** $\to$ выберите вашу сеть Wi-Fi $\to$ посмотрите строку **IP-адрес** (например, `192.168.1.150`).

#### Шаг 3. Запуск оптимизации на ПК
1. Склонируйте репозиторий или скачайте его архивом:
   ```powershell
   git clone https://github.com/SGBR22/android-tv-speedup.git
   cd android-tv-speedup
   ```
2. Запустите скрипт первичной подготовки (он сам скачает портативный Google ADB и лаунчер):
   ```powershell
   .\bootstrap.ps1
   ```
3. Запустите интерактивное главное меню:
   ```powershell
   .\tune-tv.ps1
   ```
4. Выберите **пункт [1] (Full Speedup)**:
   * Скрипт попросит ввести IP-адрес телевизора.
   * **Посмотрите на экран ТВ:** появится диалоговое окно *«Разрешить отладку по USB?»*. Обязательно отметьте пультом галочку **«Всегда разрешать с этого компьютера»** и нажмите **ОК**.
   * Инструмент в автоматическом режиме установит Luncher, скомпилирует ключевые приложения в машинный код, отключит мусор и освободит до **400 МБ оперативной памяти**.

---

### 💡 Рекомендуемый финальный штрих на ТВ
Чтобы система Android никогда больше не накапливала старые фоновые задачи:
1. Зайдите на ТВ в **Настройки** $\to$ **Для разработчиков** $\to$ раздел «Приложения».
2. Найдите пункт **«Лимит фоновых процессов»** (Background process limit) и выставьте **«Не более 1 процесса»** (или 2).

---

<br>

---

## 🇬🇧 English Version

### 📖 Overview
Most Smart TVs and TV boxes (Xiaomi Mi TV, TCL, Sony, Realme, Haier, Chromecast with Google TV, and generic TV boxes) run on low-power quad-core processors (ARM Cortex-A53) with only **1 GB to 2 GB of RAM**.

Over time, they suffer from severe slowdowns, UI freezes, and stuttering caused by three major bottlenecks:
1. **Bloated Stock Launchers** (Google TV LauncherX or OEM shells like PatchWall): Continuously stream video ads, trailers, and telemetry in the background, consuming up to **400 MB of RAM**.
2. **Virtual Memory Thrashing (ZRAM Saturation)**: The kernel's compressed ZRAM swap space becomes 100% full (often leaving less than 20 KB free). This forces the Linux kernel into continuous synchronous page reclamation against slow eMMC flash storage whenever an app is opened.
3. **Lack of Ahead-Of-Time (AOT) Compilation**: Official media apps (YouTube, system WebView, streaming clients) run through slow JIT compilation, overloading the weak CPU at launch time.

This project delivers **system-level hardware optimization** that frees up critical memory and maximizes performance while keeping all your apps **100% original and official**.

---

### ✨ Features

* 🖥️ **Ultra-Minimal [Luncher](https://github.com/CVasilakis/luncher) (194 KB):**
  * Pure, clean application grid and settings icon on a clean dark background.
  * Zero ads, zero video carousels, zero recommendations.
  * Extremely low memory footprint (**~12 MB RAM**, 30x lighter than stock). Completely offline by design (manifest requires no Internet permission).
* ⚡ **Hardware AOT Machine Code Compilation (`speed`):**
  * Forces Ahead-Of-Time compilation of YouTube, Android System WebView, and media apps directly into native CPU machine code (`cmd package compile -m speed`).
  * Instant launch speeds without frame drops.
* 🛡️ **AppOps Background Throttling:**
  * Restricts Google Play Store and background trackers from waking the CPU during video playback (`RUN_IN_BACKGROUND ignore`, `WAKE_LOCK ignore`).
* 🧹 **Non-Destructive Safe Debloat:**
  * Freezes vendor bloatware, ad recommendation services, and OEM carousels without deleting system files (`pm disable-user --user 0`).
* 🚀 **Instant UI Animations (0.0x scale):**
  * Eliminates artificial window transition delays for snappy remote control response.
* 🔄 **One-Click Factory Rollback:**
  * Fully reversible: restore all stock launchers and factory settings anytime.

---

### 📋 Prerequisites
* TV or Streaming Box running **Android TV 9.0 – 14.0** (or Google TV).
* PC with **Windows 10 / 11** and PowerShell 5.1+ (or PowerShell 7+).
* Both TV and PC connected to the **same local Wi-Fi / Ethernet network**.

---

### 🚀 Quick Start Guide

#### Step 1. Enable USB Debugging on your TV
1. On your TV remote, go to **Settings (Gear icon)** $\to$ **Device Preferences** $\to$ **About**.
2. Scroll down to **Build** and press the **`OK` button on your remote 7 times** until you see *"You are now a developer!"*.
3. Go back one level $\to$ open the newly visible **Developer Options** menu.
4. Toggle **USB Debugging** to **ON**.
   > *Note for Xiaomi TVs:* Toggling USB Debugging automatically enables network ADB on port `5555`. No physical USB cables are required.

#### Step 2. Find your TV's IP Address
* Open **Settings** $\to$ **Network & Internet** $\to$ select your active Wi-Fi connection $\to$ note down the **IP address** (e.g., `192.168.1.150`).

#### Step 3. Run Optimization from PC
1. Clone or download this repository:
   ```powershell
   git clone https://github.com/SGBR22/android-tv-speedup.git
   cd android-tv-speedup
   ```
2. Initialize the environment (downloads portable Google ADB and Luncher automatically):
   ```powershell
   .\bootstrap.ps1
   ```
3. Launch the master interactive CLI:
   ```powershell
   .\tune-tv.ps1
   ```
4. Choose **Option [1] (Full Speedup)**:
   * Enter your TV's IP address when prompted.
   * **Look at your TV screen:** An *"Allow USB debugging?"* prompt will appear. Check **"Always allow from this computer"** and select **OK**.
   * The toolkit will automatically install Luncher, compile apps to native code, disable background bloatware, and reclaim up to **400 MB of RAM**.

---

### 💡 Recommended Final Setting on TV
To keep Android from accumulating dormant background tasks:
1. Navigate to **Settings** $\to$ **Developer Options** $\to$ **Apps** section.
2. Select **Background process limit** $\to$ choose **"At most 1 process"** (or 2 processes).

---

### 📂 Repository Structure

```text
android-tv-speedup/
├── .gitignore               # Strict exclusion of binaries, APKs and dumps
├── LICENSE                  # MIT License
├── README.md                # Bilingual documentation (RU / EN)
├── bootstrap.ps1            # Auto-downloader for Google ADB and Luncher APK
├── tune-tv.ps1              # Master interactive CLI utility
└── scripts/
    ├── 1_connect.ps1        # Network ADB connection assistant
    ├── 2_install_launcher.ps1# Deploys ultra-minimal Luncher & sets default home
    ├── 3_aot_compile.ps1    # Ahead-Of-Time (AOT) machine code compilation
    ├── 4_debloat.ps1        # Safe profile-based bloatware freezer
    ├── 5_optimize_memory.ps1# 0.0x animations, AppOps restrictions & ZRAM flush
    └── 6_restore_stock.ps1  # Complete factory rollback in 1 click
```

---

### 📄 License
This project is open-source software licensed under the [MIT License](LICENSE).
