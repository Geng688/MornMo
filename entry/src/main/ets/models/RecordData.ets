import { RecordDataForCreation } from "./RecordDataForCreation";

export interface RecordData {
  id: number;
  date: string;
  moodValue: number;
  statusEmoji: string;
  statusText: string;
  content: string;
  imageUris?: string[]; // 新增：图片URI列表
}
/*
export default class Record {
  id: string;
  date: string; // YYYY-MM-DD
  time: string; // HH:mm
  moodValue: number; // 0-100
  status?: {
    emoji: string;
    text: string;
  };
  content?: string;
  images?: string[];
  audio?: string;

  constructor(moodValue: number, date: string, time: string) {
    this.id = Date.now().toString();
    this.date = date;
    this.time = time;
    this.moodValue = moodValue;
  }
}
*/
