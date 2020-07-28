//
//  LSDeleteImageContentModel.m
//  Tesstt
//
//  Created by Leason on 2020/7/28.
//  Copyright © 2020 Leason. All rights reserved.
//

#import "LSDeleteImageContentModel.h"
#import <objc/runtime.h>

@implementation LSDeleteImageIdiomItem

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.idiom = dict[@"idiom"];
        self.filename = dict[@"filename"];
        self.scale = dict[@"scale"];
    }
    return self;
}

- (BOOL)hasRealImage
{
    return self.filename.length;
}

//将对象转成字典
+ (NSDictionary*)changeToDicWithModel:(id)model
{
    NSMutableDictionary*mDic = [NSMutableDictionary dictionary];
    for (NSString*key in [[self class] propertyKeysWithModel:model]) {
        [mDic setValue:[model valueForKey:key] forKey:key];
    }
    return mDic;
}


+ (NSArray*)propertyKeysWithModel:(id)model
{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    NSMutableArray *propertys = [NSMutableArray arrayWithCapacity:outCount];
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        [propertys addObject:propertyName];
    }
    free(properties);
    return propertys;
}

@end


@implementation LSDeleteImageContentModel

- (instancetype)initWithDict:(NSDictionary *)dict
            contentsFilePath:(NSString *)contentsFilePath
            imagesetHomePath:(NSString *)imagesetHomePath;
{
    if (self = [super init]) {
        self.originalDic = [dict mutableCopy];
        self.contentsFilePath = contentsFilePath;
        self.imagesetHomePath = imagesetHomePath;
        if (self.originalDic.count) {
            NSArray *dataArray = dict[@"images"];
            if (dataArray.count) {
                for (NSDictionary *tempDic in dataArray) {
                    if ([tempDic isKindOfClass:[NSDictionary class]]) {
                        LSDeleteImageIdiomItem *item = [[LSDeleteImageIdiomItem alloc] initWithDict:tempDic];
                        if ([item.scale isEqualToString:@"1x"]) {
                            self.model1x = item;
                        }
                        if ([item.scale isEqualToString:@"2x"]) {
                            self.model2x = item;
                        }
                        if ([item.scale isEqualToString:@"3x"]) {
                            self.model3x = item;
                        }
                    }
                }
            }
            [self filterNeedDeleteModel];
        }
    }
    return self;
}


- (BOOL)hasImages
{
    if (self.originalDic.count) {
        NSArray *dataArray = self.originalDic[@"images"];
        return dataArray.count;
    }
    return NO;
}


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


- (void)resetImagesAfterDelete
{
    NSMutableArray *writeArray = [NSMutableArray array];
    if (self.model1x) {
        [writeArray addObject:[LSDeleteImageIdiomItem changeToDicWithModel:self.model1x]];
    }
    if (self.model2x) {
        [writeArray addObject:[LSDeleteImageIdiomItem changeToDicWithModel:self.model2x]];
    }
    if (self.model3x) {
        [writeArray addObject:[LSDeleteImageIdiomItem changeToDicWithModel:self.model3x]];
    }
    NSMutableDictionary *tempDic = [self.originalDic mutableCopy];
    tempDic[@"images"] = writeArray;
    self.reWriteDic = [tempDic copy];
}



@end
