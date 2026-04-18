# Workflow Manager — Proje Dokümantasyonu

## Genel Bakış

**Workflow Manager**, Trello'nun görev yönetimi ile n8n'in iş akışı tasarımını birleştiren, tam kapsamlı bir web tabanlı iş akışı yönetim uygulamasıdır. Kullanıcılar görsel bir kanvas üzerinde süreç diyagramları tasarlayabilir, bu diyagramların her adımına görevler ekleyebilir ve ekip arkadaşlarıyla işbirliği yapabilir.

---

## Teknoloji Yığını

| Katman | Teknoloji |
|--------|-----------|
| Backend | Node.js + Express.js + TypeScript + TypeORM |
| Frontend | Vue 3 + Vite + Pinia + Konva.js |
| Veritabanı | PostgreSQL |
| Kimlik Doğrulama | JWT + bcryptjs |
| Deployment | Docker + Docker Compose + Nginx |

---

## Özellikler

### 1. Görsel Kanvas Editörü
- Konva.js (2D canvas kütüphanesi) ile çizilen interaktif bir iş akışı tasarım alanı
- Sürükle-bırak ile node ekleme ve konumlandırma
- 4 farklı node tipi:
  - **Start** (Başlangıç)
  - **Process** (İşlem)
  - **Decision** (Karar — evet/hayır dalları)
  - **End** (Bitiş)
- Nodelar arası bağlantı çizme
- Karar nodları için iki çıkış konnektörü (evet/hayır)
- Zoom (mouse tekerleği) ve pan (orta fare) desteği
- Çoklu seçim (Ctrl+Click)

### 2. Görev Yönetimi (Task Management)
- Her node'a birden fazla görev eklenebilir
- Görev durumları: `pending`, `in_progress`, `completed`
- Görevler iş akışı üyelerine atanabilir
- Yalnızca göreve atanan kullanıcı tamamlandı olarak işaretleyebilir
- Tamamlanan görev oranına göre node üzerinde otomatik ilerleme çubuğu:
  - 0–50% → Kırmızı
  - 50–80% → Turuncu
  - 80–100% → Yeşil
- Node üzerine çift tıklanınca görev modalı açılır

### 3. İşbirliği & Davet Sistemi
- Her iş akışı için benzersiz bir davet kodu otomatik oluşturulur (MD5 tabanlı)
- Kullanıcılar davet koduyla katılım talebi gönderebilir
- İş akışı sahibi gelen talepleri onaylayabilir veya reddedebilir
- Üyelik rolleri: `owner`, `admin`, `member`
- InvitationManagerWidget üzerinden bekleyen talepler görüntülenip yönetilir

### 4. JSON Import / Export
- İş akışı tüm node ve bağlantılarıyla birlikte JSON formatında dışa aktarılabilir
- JSON yapıştırılarak mevcut çalışma alanına iş akışı aktarılabilir

### 5. Undo / Redo (Geri Al / İleri Al)
- 50 adım derinliğinde yerel geri alma yığını
- Ctrl+Z ile geri al, Ctrl+Y / Ctrl+Shift+Z ile ileri al
- Değişiklikler yalnızca Ctrl+S ile sunucuya kaydedilir (yerel undo/redo'dan bağımsız)

### 6. Kimlik Doğrulama & Yetkilendirme
- Kullanıcı kayıt ve giriş sistemi
- JWT token (7 günlük geçerlilik), localStorage'da saklanır
- Tüm API isteklerine token otomatik eklenir
- 401 hatası → login sayfasına yönlendirme
- Kullanıcı durumları: `pending`, `active`, `inactive`

### 7. Klavye Kısayolları

| Kısayol | Eylem |
|---------|-------|
| Ctrl+S | İş akışını sunucuya kaydet |
| Ctrl+Z | Geri al |
| Ctrl+Y / Ctrl+Shift+Z | İleri al |
| M | Hareket modunu aç/kapat |
| Delete / Del | Seçili node/bağlantıyı sil |
| Mouse tekerleği | Zoom |
| Orta fare | Canvas'ı kaydır |
| Ctrl+Click | Çoklu seçim |

---

## Veritabanı Mimarisi

### Tablolar

| Tablo | Açıklama |
|-------|----------|
| `users` | Kullanıcı hesapları (email, şifre hash, rol, durum) |
| `workflows` | İş akışı tanımları (ad, açıklama, davet kodu, metadata JSON) |
| `nodes` | İş akışındaki adımlar (tip, durum, ilerleme %, konum JSON) |
| `connections` | Nodelar arası bağlantılar (kaynak, hedef, konnektör tipi) |
| `tasks` | Node bazlı görevler (başlık, açıklama, durum, atanan kullanıcı) |
| `files` | Dosya ekleri (metadata, tip, node bağlantısı) |
| `workflow_invitations` | Davet/katılım talepleri (kod, durum, yanıt zamanı) |
| `workflow_members` | İş akışı üyeleri ve rolleri |

### Önemli Özellikler
- Tüm tablolarda UUID primary key
- Otomatik `created_at` / `updated_at` (PostgreSQL trigger)
- Cascade delete (iş akışı silinince tüm node/task/bağlantılar silinir)
- Unique kısıtlamalar: email, invite_code
- Bileşik index'ler performans için

---

## API Endpoint'leri (Özet)

```
POST   /api/auth/register            Kullanıcı kaydı
POST   /api/auth/login               Giriş (JWT döner)

GET    /api/workflows                Kullanıcının iş akışları
POST   /api/workflows                Yeni iş akışı oluştur
GET    /api/workflows/:id            İş akışı detayı
PUT    /api/workflows/:id            Güncelle
DELETE /api/workflows/:id            Sil
POST   /api/workflows/:id/export     JSON dışa aktar
POST   /api/workflows/import         JSON içe aktar

GET    /api/nodes/workflow/:wfId     Nodları listele
POST   /api/nodes/workflow/:wfId     Node oluştur
PUT    /api/nodes/:id                Node güncelle
DELETE /api/nodes/:id                Node sil

POST   /api/connections/workflow/:wfId   Bağlantı oluştur
DELETE /api/connections/:id              Bağlantı sil

GET    /api/tasks/node/:nodeId       Node görevleri
POST   /api/tasks/node/:nodeId       Görev oluştur
PUT    /api/tasks/:taskId            Görev güncelle
DELETE /api/tasks/:taskId            Görev sil
POST   /api/tasks/:taskId/assign     Görevi kullanıcıya ata

POST   /api/invitations/request              Katılım talebi gönder
GET    /api/invitations/pending/:workflowId  Bekleyen talepler
PATCH  /api/invitations/:id/respond          Onayla / reddet

GET    /health                       Servis sağlık kontrolü
```

---

## Proje Dizin Yapısı

```
workflow_manager/
├── backend/src/
│   ├── app.ts                 Express uygulama giriş noktası
│   ├── config/database.ts     TypeORM bağlantı ayarları
│   ├── middleware/auth.ts     JWT doğrulama middleware
│   ├── models/                TypeORM entity'leri (8 model)
│   ├── services/              İş mantığı katmanı (6 servis)
│   └── routes/                API endpoint tanımları (7 route)
│
├── frontend/src/
│   ├── screens/               Ana sayfa bileşenleri
│   │   ├── LoginScreen.vue          Giriş/Kayıt ekranı
│   │   ├── WorkflowListScreen.vue   İş akışı listesi
│   │   └── CanvasScreen.vue         Kanvas editörü
│   ├── widgets/               Yeniden kullanılabilir bileşenler (12 widget)
│   ├── services/              API istemcileri (6 servis)
│   ├── stores/                Pinia state yönetimi (3 store)
│   ├── models/                TypeScript arayüzleri
│   └── router/                Vue Router yapılandırması
│
├── database_migrations/       SQL migration dosyaları
├── docker-compose.yml         Servis orkestrasyon yapılandırması
├── workflow_database_schema_ultimate.sql   Tam veritabanı şeması
├── README.md                  Kullanım kılavuzu (Türkçe)
└── KEYBOARD_SHORTCUTS.md      Klavye kısayolları rehberi
```

---

## Docker Kurulumu

```
Servisler:
  backend   → localhost:3001  (Node.js, port 3000 içeride)
  frontend  → localhost:3002  (Nginx, port 80 içeride)
  postgres  → Harici ağdan bağlanır (postgres_postgres-network)
```

- Backend ve frontend çok aşamalı (multi-stage) Dockerfile ile oluşturulur
- Backend: Node 20 Alpine, non-root kullanıcı
- Frontend: Vite build → Nginx Alpine üzerinde statik servis

---

## State Yönetimi (Frontend)

| Store | Sorumluluğu |
|-------|-------------|
| `auth` | Kullanıcı oturumu, JWT token (localStorage'da kalıcı) |
| `workflow` | İş akışı CRUD, undo/redo yığını, node/bağlantı durumu |
| `canvas` | Kanvas konum/zoom, seçim, sürükleme modu |

---

## Güvenlik

- Şifreler bcryptjs ile hash'lenir (12 round)
- JWT secret ortam değişkeninden okunur
- Helmet.js güvenlik header'ları
- TypeORM parametreli sorgular (SQL injection önlemi)
- Non-root Docker kullanıcısı

---

## Kullanıcı Gözünden: Ekranlar, Butonlar ve Özellikler

### Giriş Ekranı (Login / Register)

Uygulamayı ilk açtığınızda bir giriş kartı karşılar.

**Alanlar:**
- Ad Soyad — Yalnızca kayıt modunda görünür
- E-posta — Hem giriş hem kayıtta zorunlu
- Şifre — Zorunlu

**Butonlar:**
- **Giriş Yap / Kayıt Ol** — Formu gönderir; işlem süresince "Giriş yapılıyor..." / "Kaydediliyor..." yazar ve devre dışı kalır
- **Kayıt Ol / Giriş Yap (bağlantı)** — İki mod arasında geçiş yapar

**Geri bildirim:** Hatalı kimlik bilgisi girildiğinde formun altında kırmızı hata mesajı çıkar.

---

### Üst Menü (NavBar) — Her sayfada görünür

- **Workflow Manager** başlığı (sol üst) — Tıklanınca iş akışı listesine döner
- **Workflows** bağlantısı — Liste sayfasına gider; aktif sayfada renk değişir ve alt çizgi çıkar
- **☀️ / 🌙 butonu** — Açık / koyu tema arasında geçiş yapar; tercih kaydedilir
- **Kullanıcı adı** — Giriş yapan kişinin adını gösterir
- **Çıkış Yap butonu** — Oturumu kapatır, giriş sayfasına yönlendirir

---

### İş Akışı Listesi

Tüm iş akışlarınızın listelendiği ana sayfa.

#### Üst Bölüm — Yeni Katılım / Oluşturma

| Element | Ne Yapar |
|---------|----------|
| Davet kodu alanı | Başkasının paylaştığı kodu buraya yazarsınız |
| **İş Akışına Katıl** butonu | Kod girilmeden pasif; girilince katılım talebi gönderir; onay bekler |
| **İş Akışı Oluştur** butonu | "Yeni İş Akışı" modal penceresini açar |
| **İçe Aktar** butonu | JSON dosyası seçme modalını açar |

#### İş Akışı Kartları (grid)

Her kart bir iş akışını temsil eder:

- **Kart başlığı (tıklanabilir)** — O iş akışının kanvas editörünü açar
- **Dışa Aktar butonu** — İş akışını JSON dosyası olarak indirir
- **Sil butonu** — Onay isteyerek kalıcı olarak siler
- **Node sayısı** — Kaç adım var
- **Bağlantı sayısı** — Kaç ok/bağlantı var
- **Oluşturma tarihi**
- **Davet kodu** (varsa) — Üzerine tıklanınca panoya kopyalanır; hover'da renk değişir

**"Yeni İş Akışı Oluştur" modalı:**
- Ad alanı (zorunlu)
- Açıklama alanı (isteğe bağlı)
- **İptal** / **Oluştur** butonları

**"İçe Aktar" modalı:**
- JSON dosya seçici (yalnızca `.json`)
- Seçim sonrası önizleme: ad, açıklama, node sayısı, bağlantı sayısı
- Geçersiz JSON'da hata mesajı
- **İptal** / **İçe Aktar** butonları

---

### Kanvas Editörü

İş akışı tasarımının yapıldığı ana ekran. Birçok bölüme ayrılır.

---

#### Üst Araç Çubuğu (Toolbar)

| Buton / Öge | Ne Yapar |
|-------------|----------|
| İş akışı adı | Sol üstte büyük başlık olarak görünür |
| **Dışa Aktar** | JSON olarak indirir |
| **Kaydet** | Değişiklikleri sunucuya kaydeder (Ctrl+S ile de çalışır) |
| **📨 Davetler** | Sağ tarafta davet talepleri panelini açar/kapatır; bekleyen talep varsa üzerinde kırmızı rozet gösterir (örn: "3") |

---

#### Sol Üst — Kanvas Bilgi Kutusu

Sadece bilgi gösterir, değiştirilmez:
- Zoom yüzdesi (örn: "Zoom: 120%")
- Kanvas konumu (X, Y)
- Toplam node sayısı
- Toplam bağlantı sayısı

---

#### Sol Panel — Node Tipleri

Dört buton — tıklayınca kanvasa o tipte bir node ekler:

| Buton | Renk | Kullanım |
|-------|------|----------|
| **Start** | Mavi | Akışın başlangıç noktası |
| **Process** | Mor | Bir işlem adımı |
| **Decision** | Turuncu | Evet/Hayır dallanma noktası |
| **End** | Yeşil | Akışın bitiş noktası |

---

#### Sol Panel — Node Detayları (bir node seçiliyken görünür)

| Element | Ne Yapar |
|---------|----------|
| **X butonu** | Paneli kapatır |
| Ad alanı | Seçili node'un adını düzenler |
| Açıklama alanı | Node açıklamasını düzenler |
| X / Y sayı alanları | Node'un kanvastaki konumunu sayısal olarak düzenler |
| **Değişiklikleri Kaydet** | Düzenlemeleri uygular; kayıt sırasında "Kaydediliyor..." yazar |
| **Sıfırla** | Alanları önceki değerlere geri döndürür |

---

#### Kanvas Alanı — Node'lar

Her node bir kart olarak görünür.

**Görsel özellikler:**
- Çerçeve rengi tipine göre değişir (mavi / mor / turuncu / yeşil)
- Durum noktası (küçük daire): gri = başlamadı, sarı = devam ediyor, yeşil = tamamlandı
- İlerleme çubuğu — görev tamamlanma oranını gösterir (kırmızı < %50, turuncu %50–79, yeşil ≥ %80)
- Görev özeti: "3 görev (%67)" veya "Görev yok"

**Node üzerindeki etkileşimler:**
| Hareket | Ne Olur |
|---------|---------|
| Tek tıklama | Node seçilir (mavi çerçeve çıkar) |
| Ctrl + tıklama | Çoklu seçime eklenir |
| Çift tıklama | Görev modalı açılır |
| Sürükle (M modu açıkken) | Node taşınır |
| Hover → 🗑️ butonu | Node'u kalıcı olarak siler |
| Connector noktasına tıklama | Bağlantı çizimi başlar |

**Decision node konnektörleri:**
- Sağ üst (%30): **Yes** — yeşil nokta
- Sağ alt (%70): **No** — kırmızı nokta

---

#### Kanvas Alanı — Bağlantılar (Oklar)

- Node'daki çıkış noktasına tıklayıp başka bir node'un giriş noktasına bırakarak çizilir
- Seçilince mavi ve kalın görünür
- **Delete** tuşuyla veya hover'da çıkan silme butonuyla kaldırılır

---

#### Sağ Panel — Davet Yöneticisi (sadece iş akışı sahibine görünür)

| Element | Ne Yapar |
|---------|----------|
| 🔄 Yenile butonu | Bekleyen talepleri yeniden yükler |
| Her talep için **✓ Onayla** | Kişiyi iş akışına üye olarak ekler |
| Her talep için **✗ Reddet** | Talebi reddeder |
| İsim, e-posta, tarih, kod | Talebin kime ait olduğunu gösterir |

---

#### Sağ Alt — Zoom Kontrolleri

| Buton | Ne Yapar |
|-------|----------|
| **−** | %10 yakınlaştırmayı azaltır (minimum %10) |
| **%** göstergesi | Anlık zoom değerini gösterir |
| **+** | %10 yakınlaştırmayı artırır (maksimum %300) |
| **Sıfırla** | Zoom'u %100'e çeker ve kanvası ortalar |

---

#### Görev Modalı (Node'a çift tıklanınca açılır)

Bir node'un görevlerini yönettiğiniz pencere.

**Başlık bölgesi:**
- Node adı
- Node tipi rozeti (renkli)
- **✕ Kapat** butonu

**İlerleme bölgesi:**
- "Genel İlerleme" etiketi
- Yüzde sayısı
- Renkli ilerleme çubuğu

**Görev listesi:**
| Element | Ne Yapar |
|---------|----------|
| Onay kutusu | Görevi tamamlandı/bekliyor olarak işaretler (yalnızca atanan kişi yapabilir) |
| Görev başlığı | Kalın metin |
| Durum rozeti | Kırmızı = bekliyor, Mavi = devam ediyor, Yeşil = tamamlandı |
| Açıklama | Varsa görev altında gösterilir |
| Avatar + isim | Atanan kişiyi gösterir |
| "Ata..." açılır menüsü | Görevi bir üyeye atar |
| ✏️ Düzenle | Formu o görevin verileriyle doldurur |
| 🗑️ Sil | Onay isteyerek görevi siler |

**Tamamlanan görevler** soluk görünür ve üzerleri çizili gösterilir.

**Görev ekleme / düzenleme formu:**
| Alan | Açıklama |
|------|----------|
| Başlık | Zorunlu |
| Açıklama | İsteğe bağlı, 3 satır |
| Durum açılır menüsü | Bekliyor / Devam Ediyor / Tamamlandı |
| Atanan kişi açılır menüsü | Üyeler listesi |
| **İptal** | Düzenleme modundan çıkar |
| **Görevi Ekle / Güncelle** | Kaydeder |

---

### Klavye Kısayolları Özeti

| Kısayol | Eylem |
|---------|-------|
| **Ctrl+S** | Kaydet |
| **Ctrl+Z** | Geri al |
| **Ctrl+Y** veya **Ctrl+Shift+Z** | İleri al |
| **Ctrl+A** | Tümünü seç |
| **Ctrl+C** | Seçili node'ları kopyala |
| **Ctrl+V** | Yapıştır (ofsetli konuma) |
| **M** | Tüm node'lar için sürükleme modunu aç/kapat |
| **F** | Seçili node'a odaklan / ortala |
| **Delete** | Seçili node veya bağlantıyı sil |
| **Mouse tekerleği** | Zoom |
| **Orta fare + sürükle** | Kanvası kaydır |

---

## Eksik / Geliştirilebilecek Alanlar

- [ ] WebSocket ile gerçek zamanlı işbirliği
- [ ] Test kapsamı (Jest yapılandırıldı ama testler yazılmadı)
- [ ] CI/CD pipeline
- [ ] Swagger/OpenAPI dokümantasyonu
- [ ] E-posta bildirimleri
- [ ] İş akışı versiyonlama/geçmiş
- [ ] Otomasyon motoru (şu an yalnızca görsel — çalıştırma yok)
- [ ] CORS kısıtlaması (şu an tüm origin'lere açık)
- [ ] Request validation şemaları (Joi/Yup)
