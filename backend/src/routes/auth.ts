import { Router } from 'express';
import { AuthService } from '../services/AuthService';
import { UserService } from '../services/UserService';

const router = Router();
const authService = new AuthService();
const userService = new UserService();

router.post('/register', async (req, res) => {
  try {
    const { email, name, password } = req.body;
    const user = await authService.register(email, name, password);
    res.status(201).json({ user, message: 'User registered successfully' });
  } catch (error) {
    res.status(400).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const result = await authService.login(email, password);
    res.json(result);
  } catch (error) {
    res.status(401).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

router.post('/invite', async (req, res) => {
  try {
    const { email, name } = req.body;
    const invitation = await authService.inviteUser(email, name, req.user!.id);
    res.json({ invitation, message: 'Invitation sent successfully' });
  } catch (error) {
    res.status(400).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

router.post('/approve/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await userService.approveUser(userId);
    res.json({ user, message: 'User approved successfully' });
  } catch (error) {
    res.status(400).json({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
});

export default router;