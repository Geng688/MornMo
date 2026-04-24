// src/main/ets/database/PsySuggestionDatabase.ets
import relationalStore from '@ohos.data.relationalStore';
import { BusinessError } from '@ohos.base';

interface DatabaseState {
  isInitialized: boolean;
  dbName: string;
}

// 心理暗示数据模型
export interface PsySuggestion {
  id?: number;         // 主键ID，自增
  content: string;     // 暗示内容
  createdTime?: number; // 创建时间戳
}

// 心理暗示表结构定义
const PSY_SUGGESTION_TABLE_SCHEMA = `
CREATE TABLE IF NOT EXISTS psy_suggestions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  content TEXT NOT NULL,
  created_time INTEGER DEFAULT (strftime('%s', 'now'))
)`;

// 创建索引以提高查询性能
const CREATE_INDEX_CREATED_TIME = `
CREATE INDEX IF NOT EXISTS idx_psy_suggestions_created_time ON psy_suggestions(created_time)`;

export class PsySuggestionDatabase {
  preloadSuggestions() {
    throw new Error('Method not implemented.');
  }
  private static instance: PsySuggestionDatabase;
  private rdbStore: relationalStore.RdbStore | null = null;

  // 数据库配置
  private storeConfig: relationalStore.StoreConfig = {
    name: 'PsySuggestions.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };

  // 获取单例实例
  public static getInstance(): PsySuggestionDatabase {
    if (!PsySuggestionDatabase.instance) {
      PsySuggestionDatabase.instance = new PsySuggestionDatabase();
    }
    return PsySuggestionDatabase.instance;
  }

  // 初始化数据库
  async initialize(context: Context): Promise<void> {
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, this.storeConfig);
      // 创建表
      await this.rdbStore.executeSql(PSY_SUGGESTION_TABLE_SCHEMA);
      // 创建索引
      await this.rdbStore.executeSql(CREATE_INDEX_CREATED_TIME);
      console.info('PsySuggestion database initialized successfully');
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to initialize psy suggestion database: Code: ${error.code}, message: ${error.message}`);
      throw new Error(`Failed to initialize psy suggestion database: ${error.message}`);
    }
  }

  // 插入新心理暗示
  async insertSuggestion(content: string): Promise<number> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    if (!content || content.trim().length === 0) {
      throw new Error('Suggestion content cannot be empty');
    }

    if (content.length > 50) {
      throw new Error('Suggestion content cannot exceed 50 characters');
    }

    try {
      const valuesBucket: relationalStore.ValuesBucket = {
        'content': content.trim(),
        'created_time': new Date().getTime() // 使用当前时间戳
      };

      const rowId = await this.rdbStore.insert('psy_suggestions', valuesBucket);
      console.info(`Psy suggestion inserted with ID: ${rowId}`);
      return rowId;
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to insert psy suggestion: Code: ${error.code}, message: ${error.message}`);
      throw new Error(`Failed to insert psy suggestion: ${error.message}`);
    }
  }

  // 查询所有心理暗示（按创建时间倒序）
  async getAllSuggestions(): Promise<PsySuggestion[]> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('psy_suggestions');
      predicates.orderByDesc('created_time'); // 按创建时间降序排列

      const resultSet = await this.rdbStore.query(predicates,
        ['id', 'content', 'created_time']);

      return this.processResultSet(resultSet);
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to query psy suggestions: Code: ${error.code}, message: ${error.message}`);
      throw new Error(`Failed to query psy suggestions: ${error.message}`);
    }
  }

  // 按ID查询心理暗示
  async getSuggestionById(id: number): Promise<PsySuggestion | null> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('psy_suggestions');
      predicates.equalTo('id', id);

      const resultSet = await this.rdbStore.query(predicates,
        ['id', 'content', 'created_time']);

      const suggestions = this.processResultSet(resultSet);
      return suggestions.length > 0 ? suggestions[0] : null;
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to query psy suggestion by ID: Code: ${error.code}, message: ${error.message}`);
      throw new Error(`Failed to query psy suggestion by ID: ${error.message}`);
    }
  }

  // 更新心理暗示
  async updateSuggestion(suggestion: PsySuggestion): Promise<number> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    if (!suggestion.id) {
      throw new Error('Suggestion ID is required for update');
    }

    try {
      const valuesBucket: relationalStore.ValuesBucket = {
        'content': suggestion.content
        // 注意：不更新创建时间
      };

      const predicates = new relationalStore.RdbPredicates('psy_suggestions');
      predicates.equalTo('id', suggestion.id);

      const rowsAffected = await this.rdbStore.update(valuesBucket, predicates);
      console.info(`Psy suggestion updated, rows affected: ${rowsAffected}`);
      return rowsAffected;
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to update psy suggestion: Code: ${error.code}, message: ${error.message}`);
      throw new Error(`Failed to update psy suggestion: ${error.message}`);
    }
  }

  // 删除心理暗示
  async deleteSuggestion(id: number): Promise<number> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('psy_suggestions');
      predicates.equalTo('id', id);

      const rowsDeleted = await this.rdbStore.delete(predicates);
      console.info(`Psy suggestion deleted, rows affected: ${rowsDeleted}`);
      return rowsDeleted;
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to delete psy suggestion: Code: ${error.code}, message: ${error.message}`);
      throw new Error(`Failed to delete psy suggestion: ${error.message}`);
    }
  }

  // 清空所有心理暗示
  async clearAllSuggestions(): Promise<number> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('psy_suggestions');
      const rowsDeleted = await this.rdbStore.delete(predicates);
      console.info(`All psy suggestions cleared, rows affected: ${rowsDeleted}`);
      return rowsDeleted;
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to clear psy suggestions: Code: ${error.code}, message: ${error.message}`);
      throw new Error(`Failed to clear psy suggestions: ${error.message}`);
    }
  }

  // 处理查询结果集
  private processResultSet(resultSet: relationalStore.ResultSet): PsySuggestion[] {
    const suggestions: PsySuggestion[] = [];

    if (resultSet.rowCount > 0) {
      while (resultSet.goToNextRow()) {
        const suggestion: PsySuggestion = {
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          content: resultSet.getString(resultSet.getColumnIndex('content')),
          createdTime: resultSet.getLong(resultSet.getColumnIndex('created_time'))
        };
        suggestions.push(suggestion);
      }
    }

    resultSet.close();
    return suggestions;
  }

  // 获取数据库状态
  getDatabaseState(): DatabaseState {
    return {
      isInitialized: this.rdbStore !== null,
      dbName: this.storeConfig.name
    };
  }
}