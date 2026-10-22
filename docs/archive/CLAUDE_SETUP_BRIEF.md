# Claude Code Profesyonel Kurulum — Otonom Ajan Brifingi

## Rolün

Sen bu repoda Tech Lead + Developer Experience mühendisisin. Görevin, Claude Code'un
tüm eklenti katmanını (CLAUDE.md, rules, skills, subagents, MCP, hooks, plugins) bu
proje için kurmak, test etmek ve sonunda tek bir rapor sunmak.

## Çalışma prensipleri

Adım adım onay isteme. Fazları sırayla, uçtan uca kendin tamamla. Sadece aşağıda
tanımlı GATE noktalarında dur.

Bir yapılandırma dosyasının formatını ezberden yazma. Her fazın başında ilgili resmi
dokümanı WebFetch ile oku ve şemayı oradan doğrula. Doküman ile ezberin çelişirse
doküman kazanır.

Mevcut hiçbir dosyayı sormadan silme. Üzerine yazacağın her dosyanın önce
`<dosya>.bak` kopyasını al.

Token, API key, PAT gibi hiçbir kimlik bilgisini repoya yazma. Bunlar ortam
değişkeni olarak referanslanır.

Her fazın sonunda doğrulama komutunu çalıştır, çıktısını `.claude/setup/` altına
numaralı bir dosyaya kaydet. Bir doğrulama başarısızsa düzelt ve tekrar dene;
iki denemede düzelmezse fazı "kısmi" olarak işaretle ve devam et, raporda belirt.

## Referans dokümanlar

Sırasıyla ihtiyaç duydukça oku:

- https://code.claude.com/docs/en/features-overview
- https://code.claude.com/docs/en/memory
- https://code.claude.com/docs/en/skills
- https://code.claude.com/docs/en/sub-agents
- https://code.claude.com/docs/en/mcp
- https://code.claude.com/docs/en/hooks
- https://code.claude.com/docs/en/plugins
- https://docs.flutter.dev/ai/mcp-server

---

## FAZ 0 — Envanter

Çalıştır ve çıktıları `.claude/setup/00-envanter.md` dosyasına yaz:

```bash
claude --version
git status --short
git rev-parse --abbrev-ref HEAD
flutter --version
dart --version
ls -la .claude/ 2>/dev/null || echo "yok"
wc -l CLAUDE.md 2>/dev/null || echo "CLAUDE.md yok"
claude mcp list
ls .github/workflows/ 2>/dev/null || echo "CI yok"
cat pubspec.yaml | head -40
```

Ardından repoyu tara ve şunları tespit et: katman yapısı (`lib/` altındaki dizin
düzeni), state yönetimi kütüphanesi ve sürümü, kullanılan test türleri (unit,
widget, golden, property), lint yapılandırması (`analysis_options.yaml`), CI'da
sabitlenmiş Flutter sürümü ile yerel sürüm arasında uyuşmazlık olup olmadığı.

Bu tespitleri envanter dosyasına yaz. Sonraki fazların tamamı bu tespitlere
dayanacak — varsayım kullanma, repodan okuduğunla yaz.

Temiz bir başlangıç için `git checkout -b chore/claude-setup` ile yeni dal aç.

---

## FAZ 1 — CLAUDE.md ve path-scoped rules

Hedef: CLAUDE.md 200 satırın altında, yalnızca "her oturumda geçerli" içerik.
Referans/uzun içerik skill'lere, dosya-yoluna özel kurallar `.claude/rules/`
altına taşınır.

CLAUDE.md şunları içermeli: projenin bir cümlelik tanımı, komutlar (test, analiz,
format, build), mimari kurallar, ve "asla" kuralları. Uzun mimari açıklama,
örnek kod, API dokümanı buraya girmez.

`.claude/rules/` altına en az üç dosya oluştur, her biri `paths` frontmatter'ı ile
ilgili dizine sınırlansın. Bu projede en azından şunlar: state yönetimi katmanı
(provider/notifier dosyaları), çizim katmanı (CustomPainter dosyaları), test
katmanı (`test/**`). Her kural dosyası kısa olsun, 20-30 satırı geçmesin ve
sadece o dosya tipinde geçerli davranışı anlatsın.

Mevcut BOOTSTRAP.md, TASKS*.md gibi dosyalar varsa bunları silme; içlerinden
kalıcı kural niteliğindekileri CLAUDE.md veya rules'a taşı, geri kalanını
`docs/` altına arşivle ve CLAUDE.md'den referans ver.

**Doğrulama:** `wc -l CLAUDE.md` 200'ün altında olmalı. Her rules dosyasının
frontmatter'ı geçerli YAML olmalı. Ardından bir subagent başlat ve ona şu soruyu
sor: "Bu projede yeni bir ekran için state yönetimini nasıl kurarım?" Subagent
CLAUDE.md'yi yüklediği için cevabı projenin gerçek konvansiyonlarına uymalı.
Uymuyorsa kuralları netleştir ve tekrar dene. Sonucu `.claude/setup/01-rules.md`
dosyasına yaz.

---

## FAZ 2 — Skills

En az üç skill oluştur. Her biri `.claude/skills/<isim>/SKILL.md` yapısında olsun.

**`/release`** — yayınlama akışı. Sürüm numarası artırma, changelog güncelleme,
`dart analyze` ve `flutter test` çalıştırma, release build alma, store'a yükleme
adımları. Yan etkisi olduğu için frontmatter'a `disable-model-invocation: true`
ekle; yalnızca kullanıcı çağırabilsin. Bu proje için gerçek build komutlarını
FAZ 0'daki tespitlerden al, uydurma.

**`/feature`** — yeni özellik iskeleti. Clean Architecture katmanlarını doğru
sırayla oluşturan, testle başlayan, provider ve use case'i doğru dizine koyan
adım adım iş akışı.

**`/ship-check`** — commit öncesi kalite kapısı. Format, analiz, test, golden
test, coverage eşiği kontrolü ve bulguların raporlanması.

Skill açıklamaları (`description`) tetikleyicidir, dokümantasyon değil. Üçüncü
tekil şahısla yaz ve kullanıcının gerçekten yazacağı ifadeleri içersin. Belirsiz
açıklama, skill'in hiç tetiklenmemesinin en yaygın sebebidir.

**Doğrulama:** `ls .claude/skills/*/SKILL.md` ile üçünün de yerinde olduğunu
doğrula, frontmatter'ları parse et. `/ship-check` skill'ini fiilen çalıştır ve
gerçek çıktı ürettiğini gör. Sonucu `.claude/setup/02-skills.md` dosyasına yaz.

---

## FAZ 3 — Subagents

`.claude/agents/` altına en az iki subagent tanımla.

**`flutter-reviewer`** — değişen dosyaları okuyup Clean Architecture ihlali,
gereksiz rebuild, eksik `shouldRepaint`, sızdıran controller, test edilmemiş
public API arar. Yalnızca okuma araçlarına erişsin, dosya değiştiremesin.

**`test-runner`** — testleri çalıştırıp yalnızca başarısız olanların özetini
döndürür. Uzun test çıktısının ana bağlamı doldurmasını engellemek için var.

Subagent tanımları kısa olsun, 30 satır civarı yeterli. Her birine hangi skill'leri
önyükleyeceğini `skills:` alanıyla belirt.

**Doğrulama:** Her iki subagent'ı da gerçek bir görevle çalıştır ve özet
döndürdüklerini gör. `flutter-reviewer`'ı repodaki en son commit'in diff'i
üzerinde çalıştır; bulduğu gerçek sorunları `.claude/setup/03-subagents.md`
dosyasına yaz.

---

## FAZ 4 — MCP sunucuları

Az ve gerekçeli kur. Her sunucu için "bu neden var" cümlesi yazamıyorsan kurma.

**Dart ve Flutter MCP (zorunlu):**

```bash
claude mcp add --transport stdio dart -- dart mcp-server
```

Bu sunucu Dart SDK 3.9+ / Flutter 3.35+ gerektirir. FAZ 0'da tespit ettiğin sürüm
bunun altındaysa kurma, raporda sürüm yükseltme önerisi olarak belirt.

**GitHub MCP (koşullu):** PR ve issue akışını Claude Code içinden yönetmek için.
Kişisel erişim token'ı gerektirir. → **GATE-A**

**Doğrulama:** `claude mcp list` çıktısında sunucular "connected" görünmeli.
Ardından dart sunucusunu fiilen kullan: analyzer sonuçlarını MCP üzerinden çektir
ve dönen çıktıyı `.claude/setup/04-mcp.md` dosyasına kaydet. Bağlanmayan sunucu
varsa hata mesajını da kaydet.

---

## FAZ 5 — Hooks

Hook ile skill farkı: hook garanti çalışır, skill modelin yorumuna bağlıdır. Her
seferinde mutlaka olması gereken şeyler hook'a girer.

En az üç hook kur, `.claude/settings.json` içine:

Düzenleme sonrası biçimlendirme — `PostToolUse` olayında, `Edit|Write` eşleşmesinde
değiştirilen Dart dosyasına `dart format` çalıştır.

Tehlikeli işlem engeli — `PreToolUse` olayında `.env`, `*.jks`, `key.properties`,
`google-services.json` gibi dosyalara yazmayı engelle. Bu bir istek değil,
zorlayıcı bir kapı olmalı.

İş bitti bildirimi — oturum durduğunda masaüstü bildirimi gönder. İşletim sistemine
göre doğru komutu seç (macOS'ta `osascript`, Linux'ta `notify-send`, Windows'ta
PowerShell toast).

Hook JSON şemasını yazmadan önce hooks dokümanını mutlaka oku; olay adları ve
matcher yapısı sürümle değişebiliyor.

**Doğrulama:** Kasıtlı olarak kötü biçimlendirilmiş bir Dart dosyası oluştur,
düzenle ve format hook'unun devreye girdiğini doğrula. `.env` dosyasına yazmayı
dene ve engellendiğini doğrula. Sonuçları `.claude/setup/05-hooks.md` dosyasına yaz.

---

## FAZ 6 — Plugin değerlendirmesi

`/plugin` ile resmi Anthropic marketplace'ini incele. Bu projeye gerçekten değer
katacak olanları belirle; özellikle kod incelemesi, güvenlik taraması, kod
zekası (LSP) ve güncel kütüphane dokümanı sağlayanlara bak.

Kurma kararını sen verme, aday listesi çıkar. Her aday için ne yaptığını, hangi
izinleri istediğini ve neden bu projeye uygun olduğunu yaz. Bilinmeyen yayıncıdan
geniş kabuk veya repo erişimi isteyen hiçbir plugin'i önerme.

Bulguları `.claude/setup/06-plugins.md` dosyasına yaz.

---

## FAZ 7 — Bütünsel test ve rapor

Kurulumun tamamını gerçek bir görevle sına: küçük ama uçtan uca bir değişiklik yap
(örneğin mevcut bir ekrana basit bir ayar seçeneği ekle). Bu sırada CLAUDE.md
kurallarının uygulandığını, doğru rules dosyasının yüklendiğini, hook'ların
tetiklendiğini ve `/ship-check` skill'inin temiz çıktı verdiğini gözlemle. Bu
deneme değişikliğini sonra geri al, sadece gözlemleri sakla.

Sonra `.claude/setup/RAPOR.md` dosyasını yaz. İçeriği şu sırada olsun:

Bir paragraf özet — ne kuruldu, ne kurulmadı, kurulum sonrası günlük akış nasıl
değişiyor.

Kurulan her bileşen için: dosya yolu, ne işe yaradığı, nasıl tetiklendiği, ve
somut bir kullanım örneği. Kullanıcı bu bölümü okuyarak dokümana dönmeden
çalışabilmeli.

Günlük kullanım kılavuzu — hangi durumda hangi komutu yazacağı. Yeni özellik
yazarken, hata ayıklarken, PR açarken, sürüm çıkarırken.

Test sonuçları tablosu — her fazın doğrulaması geçti mi, geçmediyse neden.

Kurulamayanlar ve gerekçeleri.

Sonraki adım önerileri — bu projede sıradaki en yüksek getirili üç iyileştirme.

Son olarak değişiklikleri anlamlı commit'lerle `chore/claude-setup` dalına at,
`git log --oneline` çıktısını rapora ekle. Merge etme, kullanıcı karar versin.

---

## GATE'ler

**GATE-A — GitHub MCP kimlik bilgisi.** GitHub MCP'yi kurmadan önce dur.
Kullanıcıya PAT'i nasıl oluşturacağını (hangi scope'lar gerekli) ve token'ı
ortam değişkeni olarak nasıl vereceğini anlat. Token'ı bekle ya da "atla"
talimatını al. Token'ı hiçbir dosyaya yazma.

**GATE-B — pubspec.yaml veya CI değişikliği.** Bir faz `pubspec.yaml`,
`analysis_options.yaml` veya `.github/workflows/` altında değişiklik gerektiriyorsa
dur, önerilen değişikliğin diff'ini sun, onay al.

**GATE-C — Final.** FAZ 7 bittiğinde raporu sun ve dur.

Bunların dışında hiçbir noktada onay isteme.
