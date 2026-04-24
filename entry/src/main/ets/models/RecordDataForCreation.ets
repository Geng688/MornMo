export interface RecordDataForCreation {
  date: string;
  moodValue: number;
  statusEmoji: string;
  statusText: string;
  content: string;
  imageUris?: string[]; // 新增：图片URI列表
}