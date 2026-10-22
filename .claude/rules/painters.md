---
paths:
  - "lib/features/*/presentation/painters/**/*.dart"
---

# CustomPainter katmanı

- Tüm tahta **tek** `CustomPainter` ile çizilir. Hücre başına widget, Flame veya
  ikinci bir painter katmanı ekleme.
- Piksel ↔ ızgara çevrimi **yalnızca** `BoardGeometry` üzerinden yapılır. Painter ve
  dokunma isabet testi aynı geometriyi kullanmalı, yoksa görsel ile tıklama kayar.
- `shouldRepaint` her yeni alan için güncellenmelidir. Alan eklediğinde karşılaştırmaya
  eklemeyi unutma — unutulan alan "neden güncellenmiyor" hatası olarak geri döner.
- Ölçüler `geo.cellSize`'a **orantılı** olmalı, sabit piksel yazma. Yoğun tahtalarda
  (36×36) görünürlük için `math.max(oran * cell, tabanPiksel)` kalıbını kullan.
- Performans bütçesi gerçektir: bir tahtada yüzlerce yılan olabilir. Pahalı detay
  (clipPath, blur, maskFilter) yalnızca ekrandaki hücre yeterince büyükken çizilir —
  `detailed` eşiği `cell * viewScale` üzerinden hesaplanır, `cell` üzerinden değil.
- `canvas.save()` çağıran her yol `canvas.restore()` ile kapanmalıdır; erken `return`
  eden dallarda da.
- Painter durumsuzdur: animasyon ilerlemesi, zoom, vurgu gibi her şey dışarıdan
  parametre olarak gelir. Painter içinde `AnimationController` tutma.
- Görsel değişikliği testle kanıtlanamaz (golden test yok) — değişikliği gerçek cihazda
  `flutter run` ile gör, ekran görüntüsüyle doğrula.
