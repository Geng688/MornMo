// src/main/ets/database/MailDatabase.ets
import relationalStore from '@ohos.data.relationalStore';
import { BusinessError } from '@ohos.base';

// 邮件数据结构
export interface MailItem {
  id?: number;
  subject: string;
  content: string;
  sendTime: number;
  isRead: boolean;
  createTime: number;
  imageUris?: string[];
}

export class MailDatabase {
  private static instance: MailDatabase;
  private rdbStore: relationalStore.RdbStore | null = null;
  private readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'MailDatabase.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };

  public static getInstance(): MailDatabase {
    if (!MailDatabase.instance) {
      MailDatabase.instance = new MailDatabase();
    }
    return MailDatabase.instance;
  }

  // 初始化数据库 - 添加context参数
  async initialize(context: Context): Promise<void> {
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, this.STORE_CONFIG);

      const mailTableSql = `
        CREATE TABLE IF NOT EXISTS mail (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          subject TEXT NOT NULL,
          content TEXT NOT NULL,
          send_time INTEGER NOT NULL,
          is_read INTEGER DEFAULT 0,
          create_time INTEGER NOT NULL
        )
      `;

      // 创建邮件图片关联表 - 修复：添加缺失的表
      const mailImagesTableSql = `
        CREATE TABLE IF NOT EXISTS mail_images (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          mail_id INTEGER NOT NULL,
          image_uri TEXT NOT NULL,
          create_time INTEGER NOT NULL
        )
      `;

      // 执行所有建表语句
      await this.rdbStore.executeSql(mailTableSql);
      await this.rdbStore.executeSql(mailImagesTableSql);
      console.log('邮件数据库初始化成功');
    } catch (error) {
      // 修正：添加error参数
      console.error('邮件数据库初始化失败:', this.formatError(error));
      throw new Error(`数据库初始化失败: ${this.formatError(error)}`);
    }
  }

  // 插入新邮件 - 修正参数
  async insertMail(
    subject: string,
    content: string,
    sendTime: number,
    createTime: number,
    imageUris?: string[]  // 可选参数
  ): Promise<number> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化');
    }

    const valueBucket: relationalStore.ValuesBucket = {
      'subject': subject,
      'content': content,
      'send_time': sendTime,
      'is_read': 0,
      'create_time': createTime
    };

    try {
      const rowId = await this.rdbStore.insert('mail', valueBucket);
      console.log('插入邮件成功，ID:', rowId);

      // 如果有图片，处理图片关联
      if (imageUris && imageUris.length > 0 && this.rdbStore) {
        await this.insertMailImages(rowId, imageUris, createTime);
      }
      return rowId;
    } catch (error) {
      // 修正：添加error参数
      console.error('插入邮件失败:', error);
      throw new Error(`插入邮件失败: ${this.formatError(error)}`);
    }
  }

  // 插入邮件图片关联
  private async insertMailImages(mailId: number, imageUris: string[], createTime: number): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化');
    }

    try {
      let successCount = 0;
      for (const imageUri of imageUris) {
        // 验证图片URI格式
        if (!this.isValidImageUri(imageUri)) {
          console.warn('跳过无效的图片URI:', imageUri);
          continue;
        }
        const imageValueBucket: relationalStore.ValuesBucket = {
          'mail_id': mailId,
          'image_uri': imageUri,
          'create_time': createTime
        };
        await this.rdbStore.insert('mail_images', imageValueBucket);
        successCount++;
      }
      console.log(`插入邮件图片成功，邮件ID: ${mailId}, 成功插入 ${successCount}/${imageUris.length} 张图片`);
    } catch (error) {
      console.error('插入邮件图片失败:', error);
      throw new Error(`插入邮件图片失败: ${this.formatError(error)}`);
    }
  }
  // 验证图片URI格式
  private isValidImageUri(uri: string): boolean {
    if (!uri || typeof uri !== 'string') {
      return false;
    }

    if (!uri.startsWith('file://')) {
      return false;
    }

    if (uri.length > 1000) {
      return false;
    }

    return true;
  }

  // 获取所有邮件
  async getAllMails(): Promise<MailItem[]> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化');
    }

    const columns = ['id', 'subject', 'content', 'send_time', 'is_read', 'create_time'];
    const predicates = new relationalStore.RdbPredicates('mail');
    predicates.orderByDesc('send_time');

    try {
      const resultSet = await this.rdbStore.query(predicates, columns);
      const mails: MailItem[] = [];

      while (resultSet.goToNextRow()) {
        const mailId = resultSet.getLong(resultSet.getColumnIndex('id'));
        const mail: MailItem = {
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          subject: resultSet.getString(resultSet.getColumnIndex('subject')),
          content: resultSet.getString(resultSet.getColumnIndex('content')),
          sendTime: resultSet.getLong(resultSet.getColumnIndex('send_time')),
          isRead: resultSet.getLong(resultSet.getColumnIndex('is_read')) === 1,
          createTime: resultSet.getLong(resultSet.getColumnIndex('create_time')),
          imageUris: await this.getMailImages(mailId)
        };

        // 获取邮件图片
        mail.imageUris = await this.getMailImages(mail.id!);
        mails.push(mail);
      }

      resultSet.close();
      return mails;
    } catch (error) {
      // 修正：添加error参数
      console.error('查询所有邮件失败:', this.formatError(error));
      throw new Error(`查询所有邮件失败: ${this.formatError(error)}`);
    }
  }

  // 获取收件箱邮件
  async getInboxMails(): Promise<MailItem[]> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化');
    }

    const columns = ['id', 'subject', 'content', 'send_time', 'is_read', 'create_time'];
    const predicates = new relationalStore.RdbPredicates('mail');
    predicates.lessThanOrEqualTo('send_time', Date.now());
    predicates.orderByDesc('send_time');

    try {
      const resultSet = await this.rdbStore.query(predicates, columns);
      const mails: MailItem[] = [];

      while (resultSet.goToNextRow()) {
        const mailId = resultSet.getLong(resultSet.getColumnIndex('id'));
        const mail: MailItem = {
          id: mailId,
          subject: resultSet.getString(resultSet.getColumnIndex('subject')),
          content: resultSet.getString(resultSet.getColumnIndex('content')),
          sendTime: resultSet.getLong(resultSet.getColumnIndex('send_time')),
          isRead: resultSet.getLong(resultSet.getColumnIndex('is_read')) === 1,
          createTime: resultSet.getLong(resultSet.getColumnIndex('create_time')),
          imageUris: await this.getMailImages(mailId)
        };
        mails.push(mail);
      }

      resultSet.close();
      return mails;
    } catch (error) {
      // 修正：添加error参数
      console.error('查询收件箱失败:', this.formatError(error));
      throw new Error(`查询收件箱失败: ${this.formatError(error)}`);
    }
  }

  // 获取邮件图片
  async getMailImages(mailId: number): Promise<string[]> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化');
    }

    const columns = ['image_uri'];
    const predicates = new relationalStore.RdbPredicates('mail_images');
    predicates.equalTo('mail_id', mailId);
    predicates.orderByAsc('id');

    try {
      const resultSet = await this.rdbStore.query(predicates, columns);
      const imageUris: string[] = [];

      while (resultSet.goToNextRow()) {
        const imageUri = resultSet.getString(resultSet.getColumnIndex('image_uri'));
        if (imageUri) {
          imageUris.push(imageUri);
        }
      }

      resultSet.close();
      return imageUris;
    } catch (error) {
      console.error('获取邮件图片失败:', error);
      return [];
    }
  }

  // 标记邮件为已读
  async markAsRead(mailId: number): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化');
    }

    const valueBucket: relationalStore.ValuesBucket = {
      'is_read': 1
    };

    const predicates = new relationalStore.RdbPredicates('mail');
    predicates.equalTo('id', mailId);

    try {
      const rowsUpdated = await this.rdbStore.update(valueBucket, predicates);
      console.log('标记邮件为已读，ID:', mailId, '更新行数:', rowsUpdated);
    } catch (error) {
      // 修正：添加error参数
      console.error('标记邮件为已读失败:', this.formatError(error));
      throw new Error(`标记邮件为已读失败: ${this.formatError(error)}`);
    }
  }

  // 在 MailDatabase.ets 中修复 deleteMail 方法
  // 简化版本：不使用事务
  async deleteMail(mailId: number): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化');
    }

    try {
      // 1. 先删除关联的图片记录
      const imagePredicates = new relationalStore.RdbPredicates('mail_images');
      imagePredicates.equalTo('mail_id', mailId);
      const imageRowsDeleted = await this.rdbStore.delete(imagePredicates);
      console.log('删除邮件图片成功，邮件ID:', mailId, '删除图片记录数:', imageRowsDeleted);

      // 2. 再删除邮件记录
      const mailPredicates = new relationalStore.RdbPredicates('mail');
      mailPredicates.equalTo('id', mailId);
      const mailRowsDeleted = await this.rdbStore.delete(mailPredicates);
      console.log('删除邮件成功，ID:', mailId, '删除行数:', mailRowsDeleted);

      if (mailRowsDeleted === 0) {
        throw new Error('邮件不存在或已被删除');
      }

    } catch (error) {
      console.error('删除邮件失败:', error);
      throw new Error(`删除邮件失败: ${this.formatError(error)}`);
    }
  }

  // 辅助方法：格式化错误信息 - 修正参数类型
  private formatError(error: Error | string | object | null | undefined): string {
    if (error instanceof Error) {
      return error.message;
    } else if (typeof error === 'string') {
      return error;
    } else if (error === null) {
      return 'null';
    } else if (error === undefined) {
      return 'undefined';
    } else {
      try {
        return JSON.stringify(error);
      } catch {
        return '无法序列化的错误对象';
      }
    }
  }

  // 获取未读收件箱邮件
  async getUnreadInboxMails(): Promise<MailItem[]> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化');
    }

    const columns = ['id', 'subject', 'content', 'send_time', 'is_read', 'create_time'];
    const predicates = new relationalStore.RdbPredicates('mail');
    predicates.lessThanOrEqualTo('send_time', Date.now());
    predicates.equalTo('is_read', 0);
    predicates.orderByDesc('send_time');

    try {
      const resultSet = await this.rdbStore.query(predicates, columns);
      const mails: MailItem[] = [];

      while (resultSet.goToNextRow()) {
        const mailId = resultSet.getLong(resultSet.getColumnIndex('id'));
        const mail: MailItem = {
          id: mailId,
          subject: resultSet.getString(resultSet.getColumnIndex('subject')),
          content: resultSet.getString(resultSet.getColumnIndex('content')),
          sendTime: resultSet.getLong(resultSet.getColumnIndex('send_time')),
          isRead: resultSet.getLong(resultSet.getColumnIndex('is_read')) === 1,
          createTime: resultSet.getLong(resultSet.getColumnIndex('create_time')),
          imageUris: await this.getMailImages(mailId)
        };
        mails.push(mail);
      }

      resultSet.close();
      return mails;
    } catch (error) {
      // 修正：添加error参数
      console.error('查询未读收件箱失败:', this.formatError(error));
      throw new Error(`查询未读收件箱失败: ${this.formatError(error)}`);
    }
  }
}