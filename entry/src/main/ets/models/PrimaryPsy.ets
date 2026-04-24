export class PrimaryPsy {
  id: number = -1;         // 主暗示对应的记录ID，-1表示无效或为空
  content: string = '';     // 暗示内容
  isEmpty: boolean = true;  // 标识主暗示是否为空状态

  //提供一个方法快速设置新内容
  setPrimaryContent(newId: number, newContent: string) {
    this.id = newId;
    this.content = newContent;
    this.isEmpty = false;
  }

  // 提供一个方法清空主暗示
  clear() {
    this.id = -1;
    this.content = '';
    this.isEmpty = true;
  }
}