# Workflow Manager

Gelişmiş iş akışı yönetim uygulaması - Trello ve n8n mantığını birleştiren profesyonel çözüm.

## Özellikler

- Akıcı canvas ile workflow tasarımı
- Düğüm tabanlı iş akışı sistemi (Başlangıç, İşlem, Karar, Bitiş)
- Görev atama ve ilerleme takibi
- Dosya yükleme ve not ekleme
- JSON import/export
- Kullanıcı yönetimi ve yetkilendirme
- PostgreSQL veritabanı desteği

## Teknolojiler

### Backend
- Node.js + Express.js + TypeScript
- PostgreSQL
- TypeORM
- JWT Authentication

### Frontend
- Vue.js 3
- Pinia (State Management)
- Konva.js (Canvas)
- TypeScript

## Kurulum

### 1. Backend Kurulumu

```bash
cd backend
npm install
cp .env.example .env
# .env dosyasını veritabanı bilgilerinizle güncelleyin
npm run dev
```

### 2. Frontend Kurulumu

```bash
cd frontend
npm install
npm run dev
```

### 3. Veritabanı Kurulumu

PostgreSQL kurulup çalıştırıldıktan sonra:

```sql
CREATE DATABASE workflow_manager;
CREATE USER workflow_user WITH PASSWORD 'workflow_pass';
GRANT ALL PRIVILEGES ON DATABASE workflow_manager TO workflow_user;
```

## Geliştirme

Backend: http://localhost:3000
Frontend: http://localhost:5173

## Üretim Dağıtımı

PM2 ile production dağıtımı için:

```bash
npm run build
pm2 start ecosystem.config.js
```