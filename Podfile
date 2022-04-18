source 'https://github.com/cosmos33/MMSpecs.git'
source 'https://cdn.cocoapods.org'

platform :ios, '11.0'

inhibit_all_warnings!
use_frameworks!

target :MDRecordSDK do
    pod 'MMFrameworks', :path => './MMFramework', :subspecs => ['Eta', 'MMFoundation']
    pod 'Toast', '~> 4.0.0'
    pod 'MBProgressHUD', '~> 1.1.0'
    pod 'MJRefresh'
    pod 'SDWebImage'
    pod 'SDWebImage/WebP'
    pod 'Masonry'
    pod 'pop'
    pod 'YYImage'
    pod 'ReactiveCocoa', '2.5'
    pod 'MMVideoSDK', '2.5.3'
    pod 'MMMedia','2.5.4'
    pod 'MMCV','3.2.0-video'
    pod 'GPUImage'
    pod 'JPImageresizerView', '0.5.0'
    pod 'NSTimer+WeakTarget', :modular_headers => true
    pod 'MetalPetal/Static', '1.13.0', :source => 'https://cdn.cocoapods.org/'
    pod 'XESceneKit', '4.5.2.20211126.1500'
    pod 'XEngineLua', '4.5.2.20211126.1500'
    pod 'XEngineUI', '4.5.2.20211126.1500'
    pod 'XEngineAudio', '4.5.2.20211126.1500'
    pod 'XEnginePhysics', '4.5.2.20211126.1500'
    pod 'LightningRender', '4.5.2.20211126.1500'
    pod 'MMXEngineBase','4.5.2'
    
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end


