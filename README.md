# LSBatchDelete2xImage
本工程是适用于iOS工程瘦身中删除1x,2x图的macos脚本,由OC语言书写,仅支持删除imageset文件夹下的图片资源；验证了OC书写脚本的可行性。


## 如何使用
main函数中添加要筛查的文件地址,Run等待程序结束.

```bash
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [LSDeleteImageSet startWithBasePath:@""];
    }
    return 0;
}
```

## 特殊处理
会优先确定最高清的图片类型，向下删除（有3x 删除2x，1x；有2x 删除1x）
```bash
- (void)filterNeedDeleteModel
{
    BOOL has3xModel = [self.model3x hasRealImage];
    BOOL has2xModel = [self.model2x hasRealImage];
    if (has3xModel) {
        self.model2x.needDeleteFullPath = [NSString stringWithFormat:@"%@/%@",self.imagesetHomePath,self.model2x.filename];
        self.model1x.needDeleteFullPath = [NSString stringWithFormat:@"%@/%@",self.imagesetHomePath,self.model1x.filename];
    }
    
    if (has2xModel) {
        self.model1x.needDeleteFullPath = [NSString stringWithFormat:@"%@/%@",self.imagesetHomePath,self.model1x.filename];
    }
    
}
```

## 错误处理
出现错误会在当前地址下输出四个txt文件

find_error.txt  -> 有imageset但无Contents.json文件

fileRead_error.txt -> 读取Contents.json错误

noImage_error.txt-> imageset中无对应的图片

reWrite_error.txt -> 删除完毕后重设Contents.json错误




