import java.util.Properties

// Dados da chave de assinatura (arquivo android/key.properties, que não vai
// para o git). Sem esse arquivo, a versão final usa a chave de teste, só para
// `flutter run --release` funcionar. A Play Store NÃO aceita essa chave de teste.
val chaveProps = Properties()
val chaveArquivo = rootProject.file("key.properties")
if (chaveArquivo.exists()) {
    chaveArquivo.inputStream().use { chaveProps.load(it) }
}

// O .aab da Play Store (tarefa bundleRelease) nunca pode sair com a chave de
// teste: sem key.properties ou sem o arquivo da chave, o build para aqui.
val gerandoAab = gradle.startParameter.taskNames.any {
    it.contains("bundle", ignoreCase = true) && it.contains("release", ignoreCase = true)
}
if (gerandoAab) {
    if (!chaveArquivo.exists()) {
        throw GradleException(
            "Falta android/key.properties: o .aab sairia assinado com a chave de teste."
        )
    }
    val arquivoDaChave = chaveProps.getProperty("storeFile")?.let { file(it) }
    if (arquivoDaChave == null || !arquivoDaChave.exists()) {
        throw GradleException(
            "A chave indicada em storeFile (key.properties) não foi encontrada: $arquivoDaChave"
        )
    }
}

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "br.com.setealegrias.sete_alegrias_de_maria"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Necessário para flutter_local_notifications (lembretes).
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // Identificador na Play Store: NÃO mude depois de publicado.
        applicationId = "br.com.setealegrias.sete_alegrias_de_maria"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (chaveArquivo.exists()) {
                keyAlias = chaveProps.getProperty("keyAlias")
                keyPassword = chaveProps.getProperty("keyPassword")
                storeFile = file(chaveProps.getProperty("storeFile"))
                storePassword = chaveProps.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (chaveArquivo.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
