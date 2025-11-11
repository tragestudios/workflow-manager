import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import { AppDataSource } from './config/database';
import { authenticateToken } from './middleware/auth';
import authRoutes from './routes/auth';
import workflowRoutes from './routes/workflow';
import userRoutes from './routes/user';
import nodeRoutes from './routes/node';
import connectionRoutes from './routes/connection';
import invitationRoutes from './routes/invitation';
import taskRoutes from './routes/task';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

app.use('/api/auth', authRoutes);
app.use('/api/workflows', authenticateToken, workflowRoutes);
app.use('/api/users', authenticateToken, userRoutes);
app.use('/api/nodes', authenticateToken, nodeRoutes);
app.use('/api/connections', authenticateToken, connectionRoutes);
app.use('/api/invitations', authenticateToken, invitationRoutes);
app.use('/api/tasks', authenticateToken, taskRoutes);

app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Error handling middleware
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    error: err.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

AppDataSource.initialize()
  .then(() => {
    console.log('Database connection established');
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  })
  .catch((error) => {
    console.error('Database connection failed:', error);
    process.exit(1);
  });