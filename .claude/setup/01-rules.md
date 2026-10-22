# FAZ 1 — CLAUDE.md ve path-scoped rules

## Şema doğrulaması (WebFetch)

`https://code.claude.com/docs/en/memory` okundu. Doğrulanan noktalar:

- Proje CLAUDE.md `./CLAUDE.md` **veya** `./.claude/CLAUDE.md` olabilir; hedef **<200 satır**.
- `.claude/rules/*.md` özyinelemeli keşfedilir. `paths` **YAML frontmatter** alanı ile
  glob'a bağlanır; `paths` yoksa kural her oturumda koşulsuz yüklenir.
- Path-scoped kurallar "her tool çağrısında" değil, **Claude eşleşen dosyayı okuduğunda**
  devreye girer.
- CLAUDE.md zorlayıcı değildir (bağlamdır); mutlak zorunluluk gerekiyorsa hook kullanılmalı
  → FAZ 5'in gerekçesi buradan geliyor.

## Oluşturulanlar

| Dosya | Kapsam (`paths`) | Satır |
|---|---|---|
| `CLAUDE.md` | (her oturum) | **95** ✅ <200 |
| `.claude/rules/domain.md` | `lib/features/*/domain/**/*.dart` | 22 |
| `.claude/rules/state-management.md` | `lib/features/*/presentation/providers/**/*.dart`, `lib/core/di/**/*.dart` | 28 |
| `.claude/rules/painters.md` | `lib/features/*/presentation/painters/**/*.dart` | 24 |
| `.claude/rules/testing.md` | `test/**/*.dart` | 25 |

CLAUDE.md içeriği: bir cümlelik proje tanımı, komutlar (CI'dan birebir), mimari kurallar,
çözülebilirlik invariantı, zorluk merdiveni, kod stili, "asla" listesi, `docs/` referansları.
Uzun mimari anlatım ve örnek kod bilinçli olarak dışarıda bırakıldı.

## Arşivleme (silme yok)

Brifing gereği hiçbir dosya silinmedi, taşındı:

- `TASKS_REVIZYON.md` → `docs/archive/TASKS_REVIZYON.md` (tamamlanmış revizyon turu)
- `BOOTSTRAP.md` → `docs/archive/BOOTSTRAP-root-duplicate.md`
  — **`docs/BOOTSTRAP.md` ile byte-byte aynıydı**; kullanıcı isterse bu kopya silinebilir.

Kalıcı kural niteliğindeki içerik (teknik anayasa, çözülebilirlik invariantı, yasaklar)
BOOTSTRAP'tan süzülüp CLAUDE.md'ye taşındı. BOOTSTRAP'ın faz planı/GATE'leri tarihsel
olduğu için taşınmadı.

## Doğrulama

### 1. Boyut ve YAML

```
$ wc -l CLAUDE.md
95 CLAUDE.md                      → ✅ 200 sınırının altında

$ python (yaml.safe_load ile frontmatter parse)
.claude/rules/domain.md:           OK  paths=['lib/features/*/domain/**/*.dart']
.claude/rules/painters.md:         OK  paths=['lib/features/*/presentation/painters/**/*.dart']
.claude/rules/state-management.md: OK  paths=['lib/features/*/presentation/providers/**/*.dart',
                                              'lib/core/di/**/*.dart']
.claude/rules/testing.md:          OK  paths=['test/**/*.dart']
```

Dördü de geçerli YAML, hepsi 20–30 satır aralığında.

### 2. Subagent testi

`general-purpose` subagent'a soruldu: *"Bu projede yeni bir ekran için state yönetimini
nasıl kurarım?"*

Subagent CLAUDE.md + `state-management.md` + `testing.md` yükleyerek cevap verdi ve
**projenin gerçek konvansiyonlarına uydu**:

- State ve notifier ayrı dosyada, `Notifier<T>` + dosya sonunda `NotifierProvider` ✅
- freezed / `@riverpod` / build_runner kullanılmayacağını doğru söyledi ✅
- Repository provider'ının `core/di/providers.dart`'a yazılacağını, async kaynağın
  `UnimplementedError` tohum provider + `main` override'ı ile geleceğini bildi ✅
- Riverpod 3 tuzağını (`initState`'te mutasyon yasağı → `addPostFrameCallback`) ve
  koddaki gerçek örneğini gösterdi ✅
- ARB zorunluluğunu, üretilen dosyaların elle düzenlenmeyeceğini söyledi ✅
- Testi `ProviderContainer` + `addTearDown` + `overrides` ile, mocksuz kurdu ✅

**Sonuç: geçti (tek denemede).**

### 3. Subagent'ın yakaladığı kural hatası → düzeltildi

Subagent, `state-management.md`'deki *"alan ekliyorsan `copyWith`, `==` ve `hashCode`'u
birlikte güncelle"* maddesinin kodla çeliştiğini bildirdi. Doğrulandı:

```
$ grep -n "operator ==\|hashCode" .../game_state.dart .../settings_state.dart
YOK
```

`GameState` ve `SettingsState` bilinçli olarak kimlik karşılaştırması kullanıyor; değer
eşitliği yalnızca domain varlıklarında zorunlu. Kural gerçeğe göre düzeltildi, ayrıca
`clearLanguage` kalıbı ve `soundControllerProvider` istisnası (DI kuralının tek gerçek
istisnası, `grep` ile doğrulandı) kurala eklendi.

Bu, kuralların "ezberden değil repodan" yazıldığının kanıtı: doğrulama adımı gerçek bir
tutarsızlık yakaladı ve kaynak koda bakılarak giderildi.
