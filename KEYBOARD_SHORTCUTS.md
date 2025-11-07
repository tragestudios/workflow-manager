# Klavye Kısayolları

Bu doküman, Workflow Manager uygulamasında kullanılabilen klavye kısayollarını açıklar.

## Genel Kısayollar

### Kaydetme ve Geri Alma

| Kısayol | Açıklama |
|---------|----------|
| `Ctrl + S` | Workflow'u kaydet - Tüm değişiklikleri backend'e kaydeder ve senkronize eder |
| `Ctrl + Z` | Geri al (Undo) - Son yapılan değişikliği geri alır (sadece local, Ctrl+S ile kaydetmelisiniz) |
| `Ctrl + Y` veya `Ctrl + Shift + Z` | İleri al (Redo) - Geri alınan değişikliği tekrar uygular |

### Canvas Kontrolleri

| Kısayol | Açıklama |
|---------|----------|
| `M` | Hareket modu - Node'ları hareket ettirme modunu açar/kapatır. Aktifken node'lar üzerinde yeşil el ikonu görünür |
| `Orta Fare Tuşu` | Canvas'ı kaydır - Orta fare tuşuna basılı tutarak canvas'ı her yöne kaydırabilirsiniz |
| `Fare Tekerleği` | Yakınlaştır/Uzaklaştır - Canvas üzerinde zoom yapar |

### Silme İşlemleri

| Kısayol | Açıklama |
|---------|----------|
| `Delete` veya `Del` | Sil - Seçili node'ları veya bağlantıları siler |
| `Hover + Çöp Kovası` | Sil - Node veya bağlantı üzerine gelince çıkan çöp kovası butonuna tıklayarak da silebilirsiniz |

## Node İşlemleri

### Node Seçimi

- **Sol Tık**: Tek bir node'u seçer
- **Ctrl + Sol Tık**: Çoklu seçim - Birden fazla node'u seçebilirsiniz
- **Boş Alana Tık**: Tüm seçimleri temizler

### Node Taşıma

1. `M` tuşuna basarak hareket modunu aktifleştirin
2. Node'un üzerine tıklayıp sürükleyin
3. Yeni pozisyonda bırakın
4. `Ctrl + S` ile değişiklikleri kaydedin

### Node Silme

1. Silinecek node'u seçin
2. `Delete` tuşuna basın veya hover ile çıkan çöp kovası butonuna tıklayın
3. `Ctrl + S` ile değişiklikleri kaydedin

## Bağlantı İşlemleri

### Bağlantı Oluşturma

1. Kaynak node'un **çıkış noktası** (sağ taraftaki yuvarlak) üzerine tıklayın
2. Hedef node'un **giriş noktası** (sol taraftaki yuvarlak) üzerine tıklayın
3. Bağlantı otomatik olarak oluşturulur

### Decision Node Bağlantıları

Decision node'larında iki ayrı çıkış noktası vardır:
- **Yes** (Üst çıkış) - Evet durumu için
- **No** (Alt çıkış) - Hayır durumu için

Her iki çıkış da ayrı ayrı bağlantı oluşturabilir.

### Bağlantı Silme

1. Silinecek bağlantıya tıklayarak seçin
2. `Delete` tuşuna basın veya hover ile çıkan çöp kovası butonuna tıklayın
3. `Ctrl + S` ile değişiklikleri kaydedin

## İpuçları

### Undo/Redo Kullanımı

- Undo/Redo işlemleri sadece **local state**'i değiştirir
- Backend'e kaydedilmez, sadece ekranda görüntülenir
- Değişiklikleri kalıcı hale getirmek için `Ctrl + S` yapmalısınız
- Son 50 işlem hafızada tutulur

### Performans İpuçları

- Büyük değişiklikler yaptıktan sonra mutlaka `Ctrl + S` yapın
- Sık sık kaydetmek veri kaybını önler
- Undo stack'i 50 işlemle sınırlıdır, bu yüzden önemli değişikliklerden önce kaydedin

### Canvas Gezinme

- Orta fare tuşu ile canvas'ı rahatça kaydırabilirsiniz
- Fare tekerleği ile hızlıca zoom yapabilirsiniz
- `M` tuşu ile hareket modunu açıp kapatarak node düzenleme yapabilirsiniz

## Sık Kullanılan İş Akışları

### Node Ekleme ve Düzenleme

1. Sol panelden node tipini seçin ve canvas'a sürükleyin
2. Node'u seçin ve detaylarını sağ panelden düzenleyin
3. `M` tuşu ile hareket modunu açın
4. Node'u istediğiniz pozisyona taşıyın
5. `Ctrl + S` ile kaydedin

### Workflow Düzenleme

1. Node'ları ekleyin ve konumlandırın
2. Bağlantıları oluşturun
3. Hataları `Ctrl + Z` ile düzeltin
4. Her şey hazır olunca `Ctrl + S` ile kaydedin

### Hızlı Silme ve Düzenleme

1. Silinecek öğeleri seçin (Ctrl ile çoklu seçim)
2. `Delete` tuşuna basın
3. Gerekirse `Ctrl + Z` ile geri alın
4. `Ctrl + S` ile son halini kaydedin
