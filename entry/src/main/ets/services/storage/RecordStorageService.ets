/*
import dataPreferences from '@ohos.data.preferences';
import Record from '../models/Record';
import { BusinessError } from '@ohos.base';

const PREF_NAME = 'mood_records';
const KEY_RECORDS = 'records';

export default class RecordStorageService {
  private static instance: RecordStorageService;
  private preferences: dataPreferences.Preferences | null = null;

  private constructor() {}

  public static getInstance(): RecordStorageService {
    if (!RecordStorageService.instance) {
      RecordStorageService.instance = new RecordStorageService();
    }
    return RecordStorageService.instance;
  }

  async init(context: any): Promise<void> {
    try {
      this.preferences = await dataPreferences.getPreferences(context, PREF_NAME);
    } catch (error) {
      console.error('Failed to get preferences.', error);
    }
  }

  async saveRecord(record: Record): Promise<boolean> {
    if (!this.preferences) return false;

    try {
      let records: Record[] = await this.getAllRecords();
      records.push(record);
      await this.preferences.put(KEY_RECORDS, JSON.stringify(records));
      await this.preferences.flush();
      return true;
    } catch (error) {
      console.error('Failed to save record.', error);
      return false;
    }
  }

  async updateRecord(updatedRecord: Record): Promise<boolean> {
    if (!this.preferences) return false;

    try {
      let records: Record[] = await this.getAllRecords();
      records = records.map(r => r.id === updatedRecord.id ? updatedRecord : r);
      await this.preferences.put(KEY_RECORDS, JSON.stringify(records));
      await this.preferences.flush();
      return true;
    } catch (error) {
      console.error('Failed to update record.', error);
      return false;
    }
  }

  async deleteRecord(recordId: string): Promise<boolean> {
    if (!this.preferences) return false;

    try {
      let records: Record[] = await this.getAllRecords();
      records = records.filter(r => r.id !== recordId);
      await this.preferences.put(KEY_RECORDS, JSON.stringify(records));
      await this.preferences.flush();
      return true;
    } catch (error) {
      console.error('Failed to delete record.', error);
      return false;
    }
  }

  async getAllRecords(): Promise<Record[]> {
    if (!this.preferences) return [];

    try {
      const recordsStr = await this.preferences.get(KEY_RECORDS, '[]');
      return JSON.parse(recordsStr as string);
    } catch (error) {
      console.error('Failed to get all records.', error);
      return [];
    }
  }

  async getRecordsByDate(date: string): Promise<Record[]> {
    const allRecords = await this.getAllRecords();
    return allRecords.filter(r => r.date === date);
  }
}*/
