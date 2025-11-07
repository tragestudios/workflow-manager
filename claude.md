# Workflow Manager - Claude Hızlı Referans

## 📁 Proje Yapısı

```
workflow-manager/
├── backend/                    # Node.js + Express + TypeORM
│   ├── src/
│   │   ├── models/            # TypeORM Entity'ler
│   │   │   ├── User.ts
│   │   │   ├── Workflow.ts
│   │   │   ├── Node.ts
│   │   │   ├── Connection.ts
│   │   │   ├── Task.ts
│   │   │   ├── File.ts
│   │   │   ├── WorkflowInvitation.ts
│   │   │   └── WorkflowMember.ts
│   │   ├── services/          # İş mantığı
│   │   │   ├── AuthService.ts
│   │   │   ├── UserService.ts
│   │   │   ├── WorkflowService.ts
│   │   │   ├── NodeService.ts
│   │   │   └── ConnectionService.ts
│   │   ├── routes/            # API endpoint'ler
│   │   │   ├── auth.ts
│   │   │   ├── user.ts
│   │   │   ├── workflow.ts
│   │   │   ├── node.ts
│   │   │   ├── connection.ts
│   │   │   └── invitation.ts
│   │   ├── middleware/
│   │   │   └── auth.ts        # JWT middleware
│   │   ├── config/
│   │   │   └── database.ts    # TypeORM config
│   │   └── app.ts             # Express app
│   ├── database.sql           # PostgreSQL schema
│   ├── tsconfig.json
│   └── package.json
│
└── frontend/                   # Vue 3 + TypeScript + Vite
    ├── src/
    │   ├── screens/           # Ana sayfalar
    │   │   ├── LoginScreen.vue
    │   │   ├── WorkflowListScreen.vue
    │   │   └── CanvasScreen.vue
    │   ├── widgets/           # UI bileşenleri
    │   │   ├── WorkflowCanvas.vue
    │   │   ├── WorkflowNode.vue
    │   │   ├── WorkflowConnection.vue
    │   │   ├── CanvasToolbar.vue
    │   │   ├── NodeTypesWidget.vue
    │   │   ├── NodeDetailsWidget.vue
    │   │   ├── InvitationManagerWidget.vue
    │   │   ├── CreateWorkflowModal.vue
    │   │   └── ImportWorkflowModal.vue
    │   ├── services/          # API istemcileri
    │   │   ├── ApiClient.ts
    │   │   ├── AuthService.ts
    │   │   ├── WorkflowService.ts
    │   │   ├── NodeService.ts
    │   │   └── ConnectionService.ts
    │   ├── stores/            # Pinia stores
    │   │   ├── auth.ts
    │   │   ├── workflow.ts
    │   │   └── canvas.ts
    │   ├── models/            # TypeScript types
    │   ├── components/
    │   │   └── NavBar.vue
    │   └── App.vue
    ├── vite.config.ts
    ├── tsconfig.json
    └── package.json
```

## 🗄️ Veritabanı Şeması

### Ana Tablolar
- **users** - Kullanıcı yönetimi (id, email, name, password, role, status, invited_by)
- **workflows** - İş akışları (id, name, description, metadata, created_by_id, invite_code)
- **nodes** - Workflow düğümleri (id, name, type, status, position, workflow_id)
- **connections** - Düğüm bağlantıları (id, source_node_id, target_node_id, workflow_id)
- **tasks** - Görevler (id, title, status, node_id, assigned_to_id)
- **files** - Dosyalar (id, filename, mime_type, node_id)
- **workflow_invitations** - Davetiyeler
- **workflow_members** - Workflow üyeleri

### Enum'lar
```typescript
// User
UserRole: 'admin' | 'user'
UserStatus: 'pending' | 'active' | 'inactive'

// Node
NodeType: 'start' | 'process' | 'decision' | 'end'
NodeStatus: 'not_started' | 'in_progress' | 'completed'

// Task
TaskStatus: 'pending' | 'in_progress' | 'completed'
```

## 🔌 API Endpoints

### Auth
- `POST /api/auth/register` - Kullanıcı kaydı
- `POST /api/auth/login` - Giriş
- `POST /api/auth/invite` - Kullanıcı davet et
- `POST /api/auth/approve/:userId` - Kullanıcı onayla

### Workflows
- `GET /api/workflows` - Workflow listesi
- `GET /api/workflows/:id` - Workflow detayı
- `GET /api/workflows/:id/members` - Workflow üyeleri (YENI)
- `POST /api/workflows` - Yeni workflow
- `PUT /api/workflows/:id` - Workflow güncelle
- `DELETE /api/workflows/:id` - Workflow sil
- `POST /api/workflows/:id/export` - Export JSON
- `POST /api/workflows/import` - Import JSON

### Nodes
- `GET /api/nodes` - Node listesi
- `POST /api/nodes` - Yeni node
- `PUT /api/nodes/:id` - Node güncelle
- `DELETE /api/nodes/:id` - Node sil

### Connections
- `GET /api/connections` - Connection listesi
- `POST /api/connections` - Yeni connection
- `DELETE /api/connections/:id` - Connection sil

### Tasks (YENI)
- `GET /api/tasks/node/:nodeId` - Node'a ait task'lar
- `GET /api/tasks/:taskId` - Task detayı
- `POST /api/tasks/node/:nodeId` - Yeni task (otomatik progress hesapla)
- `PUT /api/tasks/:taskId` - Task güncelle (otomatik progress hesapla)
- `DELETE /api/tasks/:taskId` - Task sil (otomatik progress hesapla)
- `POST /api/tasks/:taskId/assign` - Task'a kullanıcı ata

### Invitations
- `POST /api/invitations/request` - Davetiye talep et
- `GET /api/invitations/pending/:workflowId` - Bekleyen davetiyeler
- `POST /api/invitations/approve` - Davetiye onayla
- `POST /api/invitations/reject` - Davetiye reddet

## 🛠️ Geliştirme Komutları

### Backend
```bash
cd backend
npm install
npm run dev          # Development server (Port 3000)
npm run build        # Production build
npm run typecheck    # Type checking
npm run lint         # ESLint
```

### Frontend
```bash
cd frontend
npm install
npm run dev          # Development server (Port 5173)
npm run build        # Production build
npm run typecheck    # Vue type checking
npm run lint         # ESLint
```

### Database
```bash
# PostgreSQL
psql -U postgres
CREATE DATABASE workflow_manager;
CREATE USER workflow_user WITH PASSWORD 'workflow_pass';
GRANT ALL PRIVILEGES ON DATABASE workflow_manager TO workflow_user;

# Run schema
psql -U workflow_user -d workflow_manager -f backend/database.sql
```

## 🔐 Environment Variables

### Backend (.env)
```env
PORT=3000
NODE_ENV=development

DB_TYPE=postgres
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=workflow_user
DB_PASSWORD=workflow_pass
DB_DATABASE=workflow_manager

JWT_SECRET=your_jwt_secret_here
JWT_EXPIRES_IN=7d
```

## 🎨 Frontend Yapısı

### Stores (Pinia)
- **auth.ts** - Kullanıcı kimlik doğrulama, token yönetimi
- **workflow.ts** - Workflow CRUD işlemleri
- **canvas.ts** - Canvas state, zoom, pan, node seçimi

### Screens
- **LoginScreen** - Giriş/Kayıt
- **WorkflowListScreen** - Workflow yönetimi, create/import/export
- **CanvasScreen** - Workflow canvas editör

### Widgets
- **WorkflowCanvas** - Konva.js canvas container
- **WorkflowNode** - Node bileşeni (double-click → task modal)
- **WorkflowConnection** - Bağlantı çizgileri
- **CanvasToolbar** - Üst araç çubuğu
- **NodeTypesWidget** - Node tipleri paleti
- **NodeDetailsWidget** - Seçili node detayları
- **InvitationManagerWidget** - Davetiye yönetimi
- **NodeTaskModal** - Task yönetim modal'ı (YENI)

## 🔑 Önemli Dosyalar

### Backend
- `backend/src/app.ts` - Express app entry point
- `backend/src/config/database.ts` - TypeORM DataSource
- `backend/src/middleware/auth.ts` - JWT authenticateToken middleware
- `backend/database.sql` - Tam PostgreSQL schema

### Frontend
- `frontend/src/App.vue` - Ana Vue app
- `frontend/src/services/ApiClient.ts` - Axios HTTP client (interceptors ile)
- `frontend/vite.config.ts` - Path aliases (@/screens, @/widgets, vb.)

## 🔄 Akış

### Login Flow
1. User → LoginScreen → AuthService.login()
2. Backend → AuthService.login() → JWT token üret
3. Frontend → Token'ı localStorage'a kaydet
4. Frontend → AuthStore'da user bilgisini sakla
5. Redirect → WorkflowListScreen

### Workflow Creation
1. WorkflowListScreen → CreateWorkflowModal
2. WorkflowStore.createWorkflow() → POST /api/workflows
3. Backend → WorkflowService.createWorkflow()
4. Backend → Otomatik invite_code üret
5. Frontend → Yeni workflow ile canvas'a redirect

### Invitation Flow
1. User → Invite code gir → POST /api/invitations/request
2. Backend → WorkflowInvitation oluştur (status: pending)
3. Owner → InvitationManagerWidget'ta bekleyenleri görür
4. Owner → Approve/Reject → POST /api/invitations/approve
5. Backend → WorkflowMember oluştur (onaylanırsa)

### Task Management Flow (YENI)
1. User → Node'a double-click
2. Frontend → NodeTaskModal açılır
3. Modal → GET /api/tasks/node/:nodeId (task'ları getir)
4. Modal → GET /api/workflows/:id/members (üyeleri getir)
5. User → Task oluştur → POST /api/tasks/node/:nodeId
6. Backend → TaskService.createTask() → Node progress güncelle
7. User → Task'a kullanıcı ata → POST /api/tasks/:id/assign
8. **Atanan kullanıcı → Checkbox toggle (sadece atanan kişi yapabilir)**
9. Backend → Task status güncelle → Node progress yeniden hesapla
10. Frontend → Node üzerinde renkli progress bar güncellenir

## 🎯 Özellikler

✅ **Mevcut**
- Canvas-based workflow designer (Konva.js)
- Drag & drop node positioning
- 4 node tipi (start, process, decision, end)
- Node connections
- JWT authentication
- User invitation system
- Workflow invite codes
- JSON import/export
- **Task Management System (YENI)**
  - Node'a double-click ile task modal açma
  - Task CRUD işlemleri (create, read, update, delete)
  - Workflow üyelerine task atama
  - **Permission: Sadece atanan kişi task'ı complete/incomplete yapabilir**
  - Task durumu: pending, in_progress, completed
  - Node progress otomatik hesaplama (task completion'a göre)
  - Renkli progress bar (0-50%: 🔴, 50-80%: 🟠, 80-100%: 🟢)
- File attachments
- Progress tracking

⏳ **Eksik/TODO**
- WebSocket real-time collaboration
- Test coverage (Jest)
- Docker containerization
- API documentation (Swagger)
- CI/CD pipeline
- Email notifications
- Advanced permissions

## 🚀 Production

```bash
# Build
npm run build

# PM2
pm2 start ecosystem.config.js
pm2 logs
pm2 status
```

## 🐛 Önemli Notlar

1. **TypeORM Sync**: Development'ta `synchronize: true`, production'da `false` olmalı
2. **CORS**: Backend'de tüm origin'lere açık, production'da kısıtlanmalı
3. **JWT Secret**: .env'de güçlü bir secret kullanılmalı
4. **Database Migrations**: TypeORM migration'ları `database_migrations/` klasöründe
5. **Path Aliases**: Her iki projede de @ aliasları kullanılıyor (tsconfig.json)

## 📦 Dependencies

### Backend Ana Paketler
- express, cors, helmet
- typeorm, pg
- bcryptjs, jsonwebtoken
- multer (file upload)

### Frontend Ana Paketler
- vue, vue-router, pinia
- axios
- konva, vue-konva
- @vueuse/core

## 🔍 Hızlı Arama

```bash
# Backend model bul
backend/src/models/*.ts

# Frontend servis bul
frontend/src/services/*.ts

# API route bul
backend/src/routes/*.ts

# Vue component bul
frontend/src/widgets/*.vue
frontend/src/screens/*.vue

# Database migration bul
database_migrations/*.sql
```
