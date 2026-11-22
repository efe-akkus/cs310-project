# SplitMate - Step 2.2 ekran paylaşımı

22 Kasım 2026 · Koordinatör: Yunus Emre Yolal (31294)

## Bu tablo neyi gösteriyor?

Aşağıdaki paylaşım bundan sonraki düzenleme, test ve açıklama sorumluluğudur. Henüz yapılmamış işleri tamamlanmış katkı olarak göstermez. Başlangıç UI, Efe'nin talebiyle Codex yardımıyla hazırlanmıştır. Emir'in önceki katkısı Flutter başlangıç projesi; Yunus'un rolü Step 2 koordinasyonudur. Teslim raporunun Member Contributions bölümü, herkes kendi düzenlemelerini yaptıktan sonra gerçek commit ve işlere göre tamamlanacak.

## Efe Çağan Akkuş - 32413

**Ekranlar:** Giriş, kayıt, profil. **Panel:** Profil düzenleme. **Ortak alan:** Tema ve bileşenler.

Dosyalar: `lib/screens/auth_screens.dart`, `lib/screens/profile_screen.dart`, `lib/theme/app_theme.dart`, `lib/widgets/common.dart`.

- [ ] Giriş/kayıt metinleri ve hata mesajlarını gözden geçir; geçersiz e-posta ve kısa parola dene.
- [ ] Profil düzenle: ad, isteğe bağlı fotoğraf URL'si ve IBAN doğrulamasını test et.
- [ ] Dark theme'i ve klavye açıkken küçük ekranı kontrol et.
- [ ] Kendi hesabından anlamlı değişiklikleri commit et; yaptığı işi toplantıda açıklayabil.

## Emir Keskin - 31020

**Ekranlar:** Gruplarım, grup oluşturma, gruba katılma, üyeler. **Panel:** Davet kodu.

Dosyalar: `lib/screens/groups_screen.dart`, `lib/screens/create_group_screen.dart`, `lib/screens/join_group_screen.dart`, `lib/screens/invite_sheet.dart`; üyeler görünümü: `lib/screens/group_members_view.dart`.

- [ ] Grup oluştur; para birimini ve boş isim doğrulamasını kontrol et.
- [ ] `TRIP-7K2M` ile katılımı, geçersiz kodu ve tekrar katılımı dene.
- [ ] Davet kopyalama/sıfırlama ve üye listesini incele; favori grubun yukarı geldiğini kontrol et.
- [ ] Gerçek düzenlemeleri kendi hesabından commit et; Flutter başlangıç kurulumunu da katkısında belirt.

## Yunus Emre Yolal - 31294

**Ekranlar:** Grup özeti/masraf geçmişi, masraf ekle-düzenle, bakiyeler. **Paneller:** Masraf detayı, ödeme kaydı, haritadan konum seçimi.

Dosyalar: `lib/screens/group_screen.dart`, `lib/screens/expense_screens.dart`, `lib/screens/location_sheet.dart`. Üyeler görünümü Emir’in `group_members_view.dart` dosyasındadır. Hesaplama ve durum modeli: `lib/models/ledger.dart`, `lib/state/app_state.dart` (ortak değişiklikleri ekiple koordine et).

- [ ] Masraf ekle, düzenle ve sil; yetkisiz düzenleme/silme olmadığını kontrol et.
- [ ] Eşit paylaşımda kuruş kalanı ve seçili üyeleri test et.
- [ ] Ödeme kaydı ve kalan borç kontrolünü dene; haritada nokta seçip masrafa ekle.
- [ ] Gerçek düzenlemeleri kendi hesabından commit et; son sürüm, ekran görüntüleri ve raporu koordine et.

## Ortak teslim kontrolü

- Herkes aynı commit'ten güncel çalışmaya başlamalı; başka üyelerin değişikliklerinin üzerine yazılmamalı.
- Kod önce `flutter analyze` ve `flutter test` ile kontrol edilmeli.
- `flutter run` ile Android emülatörü veya iOS simülatöründe denenmeli.
- Testte örnek hesap kullanılır: `efe.akkus@sabanciuniv.edu` + en az 8 karakterli herhangi bir parola. Bu gerçek kimlik doğrulama değildir.
- Örnek borçlu hesap: `yunus@example.com`; aynı parola kuralıyla demo giriş yapılabilir.
- Gerçek Firebase, çapraz cihaz paylaşımı ve OCR bu aşamada uygulanmış sayılmamalı.
- Son düzenlemelerden sonra ekran görüntüleri ve teslim commit ID'si yenilenmeli.
- Son rapor, planlanan görevlere değil gerçekten yapılan katkılara dayanmalı.
