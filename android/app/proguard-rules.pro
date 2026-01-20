
# Flutter's default rules. You might have some of these already.
# - A list of classes that should not be stripped by Proguard.
# ...

# ultralytics_yolo 套件需要的規則
# 保留 TensorFlow Lite 相關類別
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# 保留 Ultralytics 相關類別
-keep class com.ultralytics.** { *; }

# 解決由 snakeyaml 套件引起的 java.beans 缺失錯誤
# 保留 snakeyaml 本身
-keep class org.yaml.snakeyaml.** { *; }
# 告訴 R8 忽略找不到 java.beans.* 的警告 (這是解決問題的關鍵)
-dontwarn java.beans.**
