# Claude Code - Workflow Manager Proje Analizi

## 📋 Proje Özeti
**Workflow Manager** - Gelişmiş iş akışı yönetim uygulaması (Trello + n8n mantığı)

- **Proje Tipi**: Full-stack web uygulaması
- **Mimari**: REST API Backend + SPA Frontend
- **Durum**: Geliştirme aşamasında
- **Platform**: Web (Cross-platform)

## 🏗️ Teknoloji Stack

### Backend (Node.js)
```
Framework: Express.js + TypeScript
Database: PostgreSQL + TypeORM
Auth: JWT + bcryptjs
Security: Helmet, CORS
File Upload: Multer
```

### Frontend (Vue.js)
```
Framework: Vue 3 + TypeScript + Vite
State: Pinia
Router: Vue Router
Canvas: Konva.js + vue-konva
UI: Custom components
```

## 📂 Proje Yapısı

```
workflow-manager/
├── backend/                 # API Server (Port: 3000)
│   ├── src/
│   │   ├── models/         # TypeORM Entities (User, Workflow, Node, etc.)
│   │   ├── services/       # Business Logic Layer
│   │   ├── routes/         # API Endpoints (/api/*)
│   │   ├── middleware/     # Auth Middleware
│   │   └── config/         # Database Configuration
│   ├── database.sql        # PostgreSQL Schema
│   └── package.json        # Dependencies
│
├── frontend/               # Vue SPA (Port: 5173)
│   ├── src/
│   │   ├── screens/       # Ana sayfalar (Login, Canvas, WorkflowList)
│   │   ├── widgets/       # UI Bileşenleri (Toolbar, Modal, etc.)
│   │   ├── services/      # API İstemcileri
│   │   ├── stores/        # Pinia State Management
│   │   └── models/        # TypeScript Type Definitions
│   └── package.json       # Dependencies
```

## 🗄️ Veritabanı Şeması

### Ana Tablolar
- **users**: Kullanıcı yönetimi (id, email, name, role, status)
- **workflows**: İş akışları (id, name, description, metadata, created_by)
- **nodes**: Workflow düğümleri (id, type: start|process|decision|end)
- **connections**: Düğümler arası bağlantılar
- **tasks**: Görev yönetimi ve atama
- **files**: Dosya yükleme ve saklama

## 🎯 Ana Özellikler

### ✅ Mevcut Özellikler
- Canvas tabanlı workflow tasarımı (Konva.js)
- 4 tip düğüm sistemi (Start, Process, Decision, End)
- JWT tabanlı kimlik doğrulama
- Kullanıcı rol yönetimi (admin/user)
- Görev atama ve ilerleme takibi
- Dosya yükleme sistemi
- JSON import/export
- PostgreSQL veritabanı entegrasyonu

### 🔧 Geliştirme Komutları

#### Backend
```bash
cd backend
npm install
npm run dev          # Development server
npm run build        # Production build
npm run typecheck    # Type checking
npm run lint         # ESLint
```

#### Frontend
```bash
cd frontend
npm install
npm run dev          # Development server (localhost:5173)
npm run build        # Production build
npm run typecheck    # Vue type checking
npm run lint         # ESLint
```

#### Database Setup
```sql
CREATE DATABASE workflow_manager;
CREATE USER workflow_user WITH PASSWORD 'workflow_pass';
GRANT ALL PRIVILEGES ON DATABASE workflow_manager TO workflow_user;
```

## 🔐 Environment Variables

Backend `.env` dosyası:
```
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=workflow_user
DB_PASSWORD=workflow_pass
DB_DATABASE=workflow_manager
JWT_SECRET=your_jwt_secret
```

## 📡 API Endpoints

```
POST   /api/auth/login         # Kullanıcı girişi
POST   /api/auth/register      # Kullanıcı kaydı
GET    /api/workflows          # Workflow listesi
POST   /api/workflows          # Yeni workflow
GET    /api/nodes              # Node listesi
POST   /api/nodes              # Yeni node
GET    /api/connections        # Connection listesi
POST   /api/connections        # Yeni connection
GET    /health                 # Health check
```

## 🎨 Frontend Ekranlar

- **LoginScreen**: Kullanıcı girişi
- **WorkflowListScreen**: Workflow yönetimi
- **CanvasScreen**: Workflow tasarım editörü

## 📝 Geliştirme Notları

### Kod Kalitesi
- TypeScript kullanımı hem backend hem frontend
- ESLint konfigürasyonu mevcut
- Modüler yapı ve separation of concerns
- TypeORM ile type-safe database operations

### Güvenlik
- JWT token authentication
- Password hashing (bcryptjs)
- Helmet.js güvenlik headers
- CORS konfigürasyonu

### Performance
- Vite build tool (hızlı HMR)
- Canvas optimizasyonu (Konva.js)
- Database indexing (UUID primary keys)

## 🚀 Production Deployment

PM2 ile production:
```bash
npm run build
pm2 start ecosystem.config.js
```

## 🐛 Bilinen Sorunlar / TODO
- [ ] Test coverage eksik
- [ ] Docker containerization
- [ ] CI/CD pipeline kurulumu
- [ ] API documentation (Swagger)
- [ ] Real-time collaboration (WebSocket)

---
*Bu dosya Claude Code tarafından proje analizi sonrası oluşturulmuştur.*