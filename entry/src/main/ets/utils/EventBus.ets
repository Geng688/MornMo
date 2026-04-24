/*
// src/main/ets/utils/EventBus.ts

export class EventBus {
  private static instance: EventBus;
  private events: Map<string, Function[]> = new Map();

  static getInstance(): EventBus {
    if (!EventBus.instance) {
      EventBus.instance = new EventBus();
    }
    return EventBus.instance;
  }

  // 监听事件
  on(event: string, callback: Function): void {
    if (!this.events.has(event)) {
      this.events.set(event, []);
    }
    this.events.get(event)?.push(callback);
  }

  // 移除监听
  off(event: string, callback?: Function): void {
    if (!this.events.has(event)) {
      return;
    }
    if (!callback) {
      this.events.delete(event); // 移除该事件所有监听器
    } else {
      const callbacks = this.events.get(event) || [];
      const index = callbacks.indexOf(callback);
      if (index > -1) {
        callbacks.splice(index, 1);
      }
    }
  }

  // 触发事件
  emit(event: string, data?: any): void {
    if (this.events.has(event)) {
      const callbacks = this.events.get(event) || [];
      callbacks.forEach(callback => {
        try {
          callback(data);
        } catch (error) {
          console.error(`Error in event handler for ${event}:`, error);
        }
      });
    }
  }
}

// 导出常用的事件名，避免拼写错误
export const Events = {
  RECORD_UPDATED: 'record_updated', // 记录更新
  RECORD_DELETED: 'record_deleted', // 记录删除
  RECORD_ADDED: 'record_added'     // 记录添加
};*/
