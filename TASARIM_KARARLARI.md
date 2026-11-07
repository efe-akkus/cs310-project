# SplitMate - Tasarım Kararları

Grup 31 · Son güncelleme: 7 Kasım 2026

Bu dosya ekip içinde alınan kritik kararları, gerekçelerini ve henüz kesinleşmeyen noktaları takip eder. Kararlaştırılmış davranış, uygulanmış özellik anlamına gelmez. Şu anda Step 2.1 wireframe aşamasındayız; Flutter uygulaması ve Firebase entegrasyonu henüz yapılmadı.

## 1. Kapsam değişikliği: tek cihazdan paylaşılan gruplara

**Karar:** Başlangıçtaki offline, tek cihazlı MVP yerine kişisel hesaplar ve aynı gruba bağlı kullanıcıların ortak kayıtları görebildiği bir uygulama tasarlanacak.

**Gerekçe:** Her kullanıcının kendi profilinin olması ve grup masraflarını kendi hesabından takip edebilmesi istendi.

**Sonuç:** Önceki Step 1 proposal tarihsel belge olarak korunur. Güncel ürün kapsamı bu dosya, README ve Step 2.1 v3 wireframe'lerinde açıklanır. Kullanıcı 7 Kasım 2026 tarihinde TA’nın kapsam değişikliğini onayladığını doğruladı; ekran tasarımlarının son incelemesi ayrıca yapılacak.

## 2. Giriş ve basit profil

**Karar:** Giriş zorunlu; misafir girişi yok. Kayıtta ad-soyad, e-posta ve parola istenir. Profilde ad-soyad, isteğe bağlı fotoğraf ve isteğe bağlı IBAN bulunur. Fotoğraf ve IBAN sonradan eklenebilir, değiştirilebilir veya kaldırılabilir.

**Gerekçe:** Üyelikleri gerçek kullanıcı hesaplarına bağlarken profil kapsamını küçük tutmak.

**Sonuç:** Profil görüntüleme ve düzenleme ayrı ekranlar. Fotoğraf yoksa baş harfler gösterilir. E-posta bu kapsamda salt okunur; kullanıcı yalnızca kendi profilini düzenler.

## 3. Firebase ve geliştirme aşamaları

**Karar:** Planlanan sorumluluklar:

| Bileşen | Sorumluluk |
| --- | --- |
| Firebase Authentication | Kayıt ve giriş hesapları |
| Cloud Firestore | Profiller, gruplar, üyelikler, masraflar, paylar ve ödeme kayıtları |
| Cloud Storage | İsteğe bağlı profil fotoğrafları |
| Provider | Flutter uygulama durumu ve ekranların güncellenmesi |

**Aşama ayrımı:** Step 2.1 ekran tasarımıdır. Step 2.2 örnek veriler, çalışan gezinme ve simüle edilen giriş/kayıt işlemleridir. Gerçek Firebase entegrasyonu Step 3'te yapılacak. Step 1'deki SQLite, güncel kapsamda ana veri kaynağı olarak planlanmıyor; çevrimdışı önbellek davranışı henüz kesinleşmedi.

## 4. Grup oluşturma ve davet

**Karar:** Grup oluşturulurken ad ve para birimi seçilir. Oluşturan kullanıcı ilk üye olur. Diğer kullanıcılar elle yazılmış yerel isimlerle değil, kendi hesaplarıyla davet kodundan katılır.

**Akış:** Grup oluştur → davet kodunu al → kodu uygulama dışında paylaş → diğer kullanıcı kodu girer → grup önizlemesi → katılımı onayla.

**Wireframe önerisi:** Davet kodunu grup sahibi yönetir; sıfırlama eski kodu geçersiz kılar, mevcut üyeleri çıkarmaz. Bu ayrıntılı yetki modeli TA/ekip incelemesine açık.

## 5. Masraflar ve paylaşım

**Karar:** Çekirdek akış masraf ekleme, görüntüleme, düzenleme ve silmeyi kapsar. Her masrafta açıklama, tutar, tarih, bir ödeyen ve seçili grup üyeleri bulunur. İlk sürüm eşit paylaşımı kullanır; grup başına tek para birimi vardır.

**Teknik plan:** Tutarları en küçük para biriminde tam sayı olarak tut; bölüşümde kalan kuruşları tutarlı bir kuralla dağıt. Payların toplamı masraf tutarına eşit olmalı.

**Wireframe önerisi:** Masrafı oluşturan kişi düzenleyebilir/silebilir; diğer üyeler görüntüler. Silme onayı sonrası bakiye yeniden hesaplanır. Kesin yetki modeli uygulamadan önce netleştirilecek.

## 6. Alacak-verecek hesabı

**Karar:** Bakiyeler, masraflar/paylar ve ödeme kayıtlarından hesaplanır. Birbirinden bağımsız elle güncellenen kişisel bakiye kayıtları ana kaynak yapılmaz.

**Gerekçe:** Düzenleme ve silme sonrasında aynı kayıtlarla tutarlı bir hesap elde etmek.

**Örnek:** Efe üç kişi için 300 TL öderse bakiyeler Efe +200, Emir -100, Yunus Emre -100 olur. Emir, Efe'ye 40 TL ödeme kaydı eklediğinde +160, -60, -100 olur. Grup net bakiyeleri toplamı sıfır kalır.

## 7. IBAN ve ödeme kaydı

**Karar:** IBAN isteğe bağlıdır. Genel grup/üye listelerinde gösterilmez; yalnızca aynı grubun üyelerine alıcının ödeme detayında sunulur. IBAN'ı kopyala işlemi vardır; IBAN yoksa bilgilendirme gösterilir ve manuel ödeme kaydı engellenmez.

**Karar:** Uygulama para transferi yapmaz; dışarıda yapılmış ödemenin kaydını tutar. IBAN ekleme ekranında görünürlük açıklanır.

**Wireframe önerisi:** Ödeme gönderen, giriş yapan kullanıcıdır. Tutar pozitif, alıcı farklı ve tutar önerilen kalan ödemeyi aşmayacak şekilde sınırlandırılır. IBAN görüntüsü belgede temsili/maskelidir; gerçek kullanıcı banka bilgisi içermez.

## 8. Erişim ve hata durumları

**Karar:** Kullanıcı sadece üyesi olduğu grupların kayıtlarını görmeli. Profil değişiklikleri profil sahibiyle sınırlı olmalı. Firebase aşamasında bu kurallar sunucu tarafında da uygulanmalı; yalnızca buton gizlemek yeterli değildir.

**Tasarım davranışı:** Formlarda alan içi hatalar, geçerli gönderimde özet/onay, silmede onay, boş listelerde yönlendirici eylem ve başarısız işlemlerde yeniden deneme bulunacak. Kaydetme tamamlanmadan başarı gösterilmeyecek. Fotoğraf yükleme başarısızsa baş harflerle devam edilebilecek.

## 9. Ekran seti ve görsel tasarım

**Karar:** Güncel wireframe v3, 10 ana ekranı kapsar: giriş, kayıt, gruplarım, grup oluşturma, grup özeti, masraf ekle/düzenle, bakiyeler, üyeler, profil ve gruba katılma. Masraf detayı, ödeme kaydı, profil düzenleme ve davet kodu ilgili ekranların üzerinde açılan panellerdir.

**Durum:** 10 sayfalık İngilizce pre-submission taslak hazır. Beyaz zemin, koyu yeşil vurgu ve sade yerleşim kullanılıyor. 10 ana ekrana ek olarak dört panel çizimi ve hata/onay örnekleri mevcut. Son PDF incelemesi bekleniyor; UI uygulaması öncesinde ekranlar için TA geri bildirimi alınacak.

## 10. Kapsam dışında / ertelenenler

- Banka entegrasyonu ve uygulama içinden para transferi.
- Ayrıntılı sosyal profil, mesajlaşma ve sosyal akış.
- İlk sürümde para birimi dönüşümü.
- Eşit olmayan paylaşım, kategoriler, arama/filtreleme, CSV ve dark mode: çekirdek akıştan sonra değerlendirilecek opsiyonlar.

## 11. Step 2 koordinasyonu

**Karar (5 Kasım 2026):** Step 2 koordinatörü Yunus Emre Yolal (31294). Toplantıların düzenlenmesi, görev dağılımının koordinasyonu ve atanmış TA ile iletişim onun sorumluluğunda. Her üye kendi katkılarını kendi GitHub hesabından yapmaya devam edecek.

## Takip listesi

- [x] Step 2 koordinatörü: Yunus Emre Yolal (31294). Step 1 koordinatörü Efe idi.
- [x] Güncel kapsam için TA onayı alındı (kullanıcı teyidi: 7 Kasım 2026).
- [ ] Ekran tasarımlarını TA ile incele; geri bildirimi kaydet.
- [ ] Masraf düzenleme/silme, ödeme düzeltme, gruptan ayrılma/üye çıkarma ve davet yetkilerini kesinleştir.
- [ ] IBAN'ın para birimiyle uyumu ve desteklenen ülkeleri netleştir.
- [ ] Görsel tasarımın renk, font ve bileşenlerini seç.
- [ ] Ekip GitHub erişimlerini yeniden kontrol et; herkesin kendi hesabıyla anlamlı commit yapmasını sağla.
- [ ] Step 2.1 PDF'sini 8 Kasım 2026, 23:59'a kadar SUCourse'a teslim et.
- [ ] TA geri bildirimi sonrası Flutter UI'ı geliştir; Step 2.2'yi 20 Kasım 2026, 23:59'a kadar teslim et.

## İlgili belgeler

- [Güncel wireframe PDF](docs/CS310_Group31_Step2.1.pdf)
- [Ekran açıklamaları ve akışlar](docs/SplitMate_Step2.1_Screen_Specification.md)
- [Step 1 proposal - tarihsel kapsam](docs/CS310_SplitMate_Group31_Step1_Proposal.pdf)
