import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import preferences from '@ohos.data.preferences';
import { BusinessError } from '@ohos.base';

// 定义接口
interface SuggestionData {
  content: string;
  createdTime: number;
}

// 定义表单数据接口
interface FormData {
  randomContent: string;
  updateTime: string;
}

export default class EntryFormAbility extends FormExtensionAbility {
  private prefs: preferences.Preferences | null = null;
  private readonly prefsOptions: preferences.Options = { name: 'PsySuggestionsPrefs' };

  // 获取随机心理暗示
  // 获取随机心理暗示
  private getRandomSuggestion(): string {
    if (!this.prefs) {
      return '积极思考，乐观面对！';
    }

    try {
      // 获取所有数据
      const allData = this.prefs.getAllSync();
      const suggestions: string[] = [];

      // 使用 Object.entries 替代索引访问
      Object.entries(allData).forEach((entry: [string, preferences.ValueType]) => {
        const key = entry[0];
        const value = entry[1];

        if (key.startsWith('suggestion_')) {
          try {
            const parsedData = JSON.parse(value as string) as SuggestionData;
            suggestions.push(parsedData.content);
          } catch (e) {
            console.warn(`解析心理暗示数据失败: ${key}`, e);
          }
        }
      });

      // 随机选择一条语句
      if (suggestions.length > 0) {
        const randomIndex = Math.floor(Math.random() * suggestions.length);
        return suggestions[randomIndex];
      } else {
        return '暂无心理暗示，请添加一些积极的话语吧！';
      }
    } catch (error) {
      console.error('读取心理暗示失败:', error);
      return '保持积极心态！';
    }
  }


  onAddForm(want: Want) {
    try {
      const context = this.context;
      // 获取Preferences实例
      this.prefs = preferences.getPreferencesSync(context, this.prefsOptions);

      // 获取所有心理暗示并随机选择一条
      const randomSuggestion = this.getRandomSuggestion();

      // 创建表单数据（使用明确类型）
      const formData: FormData = {
        randomContent: randomSuggestion,
        updateTime: new Date().toLocaleString()
      };

      return formBindingData.createFormBindingData(formData);
    } catch (error) {
      const err = error as BusinessError;
      console.error('获取随机心理暗示失败:', err.message);
      // 返回默认数据
      return formBindingData.createFormBindingData({
        randomContent: '今天也是美好的一天！',
        updateTime: new Date().toLocaleString()
      } as FormData);
    }
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // 卡片更新时也返回随机语句
    try {
      const context = this.context;
      // 获取Preferences实例
      this.prefs = preferences.getPreferencesSync(context, this.prefsOptions);
      const randomSuggestion = this.getRandomSuggestion();
      const formData: FormData = {
        randomContent: randomSuggestion,
        updateTime: new Date().toLocaleString()
      };

      const bindingData = formBindingData.createFormBindingData(formData);
      // 使用正确的 API 调用方式
      formProvider.updateForm(formId, bindingData);
    } catch (error) {
      console.error('更新卡片失败:', error);
    }
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
}