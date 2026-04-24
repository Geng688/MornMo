// src/main/ets/utils/ImageStorageUtil.ets
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@ohos.base'; // 修正导入路径

// 定义接口替代对象字面量类型
interface PhotoSelectOptions {
  MIMEType: photoAccessHelper.PhotoViewMIMETypes;
  maxSelectNumber: number;
}
// 定义PhotoSelectResult接口
interface PhotoSelectResult {
  photoUris: Array<string>;
  isOriginal?: boolean;
}

// 定义图片信息接口
interface ImageInfo {
  uri: string;
  isValid: boolean;
}

export class ImageStorageUtil {
  private static instance: ImageStorageUtil;

  public static getInstance(): ImageStorageUtil {
    if (!ImageStorageUtil.instance) {
      ImageStorageUtil.instance = new ImageStorageUtil();
    }
    return ImageStorageUtil.instance;
  }

  // 选择多张图片
  async selectImages(maxCount: number = 5): Promise<string[]> {
    try {
      // 使用接口定义选项，而不是对象字面量类型
      const photoSelectOptions: PhotoSelectOptions = {
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: maxCount
      };

      const photoViewPicker = new photoAccessHelper.PhotoViewPicker();

      // 使用类型断言确保参数正确
      // 不再使用any类型，使用类型安全的调用
      // 这里需要将我们的接口转换为SDK期望的类型
      const selectOptions: photoAccessHelper.PhotoSelectOptions = this.convertToSdkOptions(photoSelectOptions);
      const photoSelectResult = await photoViewPicker.select(selectOptions);

      console.info('选择图片成功，数量:', photoSelectResult.photoUris.length);
      return photoSelectResult.photoUris;
    } catch (error) {
      console.error('选择图片失败:', error);
      const businessError = error as BusinessError;
      throw new Error(`选择图片失败: ${businessError.message}`);
    }
  }

  // 转换选项到SDK期望的类型 - 修复：避免any类型
  private convertToSdkOptions(options: PhotoSelectOptions): photoAccessHelper.PhotoSelectOptions {
    // 创建一个符合SDK类型的新对象
    const sdkOptions: photoAccessHelper.PhotoSelectOptions = {
      MIMEType: options.MIMEType,
      maxSelectNumber: options.maxSelectNumber
    };
    return sdkOptions;
  }


  // 验证图片URI是否有效
  async validateImageUri(uri: string): Promise<boolean> {
    try {
      if (!uri || typeof uri !== 'string') {
        return false;
      }

      if (!uri.startsWith('file://')) {
        return false;
      }

      return true;
    } catch (error) {
      console.error('验证图片URI失败:', error);
      return false;
    }
  }

  // 获取图片信息 - 使用接口定义返回类型
  async getImageInfo(uri: string): Promise<ImageInfo> {
    try {
      const isValid = await this.validateImageUri(uri);
      // 返回符合接口定义的对象
      return { uri, isValid };
    } catch (error) {
      console.error('获取图片信息失败:', error);
      return { uri, isValid: false };
    }
  }
}