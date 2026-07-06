# GitHub Actions ile Telefondan APK Derleme

Bilgisayara hiç ihtiyaç duymadan, sadece telefon tarayıcın veya GitHub
uygulamasıyla APK üretme rehberi.

## 1. GitHub Hesabı Aç (yoksa)
https://github.com adresine git, ücretsiz hesap oluştur.

## 2. Yeni Bir Depo (Repository) Oluştur
1. GitHub'da sağ üstteki **"+"** → **"New repository"**
2. İsim ver: `scooter-bul` gibi
3. **Public** veya **Private** seç (ikisi de ücretsiz Actions için çalışır)
4. **Create repository**

## 3. Proje Dosyalarını Yükle
Telefonundan yapmanın en kolay yolu:
1. Oluşturduğun depo sayfasında **"Add file" → "Upload files"**
2. `scooter_app` klasöründeki tüm dosyaları (bu workflow dosyası dahil,
   klasör yapısı korunacak şekilde) sürükleyip bırak veya seç
3. Alt kısımda **"Commit changes"**

**Önemli:** Klasör yapısının bozulmaması lazım — özellikle
`.github/workflows/build-apk.yml` dosyasının tam olarak bu yolda
kalması gerekiyor, yoksa GitHub bunu otomatik olarak tanımaz. Eğer
telefondan toplu klasör yüklemek zor gelirse, GitHub'ın mobil
uygulamasını kullanmak yerine bir bilgisayar/kütüphane/internet
kafesinden tek seferlik bir yükleme yapıp sonrasında her şeyi
telefondan yönetmen daha pratik olabilir.

## 4. Derlemenin Otomatik Başlamasını Bekle
Dosyaları yükleyip commit ettiğin an, GitHub otomatik olarak workflow'u
tetikler. Kontrol etmek için:
1. Depo sayfasında üstteki **"Actions"** sekmesine gir
2. **"APK Derle"** adlı çalışan/tamamlanmış bir işlem göreceksin
3. Sarı nokta = devam ediyor, yeşil tik = başarılı, kırmızı çarpı = hata

Derleme genelde **5-10 dakika** sürer (ilk seferinde biraz daha uzun
olabilir çünkü Flutter SDK'yı sıfırdan indiriyor).

## 5. APK'yı İndir
1. Yeşil tik ile tamamlanan işlemin üzerine dokun
2. Sayfanın en altında **"Artifacts"** bölümünde **"scooter-bul-apk"**
   göreceksin
3. Ona dokunup indir — bu bir zip dosyası olarak gelir, içinde
   `app-release.apk` var
4. Zip'i açıp APK'yı telefonuna kur (Ayarlar'da "bilinmeyen
   kaynaklardan yükleme" izni gerekebilir)

## Bir Şeyler Ters Giderse
"Actions" sekmesinde kırmızı çarpı görürsen, üzerine dokunup hata
logunu (kırmızı yazılı kısmı) bana buraya yapıştır — birlikte çözeriz.
En sık karşılaşılan sorunlar genelde `pubspec.yaml` içindeki paket
sürümleriyle ilgili oluyor, kolayca düzeltilebilir.

## Bundan Sonrası
Koda her değişiklik yapıp GitHub'a yeni bir "commit" gönderdiğinde,
APK otomatik olarak yeniden derlenir — yani her güncellemede tekrar
bu adımları baştan yapmana gerek yok, sadece Actions sekmesinden yeni
APK'yı indirmen yeterli.
