import { Router } from 'express';
import { AppDataSource } from '../config/database';
import { WorkflowInvitation, InvitationStatus } from '../models/WorkflowInvitation';
import { Workflow } from '../models/Workflow';
import { User } from '../models/User';
import { WorkflowMember, MemberRole } from '../models/WorkflowMember';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// Create invitation by code
router.post('/request', authenticateToken, async (req, res) => {
  try {
    const { inviteCode } = req.body;
    const userId = req.user?.id;

    if (!userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }

    if (!inviteCode) {
      return res.status(400).json({ error: 'Invite code is required' });
    }

    // Find workflow by invite code
    const workflowRepo = AppDataSource.getRepository(Workflow);
    const workflow = await workflowRepo.findOne({
      where: { inviteCode: inviteCode.toUpperCase() },
      relations: ['createdBy']
    });

    if (!workflow) {
      return res.status(404).json({ error: 'Invalid invite code' });
    }

    // Check if user is already the owner
    if (workflow.createdById === userId) {
      return res.status(400).json({ error: 'You cannot invite yourself to your own workflow' });
    }

    // Check if invitation already exists
    const invitationRepo = AppDataSource.getRepository(WorkflowInvitation);
    const existingInvitation = await invitationRepo.findOne({
      where: {
        workflowId: workflow.id,
        invitedUserId: userId,
        status: InvitationStatus.PENDING
      }
    });

    if (existingInvitation) {
      return res.status(400).json({ error: 'You already have a pending invitation for this workflow' });
    }

    // Create new invitation request
    const invitation = new WorkflowInvitation();
    invitation.inviteCode = inviteCode.toUpperCase();
    invitation.workflowId = workflow.id;
    invitation.invitedById = workflow.createdById;
    invitation.invitedUserId = userId;
    invitation.status = InvitationStatus.PENDING;

    await invitationRepo.save(invitation);

    const savedInvitation = await invitationRepo.findOne({
      where: { id: invitation.id },
      relations: ['workflow', 'invitedBy', 'invitedUser']
    });

    res.json({
      message: 'Invitation request sent successfully',
      invitation: savedInvitation
    });
  } catch (error) {
    console.error('Error creating invitation request:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get pending invitations for workflow owner
router.get('/pending/:workflowId', authenticateToken, async (req, res) => {
  try {
    const { workflowId } = req.params;
    const userId = req.user?.id;

    if (!userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }

    // Verify user owns the workflow
    const workflowRepo = AppDataSource.getRepository(Workflow);
    const workflow = await workflowRepo.findOne({
      where: { id: workflowId, createdById: userId }
    });

    if (!workflow) {
      return res.status(404).json({ error: 'Workflow not found or you do not have permission' });
    }

    const invitationRepo = AppDataSource.getRepository(WorkflowInvitation);
    const pendingInvitations = await invitationRepo.find({
      where: {
        workflowId,
        status: InvitationStatus.PENDING
      },
      relations: ['invitedUser'],
      order: { createdAt: 'DESC' }
    });

    res.json(pendingInvitations);
  } catch (error) {
    console.error('Error fetching pending invitations:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Approve or reject invitation
router.patch('/:invitationId/respond', authenticateToken, async (req, res) => {
  try {
    const { invitationId } = req.params;
    const { action } = req.body; // 'approve' or 'reject'
    const userId = req.user?.id;

    if (!userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }

    if (!['approve', 'reject'].includes(action)) {
      return res.status(400).json({ error: 'Action must be approve or reject' });
    }

    const invitationRepo = AppDataSource.getRepository(WorkflowInvitation);
    const invitation = await invitationRepo.findOne({
      where: { id: invitationId },
      relations: ['workflow', 'invitedUser']
    });

    if (!invitation) {
      return res.status(404).json({ error: 'Invitation not found' });
    }

    // Verify user owns the workflow
    if (invitation.invitedById !== userId) {
      return res.status(403).json({ error: 'You do not have permission to respond to this invitation' });
    }

    if (invitation.status !== InvitationStatus.PENDING) {
      return res.status(400).json({ error: 'Invitation has already been responded to' });
    }

    invitation.status = action === 'approve' ? InvitationStatus.APPROVED : InvitationStatus.REJECTED;
    invitation.respondedAt = new Date();
    invitation.isUsed = action === 'approve';

    await invitationRepo.save(invitation);

    // If approved, add user to workflow members
    if (action === 'approve' && invitation.invitedUserId) {
      const memberRepo = AppDataSource.getRepository(WorkflowMember);

      // Check if user is already a member (to avoid duplicates)
      const existingMember = await memberRepo.findOne({
        where: {
          workflowId: invitation.workflowId,
          userId: invitation.invitedUserId
        }
      });

      if (!existingMember) {
        const member = new WorkflowMember();
        member.workflowId = invitation.workflowId;
        member.userId = invitation.invitedUserId;
        member.role = MemberRole.MEMBER;

        await memberRepo.save(member);
      }
    }

    res.json({
      message: `Invitation ${action}d successfully`,
      invitation
    });
  } catch (error) {
    console.error('Error responding to invitation:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get user's invitations (both sent and received)
router.get('/my', authenticateToken, async (req, res) => {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }
    const invitationRepo = AppDataSource.getRepository(WorkflowInvitation);

    // Get invitations received by user
    const receivedInvitations = await invitationRepo.find({
      where: { invitedUserId: userId },
      relations: ['workflow', 'invitedBy'],
      order: { createdAt: 'DESC' }
    });

    // Get invitations sent by user (workflows they own)
    const sentInvitations = await invitationRepo.find({
      where: { invitedById: userId },
      relations: ['workflow', 'invitedUser'],
      order: { createdAt: 'DESC' }
    });

    res.json({
      received: receivedInvitations,
      sent: sentInvitations
    });
  } catch (error) {
    console.error('Error fetching user invitations:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get workflow invite code
router.get('/code/:workflowId', authenticateToken, async (req, res) => {
  try {
    const { workflowId } = req.params;
    const userId = req.user?.id;

    if (!userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }

    const workflowRepo = AppDataSource.getRepository(Workflow);
    const workflow = await workflowRepo.findOne({
      where: { id: workflowId, createdById: userId },
      relations: ['createdBy']
    });

    if (!workflow) {
      return res.status(404).json({ error: 'Workflow not found or you do not have permission' });
    }

    res.json({ inviteCode: workflow.inviteCode });
  } catch (error) {
    console.error('Error fetching invite code:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;