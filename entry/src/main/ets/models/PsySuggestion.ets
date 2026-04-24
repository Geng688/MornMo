//src/main/ets/models/PsySuggestion.ets
// 心理暗示数据模型
export interface PsySuggestion {
  id?: number;         // 主键ID
  content: string;     // 暗示内容
  createdTime?: number; // 创建时间戳
}