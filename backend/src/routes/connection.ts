import { Router } from 'express';
import { ConnectionService } from '../services/ConnectionService';

const router = Router();
const connectionService = new ConnectionService();

// Get connections by workflow
router.get('/workflow/:workflowId', async (req, res) => {
  try {
    const connections = await connectionService.getConnectionsByWorkflow(req.params.workflowId);
    res.json(connections);
  } catch (error) {
    res.status(404).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
}); 

// Get connection by ID
router.get('/:id', async (req, res) => {
  try {
    const connection = await connectionService.getConnectionById(req.params.id);
    res.json(connection);
  } catch (error) {
    res.status(404).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

// Create connection in workflow
router.post('/workflow/:workflowId', async (req, res) => {
  try {
    const connection = await connectionService.createConnection(req.params.workflowId, req.body);
    res.status(201).json(connection);
  } catch (error) {
    res.status(400).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

// Update connection
router.put('/:id', async (req, res) => {
  try {
    const connection = await connectionService.updateConnection(req.params.id, req.body);
    res.json(connection);
  } catch (error) {
    res.status(400).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

// Delete connection
router.delete('/:id', async (req, res) => {
  try {
    await connectionService.deleteConnection(req.params.id);
    res.status(204).send();
  } catch (error) {
    res.status(400).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

export default router;