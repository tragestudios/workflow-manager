import { Router } from 'express';
import { TaskService } from '../services/TaskService';

const router = Router();
const taskService = new TaskService();

// Get tasks for a specific node
router.get('/node/:nodeId', async (req, res) => {
  try {
    const tasks = await taskService.getNodeTasks(req.params.nodeId);
    res.json(tasks);
  } catch (error) {
    res.status(500).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

// Get a specific task
router.get('/:taskId', async (req, res) => {
  try {
    const task = await taskService.getTaskById(req.params.taskId);
    res.json(task);
  } catch (error) {
    res.status(404).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

// Create a new task for a node
router.post('/node/:nodeId', async (req, res) => {
  try {
    const task = await taskService.createTask(req.params.nodeId, req.body);
    res.status(201).json(task);
  } catch (error) {
    res.status(400).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

// Update a task
router.put('/:taskId', async (req, res) => {
  try {
    const task = await taskService.updateTask(req.params.taskId, req.body);
    res.json(task);
  } catch (error) {
    res.status(400).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

// Delete a task
router.delete('/:taskId', async (req, res) => {
  try {
    await taskService.deleteTask(req.params.taskId);
    res.status(204).send();
  } catch (error) {
    res.status(400).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

// Assign a task to a user
router.post('/:taskId/assign', async (req, res) => {
  try {
    const { userId } = req.body;
    const task = await taskService.assignTask(req.params.taskId, userId);
    res.json(task);
  } catch (error) {
    res.status(400).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

export default router;
