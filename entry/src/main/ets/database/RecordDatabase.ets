// src/main/ets/database/RecordDatabase.ets
import relationalStore from '@ohos.data.relationalStore';
import { BusinessError } from '@ohos.base';
import { RecordData } from '../models/RecordData';
import { RecordDataForCreation } from '../models/RecordDataForCreation';

// 定义记录表结构
const RECORD_TABLE_SCHEMA = `
CREATE TABLE IF NOT EXISTS records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  moodValue INTEGER NOT NULL,
  statusEmoji TEXT,
  statusText TEXT,
  content TEXT,
  created_time TIMESTAMP DEFAULT (datetime('now','localtime'))
)`;

// 创建记录图片关联表
const RECORD_IMAGES_TABLE_SCHEMA = `
CREATE TABLE IF NOT EXISTS record_images (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  record_id INTEGER NOT NULL,
  image_uri TEXT NOT NULL,
  create_time TIMESTAMP DEFAULT (datetime('now','localtime')),
  FOREIGN KEY (record_id) REFERENCES records(id) ON DELETE CASCADE
)`;

// 创建索引
const CREATE_INDEX_DATE = `
CREATE INDEX IF NOT EXISTS idx_records_date ON records(date)`;

const CREATE_INDEX_RECORD_IMAGES = `
CREATE INDEX IF NOT EXISTS idx_record_images_record_id ON record_images(record_id)`;

export class RecordDatabase {
  private static instance: RecordDatabase;
  private rdbStore: relationalStore.RdbStore | null = null;
  private storeConfig: relationalStore.StoreConfig = {
    name: 'MoodRecords.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };

  public static getInstance(): RecordDatabase {
    if (!RecordDatabase.instance) {
      RecordDatabase.instance = new RecordDatabase();
    }
    return RecordDatabase.instance;
  }

  // 初始化数据库 - 添加图片表
  async initialize(context: Context): Promise<void> {
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, this.storeConfig);

      // 创建所有表
      await this.rdbStore.executeSql(RECORD_TABLE_SCHEMA);
      await this.rdbStore.executeSql(RECORD_IMAGES_TABLE_SCHEMA);
      await this.rdbStore.executeSql(CREATE_INDEX_DATE);
      await this.rdbStore.executeSql(CREATE_INDEX_RECORD_IMAGES);

      console.info('Database initialized successfully with images table');
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to initialize database: Code: ${error.code}, message: ${error.message}`);
      throw new Error(`Failed to initialize database: ${error.message}`);
    }
  }

  // 插入新记录（支持图片）
  async insertRecord(record: RecordDataForCreation, imageUris?: string[]): Promise<number> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    try {
      const valuesBucket: relationalStore.ValuesBucket = {
        'date': record.date,
        'moodValue': record.moodValue,
        'statusEmoji': record.statusEmoji,
        'statusText': record.statusText,
        'content': record.content
      };

      const rowId = await this.rdbStore.insert('records', valuesBucket);
      console.info(`Record inserted with ID: ${rowId}`);

      // 插入图片关联
      if (imageUris && imageUris.length > 0) {
        await this.insertRecordImages(rowId, imageUris);
      }

      return rowId;
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to insert record: Code: ${error.code}, message: ${error.message}`);
      throw new Error(`Failed to insert record: ${error.message}`);
    }
  }

  // 插入记录图片
  private async insertRecordImages(recordId: number, imageUris: string[]): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    try {
      for (const imageUri of imageUris) {
        if (this.isValidImageUri(imageUri)) {
          const imageValuesBucket: relationalStore.ValuesBucket = {
            'record_id': recordId,
            'image_uri': imageUri
          };
          await this.rdbStore.insert('record_images', imageValuesBucket);
        }
      }
      console.info(`Inserted ${imageUris.length} images for record ID: ${recordId}`);
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to insert record images: Code: ${error.code}, message: ${error.message}`);
      throw new Error(`Failed to insert record images: ${error.message}`);
    }
  }

  /// 修复：验证图片URI格式 - 使用严格的布尔表达式
  private isValidImageUri(uri: string): boolean {
    // 修复：使用严格的布尔表达式，避免类型推断问题
    if (typeof uri !== 'string') {
      return false;
    }

    if (uri.trim().length === 0) {
      return false;
    }

    if (!uri.startsWith('file://')) {
      return false;
    }

    if (uri.length <= 7) { // "file://".length = 7
      return false;
    }

    return true;
  }


  // 更新记录（支持图片）
  async updateRecord(record: RecordData, imageUris?: string[]): Promise<number> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }


    try {
      const valuesBucket: relationalStore.ValuesBucket = {
        'date': record.date,
        'moodValue': record.moodValue,
        'statusEmoji': record.statusEmoji,
        'statusText': record.statusText,
        'content': record.content
      };

      const predicates = new relationalStore.RdbPredicates('records');
      predicates.equalTo('id', record.id);

      const rowsAffected = await this.rdbStore.update(valuesBucket, predicates);
      console.info(`Record updated, rows affected: ${rowsAffected}`);

      // 更新图片：先删除旧图片，再插入新图片
      if (imageUris) {
        await this.deleteRecordImages(record.id);
        if (imageUris.length > 0) {
          await this.insertRecordImages(record.id, imageUris);
        }
      }

      return rowsAffected;
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to update record: Code: ${error.code}, message: ${error.message}`);
      throw new Error(`Failed to update record: ${error.message}`);
    }
  }

  // 删除记录图片
  private async deleteRecordImages(recordId: number): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('record_images');
      predicates.equalTo('record_id', recordId);
      const rowsDeleted = await this.rdbStore.delete(predicates);
      console.info(`Deleted ${rowsDeleted} images for record ID: ${recordId}`);
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to delete record images: Code: ${error.code}, message: ${error.message}`);
      throw new Error(`Failed to delete record images: ${error.message}`);
    }
  }

  // 删除记录（级联删除图片）
  async deleteRecord(id: number): Promise<number> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }


    try {
      // 先删除关联的图片
      await this.deleteRecordImages(id);

      // 再删除记录
      const predicates = new relationalStore.RdbPredicates('records');
      predicates.equalTo('id', id);
      const rowsDeleted = await this.rdbStore.delete(predicates);
      console.info(`Record deleted, rows affected: ${rowsDeleted}`);

      return rowsDeleted;
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to delete record: Code: ${error.code}, message: ${error.message}`);
      throw new Error(`Failed to delete record: ${error.message}`);
    }
  }

  // 查询记录图片
  async getRecordImages(recordId: number): Promise<string[]> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('record_images');
      predicates.equalTo('record_id', recordId);
      predicates.orderByAsc('id');

      const resultSet = await this.rdbStore.query(predicates, ['image_uri']);
      const imageUris: string[] = [];

      while (resultSet.goToNextRow()) {
        const imageUri = resultSet.getString(resultSet.getColumnIndex('image_uri'));
        if (imageUri && this.isValidImageUri(imageUri)) {
          imageUris.push(imageUri);
        }
      }

      resultSet.close();
      return imageUris;
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to get record images: Code: ${error.code}, message: ${error.message}`);
      return [];
    }
  }

  // 查询所有记录（包含图片）
  async queryAllRecords(): Promise<RecordData[]> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('records');
      predicates.orderByAsc('date');

      const resultSet = await this.rdbStore.query(predicates,
        ['id', 'date', 'moodValue', 'statusEmoji', 'statusText', 'content']);

      return await this.processResultSetWithImages(resultSet);
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to query records: Code: ${error.code}, message: ${error.message}`);
      throw new Error(`Failed to query records: ${error.message}`);
    }
  }

  // 按日期查询记录（包含图片）
  async queryRecordsByDate(date: string): Promise<RecordData[]> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('records');
      predicates.like('date', `${date}%`);

      const resultSet = await this.rdbStore.query(predicates,
        ['id', 'date', 'moodValue', 'statusEmoji', 'statusText', 'content']);

      return await this.processResultSetWithImages(resultSet);
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to query records by date: Code: ${error.code}, message: ${error.message}`);
      throw new Error(`Failed to query records by date: ${error.message}`);
    }
  }

  // 处理结果集（包含图片）
  private async processResultSetWithImages(resultSet: relationalStore.ResultSet): Promise<RecordData[]> {
    const records: RecordData[] = [];

    if (resultSet.rowCount > 0) {
      while (resultSet.goToNextRow()) {
        const recordId = resultSet.getLong(resultSet.getColumnIndex('id'));
        const record: RecordData = {
          id: recordId,
          date: resultSet.getString(resultSet.getColumnIndex('date')),
          moodValue: resultSet.getLong(resultSet.getColumnIndex('moodValue')),
          statusEmoji: resultSet.getString(resultSet.getColumnIndex('statusEmoji')),
          statusText: resultSet.getString(resultSet.getColumnIndex('statusText')),
          content: resultSet.getString(resultSet.getColumnIndex('content')),
          imageUris: await this.getRecordImages(recordId) // 加载图片
        };
        records.push(record);
      }
    }

    resultSet.close();
    return records;
  }

  // 按日期范围查询记录（包含图片）
  async queryRecordsByDateRange(startDate: string, endDate: string): Promise<RecordData[]> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('records');
      predicates.between('date', startDate, endDate);
      predicates.orderByAsc('date');

      const resultSet = await this.rdbStore.query(predicates,
        ['id', 'date', 'moodValue', 'statusEmoji', 'statusText', 'content']);

      return await this.processResultSetWithImages(resultSet);
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to query records by date range: Code: ${error.code}, message: ${error.message}`);
      throw new Error(`Failed to query records by date range: ${error.message}`);
    }
  }
}