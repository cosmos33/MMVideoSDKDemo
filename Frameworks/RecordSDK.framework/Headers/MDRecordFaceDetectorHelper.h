//
//  MDRecordFaceDetectorHelper.h
//  CXBeautyKit
//
//  Created by sunfei on 2019/3/8.
//

#import <Foundation/Foundation.h>

#define kMDRecordDetectorModelRootPath [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"MDRecordSDK/Object_Detectors"]

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MDRecordDetectorType) {
    MDRecordFaceDetectorTypeDefault,          // 人脸检测
    MDRecordFaceDetectorTypeObject,           // 手势检测
    MDRecordFaceDetectorTypeImageSegmenter,   // 抠图检测器
    MDRecordFaceDetectorTypeMomentImageSegmenter,   // 拍摄器抠图检测器
    MDRecordFaceDetectorTypeBareness,         // 光膀子检测器
    MDRecordFaceDetectorTypeBodyJoint,        // 人体关节点
    MDRecordFaceDetectorTypeGeneralBodyJoint, // 人体关节点，非CoreML版
    MDRecordFaceDetectorTypeExpress,
    MDRecordFaceDetectorType87,               // 87 点人脸检测
    MDRecordFaceDetectorTypeFacerigV2,        // FacerigV2检测器
    MDRecordFaceDetectorTypeHandGesture       // 新版手势检测
};

typedef NS_ENUM(NSUInteger, MDRecordFaceDetectorModel) {
    MDRecordFaceDetectorFAModelNone = 0,
    MDRecordFaceDetectorFAModel = 1 << 0, // 人脸检测器FA模型
    MDRecordFaceDetectorFDModel = 1 << 1, // 人脸检测器FD模型
    MDRecordFaceDetectorODModel = 1 << 4,  // 手势检测器OD模型
    MDRecordFaceDetectorSGModel = 1 << 5, // 抠图检测器SG模型
    MDRecordFaceDetectorBDModel = 1 << 7, // 光膀子检测器BD模型
    MDRecordFaceDetectorMomentSGModel = 1 << 8, // 拍摄器业务使用抠背景模型
    MDRecordFaceDetectorBodyDetectModel = 1 << 9, // 关节点模型
    MDRecordFaceDetectorGeneralBodyDetectModel = 1 << 10, // 关节点模型，非CoreML版
    MDRecordFaceDetectorExpressModel = 1 << 11, // 表情识别模型
    MDRecordFaceDetectorFD87Model = 1 << 13, // 人脸检测器FD 87点模型
    MDRecordFaceDetectorFrecogV2Model = 1 << 14, // Facerig检测器FrecogV2模型
    MDRecordFaceDetectorHandGestureDetectModel = 1 << 15, // 手势检测模型
};

@interface MDRecordFaceDetectorHelper : NSObject

+ (BOOL)disk4Model:(MDRecordFaceDetectorModel)model;
+ (NSString *)md54Model:(MDRecordFaceDetectorModel)model;
+ (void)updateMD54Model:(MDRecordFaceDetectorModel)model md5:(nullable NSString *)newMD5;
+ (void)setDetectorModelMD5:(nullable NSString *)md5String forModel:(NSString*)modelName; 
+ (BOOL)modelExists:(MDRecordFaceDetectorModel)model;
+ (NSString *)modelPath:(MDRecordFaceDetectorModel)model;
+ (NSString *)name4Model:(MDRecordFaceDetectorModel)model;
+ (NSString *)extension4Model:(MDRecordFaceDetectorModel)model;

+ (Class)class4DetectorType:(MDRecordDetectorType)type;

@end

NS_ASSUME_NONNULL_END
