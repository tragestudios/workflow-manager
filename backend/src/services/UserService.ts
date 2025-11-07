import { AppDataSource } from '../config/database';
import { User, UserStatus } from '../models/User';

export class UserService {
  private userRepository = AppDataSource.getRepository(User);

  async getUserById(id: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new Error('User not found');
    }
    const { password: _, ...userWithoutPassword } = user;
    return userWithoutPassword as User;
  }

  async getUsers(): Promise<User[]> {
    const users = await this.userRepository.find({
      select: ['id', 'email', 'name', 'role', 'status', 'avatar', 'createdAt']
    });
    return users;
  }

  async updateUser(id: string, updateData: Partial<User>): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new Error('User not found');
    }

    delete updateData.password;
    delete updateData.id;

    await this.userRepository.update(id, updateData);
    return await this.getUserById(id);
  }

  async approveUser(id: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new Error('User not found');
    }

    user.status = UserStatus.ACTIVE;
    await this.userRepository.save(user);

    const { password: _, ...userWithoutPassword } = user;
    return userWithoutPassword as User;
  }
}