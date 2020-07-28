//
//  LSDeleteImageSet.m
//  Tesstt
//
//  Created by Leason on 2020/7/27.
//  Copyright © 2020 Leason. All rights reserved.
//

#import "LSDeleteImageSet.h"
#import "LSDeleteImageContentModel.h"


@implementation LSDeleteImageSet

+ (void)startWithBasePath:(NSString *)path
{
    [[self new] deleteImageWithPath:path];
}


- (void)deleteImageWithPath:(NSString *)basePath
{
    if (basePath.length == 0) {
        return;
    }
    
    /// 筛选文件
    NSMutableArray *findErrorArray = [NSMutableArray new];
    NSMutableArray *fileReadErrorArray = [NSMutableArray new];
    NSMutableArray *noImagesErrorArray = [NSMutableArray new];
    
    NSMutableArray *modelArray = [NSMutableArray new];
    
    [self findImageWithBasePath:basePath findErrorArray:findErrorArray fileReadErrorArray:fileReadErrorArray noImagesErrorArray:noImagesErrorArray modelArray:modelArray];
    /// 执行删除操作
    NSMutableArray *reWriteErrorArray = [NSMutableArray new];
    [self deleteImageAndReWriteContents:modelArray errorArray:reWriteErrorArray];

    /// 输出删除问题文件
    
    if (findErrorArray.count) {
        [self writeToJsonWithPath:[NSString stringWithFormat:@"%@/find_error.txt",basePath] jsonData:findErrorArray];
    }
    
    if (fileReadErrorArray.count) {
        [self writeToJsonWithPath:[NSString stringWithFormat:@"%@/fileRead_error.txt",basePath] jsonData:fileReadErrorArray];
    }
    
    if (noImagesErrorArray.count) {
        [self writeToJsonWithPath:[NSString stringWithFormat:@"%@/noImage_error.txt",basePath] jsonData:noImagesErrorArray];
    }
    
    if (reWriteErrorArray.count) {
        [self writeToJsonWithPath:[NSString stringWithFormat:@"%@/reWrite_error.txt",basePath] jsonData:reWriteErrorArray];
    }
    
}


- (void)findImageWithBasePath:(NSString *)basePath
               findErrorArray:(NSMutableArray *)findErrorArray
           fileReadErrorArray:(NSMutableArray *)fileReadErrorArray
           noImagesErrorArray:(NSMutableArray *)noImagesErrorArray
                   modelArray:(NSMutableArray *)modelArray
{
    NSLog(@"LSDeleteImage --- begin findImageSet");
    // 1 查找imageset文件
    NSArray *imageSetArray = [self allFilesAtPath:basePath endName:@"imageset"];
    // 2 查找imageset文件下的contents.json
    for (int i = 0; i < imageSetArray.count; i++) {
        NSString *singleShortPath = imageSetArray[i];
        NSString *singleImageSetPath = [NSString stringWithFormat:@"%@/%@",basePath,singleShortPath];
        
        NSArray *findContentArray = [self allFilesAtPath:singleImageSetPath endName:@"json"];
        if (findContentArray.count) {
            NSString *contentsFilePath = [NSString stringWithFormat:@"%@/%@",singleImageSetPath,findContentArray.lastObject];
            NSDictionary *contentDic = [self readLocalFileWithName:contentsFilePath];
            if (contentDic) {
                LSDeleteImageContentModel *contentModel = [[LSDeleteImageContentModel alloc] initWithDict:contentDic contentsFilePath:contentsFilePath imagesetHomePath:singleImageSetPath];
                if ([contentModel hasImages]) {
                    [modelArray addObject:contentModel];
                } else {
                    [noImagesErrorArray addObject:contentsFilePath];
                }
            } else {
                [fileReadErrorArray addObject:contentsFilePath];
            }
        } else {
            [findErrorArray addObject:singleImageSetPath];
        }
    }
    NSLog(@"LSDeleteImage --- 查找到%ld个图片资源文件",modelArray.count);
    
}


- (void)deleteImageAndReWriteContents:(NSArray *)modelArray errorArray:(NSMutableArray *)deleteArray
{
    NSLog(@"LSDeleteImage --- 开始删除");
    if (modelArray) {
          for (LSDeleteImageContentModel *tempModel in modelArray) {
              if (tempModel.model1x.needDeleteFullPath) {
                  BOOL deleteSuccess = [self deleteFileWithPath:tempModel.model1x.needDeleteFullPath];
                  if (deleteSuccess) {
                      tempModel.model1x.filename = nil;
                  }
              }
              
              if (tempModel.model2x.needDeleteFullPath) {
                  BOOL deleteSuccess = [self deleteFileWithPath:tempModel.model2x.needDeleteFullPath];
                  if (deleteSuccess) {
                      tempModel.model2x.filename = nil;
                  }
              }
              [tempModel resetImagesAfterDelete];
              BOOL success = [self writeToJsonWithPath:tempModel.contentsFilePath jsonData:tempModel.reWriteDic];
              if (!success) {
                  [deleteArray addObject:tempModel.contentsFilePath];
              }
          }
        
         NSLog(@"LSDeleteImage --- 删除完成");
      }
}


#pragma mark ----- Helper  -----

/// find imageset文件
- (NSArray*) allFilesAtPath:(NSString*) dirString endName:(NSString *)endName {
    if (dirString.length && endName.length) {
        NSMutableArray* array = [NSMutableArray array];
        //文件操作对象
        NSFileManager *manager = [NSFileManager defaultManager];
        //文件夹路径
        NSString *home = [dirString stringByExpandingTildeInPath];//根目录文件夹
        //目录迭代器
        NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:home];
        //新建数组，存放各个文件路径
        NSMutableArray *files = [NSMutableArray arrayWithCapacity:42];
        //遍历目录迭代器，获取各个文件路径
        NSString *filename;
        while (filename = [direnum nextObject]) {
            if ([[filename pathExtension] isEqualTo:endName]) {//筛选出文件后缀名是htm的文件
                [files addObject:filename];
            }
        }
        //遍历数组，输出列表
        NSEnumerator *enume = [files objectEnumerator];
        while (filename = [enume nextObject]) {
            [array addObject:filename];
        }
        return array;
    }
    return nil;
}



// 读取本地JSON文件
- (NSDictionary *)readLocalFileWithName:(NSString *)name {
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:name];
    // 对数据进行JSON格式化并返回字典形式
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
  
}

///删除文件
- (BOOL)deleteFileWithPath:(NSString *)pathName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDelete = [fileManager removeItemAtPath:pathName error:nil];
    if (isDelete) {
        NSLog(@"LSDeleteImage --- deleteSuccess imageFile path = %@",pathName);
        return YES;
    }
     NSLog(@"LSDeleteImage --- deleteError imageFile path = %@",pathName);
    return NO;
}




- (BOOL)writeToJsonWithPath:(NSString *)pathName jsonData:(id)jsonObj
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options:1 error:nil];
    BOOL success = [jsonData writeToFile:pathName atomically:YES];
    return success;
}



@end
