// src/main/ets/models/Suggestion.ets
export interface Suggestion {
  id?: number;          // 主键ID，自增
  content: string;      // 暗示内容
  createTime: number;   // 创建时间戳
}