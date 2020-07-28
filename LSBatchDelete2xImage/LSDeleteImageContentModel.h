//
//  LSDeleteImageContentModel.h
//  Tesstt
//
//  Created by Leason on 2020/7/28.
//  Copyright © 2020 Leason. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSDeleteImageIdiomItem  : NSObject

@property (nonatomic, copy) NSString *idiom;
@property (nonatomic, copy, nullable) NSString *filename;
@property (nonatomic, copy) NSString *scale;

@property (nonatomic, copy) NSString *needDeleteFullPath;



- (instancetype)initWithDict:(NSDictionary *)dict;

- (BOOL)hasRealImage;

//将对象转成字典
+ (NSDictionary*)changeToDicWithModel:(id)model;

@end


@interface LSDeleteImageContentModel : NSObject

@property (nonatomic, strong) NSDictionary *originalDic;
@property (nonatomic, strong) NSDictionary *reWriteDic;

@property (nonatomic, copy) NSString *contentsFilePath;
@property (nonatomic, copy) NSString *imagesetHomePath;

@property (nonatomic, strong) LSDeleteImageIdiomItem *model1x;
@property (nonatomic, strong) LSDeleteImageIdiomItem *model2x;
@property (nonatomic, strong) LSDeleteImageIdiomItem *model3x;


- (instancetype)initWithDict:(NSDictionary *)dict
            contentsFilePath:(NSString *)contentsFilePath
            imagesetHomePath:(NSString *)imagesetHomePath;

- (BOOL)hasImages;

- (void)resetImagesAfterDelete;
@end

NS_ASSUME_NONNULL_END
