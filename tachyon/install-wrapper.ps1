$gradleVersion = "8.8"
$baseUrl = "https://raw.githubusercontent.com/gradle/gradle/v$gradleVersion.0"

Write-Host "Lade Gradle Wrapper (v$gradleVersion) herunter..." -ForegroundColor Cyan

# Verzeichnisse anlegen
$wrapperDir = "gradle\wrapper"
New-Item -ItemType Directory -Force -Path $wrapperDir | Out-Null

# Dateien herunterladen
Invoke-WebRequest -Uri "$baseUrl/gradlew.bat" -OutFile "gradlew.bat"
Invoke-WebRequest -Uri "$baseUrl/gradlew" -OutFile "gradlew"
Invoke-WebRequest -Uri "$baseUrl/gradle/wrapper/gradle-wrapper.jar" -OutFile "$wrapperDir\gradle-wrapper.jar"

# Properties Datei manuell erstellen, um sicherzugehen, dass die URL exakt passt
$propertiesContent = @"
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-$gradleVersion-bin.zip
networkTimeout=10000
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
"@

Set-Content -Path "$wrapperDir\gradle-wrapper.properties" -Value $propertiesContent

Write-Host "Gradle Wrapper erfolgreich installiert." -ForegroundColor Green
