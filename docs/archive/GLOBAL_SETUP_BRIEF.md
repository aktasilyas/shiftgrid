# Global Claude Code Sistemi — Otonom Ajan Brifingi

## Amaç

Tek bir projeye değil, **makineye** kurulum yapıyorsun. Kurulum bittiğinde kullanıcı
herhangi bir yeni projeyi açtığında şunlar hazır gelecek: ortak kurallar, ortak
skill'ler, ortak subagent'lar, izin politikası, GitHub otomasyonu ve telefondan
kontrol imkanı. Kullanıcı bir daha proje başına kurulum yapmayacak.

## Rolün

Platform / Developer Experience mühendisisin. Görev uçtan uca senin.

## Çalışma prensipleri

Adım adım onay isteme. Sadece tanımlı GATE'lerde dur.

Hiçbir yapılandırma şemasını ezberden yazma. Her fazın başında ilgili resmi
dokümanı WebFetch ile oku, şemayı oradan doğrula. Doküman ile ezberin çelişirse
doküman kazanır. Bu kurulumun tamamı hızlı değişen özellikler üzerine kurulu.

`~/.claude/` altında değiştireceğin her dosyanın önce zaman damgalı yedeğini al:
`~/.claude/_backup_<tarih>/`.

Slash komutu gerektiren (`/config`, `/install-github-app`, `/plugin`, `/schedule`
gibi) veya tarayıcıda oturum açma gerektiren işleri sen yapamazsın. Bunları
yapmaya çalışma; **MANUEL-n** etiketiyle listele ve raporun sonundaki
"Senin yapacakların" bölümünde topla. Her biri için tam olarak ne yazılacağını,
nereye tıklanacağını ve beklenen çıktıyı yaz.

Hiçbir token, API anahtarı veya PAT'i dosyaya yazma.

Her fazın çıktısını `~/.claude/setup/` altına numaralı dosya olarak kaydet.

## Referans dokümanlar

- https://code.claude.com/docs/en/features-overview
- https://code.claude.com/docs/en/memory
- https://code.claude.com/docs/en/settings
- https://code.claude.com/docs/en/permission-modes
- https://code.claude.com/docs/en/skills
- https://code.claude.com/docs/en/sub-agents
- https://code.claude.com/docs/en/mcp
- https://code.claude.com/docs/en/hooks
- https://code.claude.com/docs/en/plugins
- https://code.claude.com/docs/en/plugin-marketplaces
- https://code.claude.com/docs/en/remote-control
- https://code.claude.com/docs/en/claude-code-on-the-web
- https://code.claude.com/docs/en/github-actions

---

## FAZ 0 — Envanter

```bash
claude --version
uname -a
echo $SHELL
ls -la ~/.claude/ 2>/dev/null || echo "yok"
cat ~/.claude/settings.json 2>/dev/null || echo "settings.json yok"
ls ~/.claude/skills/ ~/.claude/agents/ 2>/dev/null
claude mcp list
gh auth status 2>/dev/null || echo "gh CLI yok veya giriş yapılmamış"
git config --global user.name && git config --global user.email
```

Kullanıcının hangi dilleri/stack'leri kullandığını anlamak için ana geliştirme
dizinlerini tara (`~/Projects`, `~/dev`, `~/source` gibi yaygın konumlar; bulduğunu
kullan). Hangi framework'ler tekrar ediyor, hangi paket yöneticileri var, hangi
test komutları kullanılıyor — bunları not et. Global yapılandırma bu gerçek
kullanıma göre şekillenecek, varsayıma göre değil.

Çıktı: `~/.claude/setup/00-envanter.md`

---

## FAZ 1 — Global CLAUDE.md

`~/.claude/CLAUDE.md` oluştur. Buraya **projeden bağımsız, her zaman geçerli**
davranış kuralları girer. Proje detayı, mimari, komut girmez — onlar proje
CLAUDE.md'sinin işi.

İçermesi gerekenler: iletişim dili (Türkçe), kod yorumları dili, açıklama
üslubu (kısa, önce neden sonra çözüm), commit mesajı formatı (Conventional
Commits), dal isimlendirme kuralı, "test yazmadan özellik bitmiş sayılmaz"
ilkesi, sır/kimlik bilgisi dosyalarına asla dokunmama kuralı, ve iş bitiminde
ne rapor edileceği.

200 satırın altında tut. Uzun olan her şey skill'e gider.

Doğrulama: dosya var, satır sayısı sınırın altında, geçerli markdown.
Çıktı: `~/.claude/setup/01-global-claude-md.md`

---

## FAZ 2 — İzin politikası ve sandbox

Bu fazın amacı: kullanıcının gün boyu "Approve" tıklamasını bitirmek, güvenliği
kaybetmeden.

Önce `https://code.claude.com/docs/en/permission-modes` ve
`https://code.claude.com/docs/en/settings` dokümanlarını oku. Kural değerlendirme
sırasını (hooks → deny → ask → allow → mod) ve mevcut mod isimlerini oradan
doğrula.

`~/.claude/settings.json` içinde şunları kur:

**deny listesi** — her şeyden önce gelir, bypass modunda bile geçerlidir. Sır
dosyaları (`.env` ve türevleri, `*.pem`, `*.jks`, `key.properties`,
`google-services.json`, `*credentials*`), kök/ev dizini silme kalıpları, ve
kullanıcının makinesinde tehlikeli olabilecek global komutlar.

**allow listesi** — FAZ 0'da tespit ettiğin gerçek komutlardan üret. Salt-okunur
git komutları, test komutları, formatlayıcılar, analizörler, paket yöneticisinin
okuma komutları. Spekülatif kural ekleme; sadece kullanıcının fiilen kullandığı
komutlar girsin.

**defaultMode** — kullanıcının profiline uygun olanı seç ve raporda gerekçelendir.

**sandbox** — dokümandaki güncel şemaya göre etkinleştir. Ağ erişimi için izinli
alan adları listesi yaz: paket kayıt defterleri, GitHub, ve FAZ 0'da tespit
ettiğin stack'in ihtiyaç duyduğu alan adları.

Auto mode kullanılabilir durumdaysa raporda anlat ve nasıl açılacağını
MANUEL adımı olarak yaz.

Doğrulama: `claude --version` sonrası settings.json'ı JSON olarak parse et,
şemaya uygunluğunu kontrol et. Bozuk JSON tüm Claude Code kurulumunu etkiler,
bu doğrulamayı atlama.
Çıktı: `~/.claude/setup/02-izinler.md`

---

## FAZ 3 — Global skill'ler ve subagent'lar

`~/.claude/skills/` ve `~/.claude/agents/` altına kur. Bunlar her projede
kullanılabilir olacak, o yüzden hiçbiri belirli bir dile veya framework'e
bağımlı olmasın — projeyi okuyup adapte olsunlar.

**Skill: `/bootstrap`** — yeni bir projeye Claude Code kurulumu yapar. Repoyu
analiz eder, proje CLAUDE.md'sini yazar, `.claude/rules/` altında dil ve dizin
bazlı kurallar üretir, uygun MCP sunucularını önerir, temel hook'ları kurar.
Kullanıcının bir daha manuel kurulum yapmamasının anahtarı bu skill.

**Skill: `/prior-art`** — verilen problem için GitHub'da mevcut çözümleri araştırır.
Arama, filtreleme (son commit tarihi, açık issue oranı, lisans uyumu, bakım
durumu), ve her aday için "kullan / ilham al / uzak dur" kararı içeren bir rapor
üretir. Lisansı projeyle uyumsuz olanları açıkça işaretler. Bu skill'i
`context: fork` ile izole bağlamda çalıştır ki arama çıktısı ana konuşmayı
doldurmasın.

**Skill: `/ship`** — commit öncesi kalite kapısı ve PR akışı. Format, analiz,
test, değişiklik özeti, Conventional Commits formatında commit, dal oluşturma,
PR açma ve PR açıklamasını doldurma.

**Skill: `/handoff`** — oturum sonunda ne yapıldığını, nerede kalındığını ve
sıradaki adımı özetleyen bir devir notu üretir. Telefondan takip için kritik.

**Subagent: `reviewer`** — değişen kodu okur, mimari ihlali, test boşluğu,
performans ve güvenlik sorunu arar. Salt-okunur araçlarla sınırlı olsun.

**Subagent: `researcher`** — dış araştırma yapar, sadece özet döndürür. Ana
bağlamı korumak için var.

Skill açıklamalarını (`description`) tetikleyici olarak yaz, dokümantasyon olarak
değil: üçüncü tekil şahıs, kullanıcının gerçekten yazacağı ifadeler. Belirsiz
açıklama, bir skill'in hiç tetiklenmemesinin en yaygın sebebidir. Yan etkisi olan
skill'lere (`/ship` gibi) `disable-model-invocation: true` ekle.

Doğrulama: her skill'in frontmatter'ını parse et. `/prior-art` skill'ini gerçek
bir konuyla çalıştır ve anlamlı çıktı ürettiğini gör.
Çıktı: `~/.claude/setup/03-skills-agents.md`

---

## FAZ 4 — Kişisel plugin ve marketplace

Bu faz "her projede tekrar kurulum yapmama" hedefinin kalıcı çözümü. FAZ 1-3'te
ürettiğin her şeyi bir plugin olarak paketle ve kullanıcının kendi GitHub
marketplace'inde yayınla. Böylece yeni makine, yeni proje veya sıfırlama
durumunda tek komutla her şey geri gelir.

Plugin ve marketplace şemasını dokümanlardan doğrula, sonra kullanıcının
makinesinde `~/dev/claude-kit` (veya FAZ 0'da bulduğun geliştirme dizini) altında
repo yapısını kur: plugin manifesti, skills, agents, hooks ve MCP tanımları,
marketplace manifesti, ve kurulum talimatlarını içeren README.

Repoyu git ile başlat, commit'le. Uzak repoya push GATE-B'ye tabi.

Doğrulama: manifest dosyalarını JSON/YAML olarak parse et, dizin yapısının
dokümandaki şemaya uyduğunu kontrol et.
Çıktı: `~/.claude/setup/04-plugin.md`

---

## FAZ 5 — GitHub otomasyonu

Hedef: issue'ya `@claude` yazınca kod yazıp PR açan, PR açılınca otomatik inceleme
yapan bir yapı. Referans: `https://code.claude.com/docs/en/github-actions`.

Kullanıcının aktif projeleri için yeniden kullanılabilir bir workflow şablonu
hazırla ve `~/.claude/templates/github/` altına koy. Şablon, GitHub Actions izin
kapsamlarını doğru tanımlasın — bir workflow'a `permissions` bloğu eklendiği anda
GitHub o job'ı varsayılan modundan çıkarır ve isimlendirmediğin her kapsamı
`none` yapar; bu, GitHub'a yazmaya çalışan workflow'ların en yaygın hata sebebidir.

GitHub App kurulumu ve repo secret'ı ekleme senin yapabileceğin işler değil,
MANUEL adımı olarak yaz: hangi izinler gerekiyor, secret adı tam olarak ne,
büyük/küçük harf duyarlı olduğu uyarısı, ve fork PR'larında secret'ın boş
geleceği notu.

Ayrıca `/bootstrap` skill'ini güncelle: yeni bir projede çalıştırıldığında bu
workflow şablonunu da kursun.

Çıktı: `~/.claude/setup/05-github.md`

---

## FAZ 6 — Uzaktan çalışma kurulumu

İkisi farklı şey, ikisini de rapora ayrı ayrı yaz.

**Remote Control** — yerel oturumu telefondan/tarayıcıdan sürmek. Makine açık
kalmalı. Tüm oturumlarda varsayılan olarak açılması bir ayar meselesi, MANUEL
adımı olarak yaz.

**Claude Code on the web / bulut oturumları** — makine kapalıyken de çalışan,
Anthropic altyapısında koşan oturumlar. GitHub bağlantısı ve ortam yapılandırması
gerektirir. Bulut ortamının kurulum betiği (bağımlılık kurulumu, SDK sürümü) için
kullanıcının stack'ine uygun bir şablon hazırla ve `~/.claude/templates/cloud/`
altına koy.

Her iki özelliğin de araştırma önizlemesi statüsünde olduğunu ve plan/kuruluş
politikasına bağlı olabileceğini raporda belirt. Kullanıcının planında mevcut
değilse alternatif olarak GitHub Actions üzerinden asenkron çalışma yolunu anlat.

Çıktı: `~/.claude/setup/06-uzaktan.md`

---

## FAZ 7 — Zamanlanmış işler (Routines)

Kullanıcı için üç rutin tasarla ve prompt metinlerini yaz. Oluşturma işlemi
MANUEL adımı olacak, ama promptları ve zamanlamayı sen hazırla:

Gece bağımlılık ve güvenlik taraması — güncel olmayan paketler, bilinen açıklar,
kırıcı değişiklik uyarıları; bulgu varsa issue açar.

Sabah proje brifingi — açık PR'lar, başarısız CI koşuları, yeni issue'lar,
dünkü ilerleme özeti; tek bir kısa rapor üretir.

Haftalık teknik borç raporu — test kapsamı değişimi, analiz uyarıları, büyüyen
dosyalar, mimari sapmalar.

Rutinlerin maliyet ürettiğini ve minimum çalışma aralığı olduğunu rapora yaz.

Çıktı: `~/.claude/setup/07-routines.md`

---

## FAZ 8 — Uçtan uca test ve rapor

Gerçek bir sınama yap: kullanıcının projelerinden birinde `/bootstrap` çalıştır,
küçük bir değişiklik yap, `/ship` ile PR akışını dene. Bu sırada izin sorusu
çıkıp çıkmadığını, hangi kuralların devreye girdiğini, hook'ların tetiklenip
tetiklenmediğini gözlemle. Denemeyi geri al, gözlemleri sakla.

`~/.claude/setup/RAPOR.md` yaz:

Bir paragraf özet — sistem ne yapıyor, kurulum öncesine göre günlük akış nasıl
değişiyor.

Kurulan her bileşen: dosya yolu, görevi, nasıl tetiklendiği, somut kullanım
örneği.

**Günlük kullanım kılavuzu** — bu bölüm raporun en önemli kısmı. Şu senaryoların
her biri için tam olarak ne yazılacağı: yeni proje başlatma, mevcut projede
özellik geliştirme, hata ayıklama, PR açma, telefondan iş başlatma, telefondan
devam eden işi kontrol etme, sürüm çıkarma, benzer projeleri araştırma.

**Senin yapacakların** — tüm MANUEL-n adımları, sırayla, her biri tek tıklık
netlikte. Kaç dakika süreceğini de yaz.

Test sonuçları, kurulamayanlar ve gerekçeleri, sonraki üç öneri.

---

## GATE'ler

**GATE-A — Kimlik bilgisi.** GitHub PAT veya Anthropic API anahtarı gerektiğinde
dur, nasıl üretileceğini anlat, bekle. Anahtarı hiçbir dosyaya yazma.

**GATE-B — Uzak repoya push.** claude-kit reposunu GitHub'a göndermeden önce dur,
public mi private mı olacağını sor, içeriğinde sızmış sır olmadığını doğrula.

**GATE-C — Maliyet üreten kurulum.** Bulut rutinleri veya GitHub Actions
otomasyonu maliyet üretir. Kurmadan önce tahmini kullanımı sun.

**GATE-D — Final.** Raporu sun ve dur.

Bunların dışında onay isteme.
