import { Router } from 'express';
import { NodeService } from '../services/NodeService';

const router = Router();
const nodeService = new NodeService();

// Get nodes by workflow
router.get('/workflow/:workflowId', async (req, res) => {
  try {
    const nodes = await nodeService.getNodesByWorkflow(req.params.workflowId);
    res.json(nodes);
  } catch (error) {
    res.status(404).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

// Get node by ID
router.get('/:id', async (req, res) => {
  try {
    const node = await nodeService.getNodeById(req.params.id);
    res.json(node);
  } catch (error) {
    res.status(404).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

// Create node in workflow
router.post('/workflow/:workflowId', async (req, res) => {
  try {
    const node = await nodeService.createNode(req.params.workflowId, req.body);
    res.status(201).json(node);
  } catch (error) {
    res.status(400).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

// Update node
router.put('/:id', async (req, res) => {
  try {
    const node = await nodeService.updateNode(req.params.id, req.body);
    res.json(node);
  } catch (error) {
    res.status(400).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

// Delete node
router.delete('/:id', async (req, res) => {
  try {
    await nodeService.deleteNode(req.params.id);
    res.status(204).send();
  } catch (error) {
    res.status(400).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

export default router;