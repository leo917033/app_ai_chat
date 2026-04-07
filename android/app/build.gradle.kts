plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    compileSdk = 36

    namespace = "com.example.yolo_text"
    // ndkVersion = flutter.ndkVersion // 如果您沒有特別使用 NDK，可以先註解掉
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.yolo_text"

        // ✅ 2. 移除 Flutter 動態設定，改為手動指定
        minSdk = 24
        targetSdk = 34

        // 讓 versionCode 和 versionName 繼續由 Flutter 管理，這通常是比較好的做法
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")

            // ✅ 3. 修正 Kotlin DSL 的語法
            isMinifyEnabled = true
            isShrinkResources = true

            // 使用函式呼叫並用雙引號表示字串
            setProguardFiles(listOf(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            ))
        }
    }
}

flutter {
    source = "../.."
}

// ✅ 4. 新增 dependencies 區塊 (如果您的檔案裡沒有的話)
dependencies {
    implementation(kotlin("stdlib-jdk7"))
}
