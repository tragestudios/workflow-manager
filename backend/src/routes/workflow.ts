import { Router } from 'express';
import { WorkflowService } from '../services/WorkflowService';

const router = Router();
const workflowService = new WorkflowService();

router.get('/', async (req, res) => {
  try {
    const workflows = await workflowService.getWorkflows(req.user!.id);
    res.json(workflows);
  } catch (error) {
    res.status(500).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const workflow = await workflowService.getWorkflowById(req.params.id);
    res.json(workflow);
  } catch (error) {
    res.status(404).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

router.post('/', async (req, res) => {
  try {
    const workflow = await workflowService.createWorkflow(req.body, req.user!.id);
    res.status(201).json(workflow);
  } catch (error) {
    res.status(400).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

router.put('/:id', async (req, res) => {
  try {
    const workflow = await workflowService.updateWorkflow(req.params.id, req.body);
    res.json(workflow);
  } catch (error) {
    res.status(400).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await workflowService.deleteWorkflow(req.params.id);
    res.status(204).send();
  } catch (error) {
    res.status(400).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

router.post('/:id/export', async (req, res) => {
  try {
    const json = await workflowService.exportWorkflow(req.params.id);
    res.json(json);
  } catch (error) {
    res.status(400).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

router.post('/import', async (req, res) => {
  try {
    const workflow = await workflowService.importWorkflow(req.body, req.user!.id);
    res.status(201).json(workflow);
  } catch (error) {
    res.status(400).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

// Get workflow members
router.get('/:id/members', async (req, res) => {
  try {
    const members = await workflowService.getWorkflowMembers(req.params.id);
    res.json(members);
  } catch (error) {
    res.status(500).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

export default router;