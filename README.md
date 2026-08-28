# Sandık Düştü

Renkleri eşleştirerek düşen sandıkları yakalama oyunu. Oyun, portre ekranlı Android cihazlar için Godot 4.7 ile geliştirilmiştir.

## Oynanış

Üstten düşen küçük sandığın rengini, alttaki büyük sandıklardan seçin ve ilgili üçgene dokunarak sandığı yakalayın.

- **Kolay:** 3 renkli sandık düzeni, düşüş hızı `200`.
- **Orta:** 6 renkli sandık düzeni, düşüş hızı `150`.
- **Zor:** 9 renkli sandık düzeni, düşüş hızı `100`.

Yanlış seçimler veya bariyeri geçen sandıklar hata sayılır. Seviye hedefini, izin verilen hata sayısını aşmadan tamamlayın.

## Özellikler

- 50 veri odaklı kısa seviye.
- Kilidi sırayla açılan seviyeler ve yerel en iyi skorlar.
- Başarımlar, en yüksek seri ve toplam yakalanan sandık istatistikleri.
- Cihaz tarihine dayalı, çevrimdışı günlük görevler.
- İlk kullanım öğreticisi.
- Kozmetik arka plan temaları ve titreşim tercihi.
- Android güvenli alanına uyarlanan oyun alanı.
- Yerel gizlilik bölümü ve oyun verilerini sıfırlama seçeneği.

## Gereksinimler

- Godot `4.7`
- Android cihazda denemek için Android SDK, OpenJDK 17 ve USB hata ayıklama

## Çalıştırma

1. Depoyu klonlayın veya Godot Project Manager’dan içe aktarın.
2. `project.godot` dosyasını Godot 4.7 ile açın.
3. Projeyi çalıştırın.

Android cihaz testi için Godot **Editor Settings → Export → Android** alanında Java ve Android SDK yollarını tanımlayın. Ardından **Project → Export → Android** üzerinden debug paketiyle cihazda çalıştırın.

## Gizlilik

Oyun; rekor, seviye ilerlemesi, başarımlar, günlük görevler ve tercihleri yalnızca cihazda saklar. Reklam, analitik ve çevrimiçi hesap sistemi içermez.

Güncel politika: [Sandık Düştü Gizlilik Politikası](https://ttaskesen.github.io/SandikDustu/PRIVACY_POLICY.html)

İletişim: tgrttaskesen@gmail.com

## Yayın durumu

Bu depo kaynak kodunu içerir; içinde yayınlanabilir APK veya AAB bulunmaz. Google Play yayını öncesinde aşağıdakiler tamamlanmalıdır:

- API hedefi gereksiniminin güncel Play politikasıyla doğrulanması.
- Gradle ile imzalı release AAB oluşturulması.
- Keystore’un geliştirici tarafından güvenli saklanması.
- Play Console mağaza listesi, Data safety formu, içerik derecelendirmesi ve gerçek cihaz testleri.

## Proje yapısı

- `levels/level.tscn`: Ana menü ve oyun sahnesi.
- `scripts/oyun/oyun_yoneticisi.gd`: Düşen sandıklar, skor, geri bildirim ve oyun akışı.
- `scripts/seviye_veritabani.gd`: 50 seviyenin veri odaklı tanımları.
- `scripts/global.gd`: Yerel kayıt, günlük görev, başarımlar ve temalar.
- `assets/`: Sandık, üçgen, bariyer, simge ve ses varlıkları.

## Lisans

Bu depo için açık kaynak lisansı henüz tanımlanmamıştır. Kod ve görselleri kullanmak veya dağıtmak için geliştiriciden izin alınmalıdır.
