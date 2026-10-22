# TASKS — Görsel/Ses/Yoğunluk Revizyonu (Architect Review v2)

> Cursor: Bu dosyadaki görevleri sırayla uygula. Her görev ayrı commit,
> hepsi tek PR (`feat/sfx-and-density`). BOOTSTRAP kuralları geçerli.

## ÖN KOŞUL — Bayat build tespiti

Kullanıcının emülatöründeki build ESKİ: ekran görüntüsünde kare tile'lar var,
oysa main'deki `BoardPainter` nokta ızgarası + slither animasyonu içeriyor.
İlk iş: `flutter clean && flutter run` ile emülatöre güncel build'i kur,
mevcut görünümün ekran görüntüsünü `docs/screenshots/current.png` olarak kaydet.
Sonraki görsel kararlar bu güncel görüntü üzerinden verilecek.

## GÖREV 1 — Prosedürel SFX entegrasyonu

`assets/audio/` klasörüne kullanıcının vereceği 4 dosyayı koy:
`hiss.wav`, `slither.wav`, `tap.wav`, `win.wav`
(Prosedürel sentezlendi — lisans yok, `docs/LICENSES.md`'ye "in-house procedural,
CC0" olarak işle. BACKLOG'daki "lisanslı tıslama SFX" maddesini kapat.)

`pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/audio/
```

`lib/core/audio/sound_controller.dart` — SystemSound stand-in'lerini kaldır,
`audioplayers` (zaten bağımlılıkta) ile değiştir. Düşük gecikme için `AudioPool`:

```dart
import 'package:audioplayers/audioplayers.dart';

enum SoundEffect { tap, escape, hiss, win }

class SoundController {
  SoundController({required this.isEnabled});

  final bool Function() isEnabled;
  final Map<SoundEffect, AudioPool> _pools = {};

  static const _files = {
    SoundEffect.tap: 'audio/tap.wav',
    SoundEffect.escape: 'audio/slither.wav',
    SoundEffect.hiss: 'audio/hiss.wav',
    SoundEffect.win: 'audio/win.wav',
  };

  Future<void> init() async {
    for (final e in SoundEffect.values) {
      _pools[e] = await AudioPool.createFromAsset(
        path: _files[e]!,
        maxPlayers: e == SoundEffect.tap ? 3 : 2,
      );
    }
  }

  Future<void> play(SoundEffect effect) async {
    if (!isEnabled()) return;
    await _pools[effect]?.start();
  }

  Future<void> dispose() async {
    for (final p in _pools.values) {
      await p.dispose();
    }
  }
}
```

Entegrasyon noktaları:
- `init()` uygulama açılışında (provider init), test ortamında atla
  (mevcut platform-guard yaklaşımını koru).
- Çarpışmada (`FireOutcome.collided`) → `hiss` (zaten bağlıysa dosya değişimi yeter).
- Slither animasyonu BAŞLARKEN → `escape` (slither.wav) çal; animasyon bitişinde değil.
- Ses ayarı (settings) mevcut `isEnabled` üzerinden çalışmaya devam etmeli.

## GÖREV 2 — Yoğunluk/iç-içelik ayarı (referans hissi)

Kullanıcı geri bildirimi: referans oyunda yollar daha uzun, daha iç içe.
`difficulty.dart` profillerini şöyle güncelle:

| Profil | size | snakeCount | minLen | maxLen | maxOpenRatio |
|---|---|---|---|---|---|
| easy | 6 | 6 | 2 | 5 | 0.50 |
| medium | 8 | 11 | 3 | 8 | 0.40 |
| hard | 10 | 16 | 3 | 12 | 0.32 |

Notlar:
- Doluluk hedefi: medium ~%75+, hard ~%85+ hücre dolu olmalı — üreteç
  `snakeCount`'a ulaşamıyorsa (break) sorun değil, ama 40 seed'lik örneklemde
  ortalama doluluk bu bandın altındaysa `maxAttempts`'i artır.
- `maxOpenRatio` düşüşü "başta çok fazla serbest atış" hissini azaltır → iç içelik artar.
- Property testini yeniden çalıştır (1000 seed × 3 profil) — profil değişince
  üretilen seviyeler tamamen değişir, determinizm seed+profile bağlı olduğu için
  mevcut oyuncu ilerlemesi (seviye indeksi) etkilenmez.
- 10×10 hard'da painter performansını kontrol et: tek CustomPainter'da
  16 yılan × 26 stroke adımı ≈ 416 drawLine/frame — sorun beklenmez ama
  emülatörde 60fps doğrula; takılırsa `steps`'i uzunluğa oranla ölçekle
  (`steps = 8 + 3*snake.length` gibi).

## GÖREV 3 — Baş/görsel mikro-cila

Güncel build görüntüsüne göre değerlendir (ÖN KOŞUL'daki screenshot):
- Başta gözler yoksa ekle: kama başın üstüne 2 küçük amber göz
  (`headAccent`), hareket yönüne göre simetrik.
- Statik dururken hafif "nefes" (breathing) efekti: `_hintPulse` benzeri
  yavaş bir controller ile gövde genişliğini %±3 oynat — yılanlar canlı dursun.
  Performans: tek controller, tüm yılanlar aynı fazda.

## GÖREV 4 — Önceki review kalanları

1. CI Flutter sürümünü `3.41.3`'e eşitle (lokal ile aynı).
2. `BoardPainter` başlığı DECISIONS #0015'e referans veriyor ama DECISIONS.md'de
   #0015 yok — kararı geriye dönük logla: "Nokta ızgarası + slither görsel dili"
   (tarih, karar, gerekçe formatında).
3. Bu PR sonunda API 36 emülatörde smoke test: bir hard seviye aç,
   3 yılan çıkar, 1 çarpışma yap (hiss duyulmalı), STATE.md'yi güncelle.

## KABUL KRİTERLERİ

- [ ] `flutter analyze` temiz, tüm testler yeşil (property test dahil)
- [ ] Çarpışmada gerçek tıslama sesi (SystemSound.alert YOK artık)
- [ ] Slither başlarken süzülme sesi
- [ ] Hard seviye gözle görülür şekilde daha yoğun/iç içe
- [ ] Emülatör smoke testi yapıldı, screenshot docs'a eklendi
- [ ] DECISIONS #0015 + #0016 (bu revizyon) loglandı
