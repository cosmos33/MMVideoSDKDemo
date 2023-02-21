source 'https://github.com/cosmos33/MMSpecs.git'
source 'https://cdn.cocoapods.org'

platform :ios, '11.0'

inhibit_all_warnings!
use_frameworks!

ENGING_VERSION='5.0.1.20221229.1629'
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
    pod 'MMVideoSDK', '3.0.1.1'
    pod 'MMMedia','3.0.0'
    pod 'MMCV','4.1.2-tantan'
    pod 'GPUImage'
    pod 'JPImageresizerView', '0.5.0'
    pod 'NSTimer+WeakTarget', :modular_headers => true
    pod 'MetalPetal/Static', '1.13.0', :source => 'https://cdn.cocoapods.org/'
    pod 'XESceneKit', "#{ENGING_VERSION}"
    pod 'XEngineLua', "#{ENGING_VERSION}"
    pod 'XEngineUI', "#{ENGING_VERSION}"
    pod 'XEngineAudio', "#{ENGING_VERSION}"
    pod 'XEnginePhysics', "#{ENGING_VERSION}"
    pod 'LightningRender', "#{ENGING_VERSION}"
    pod 'XEngineAR',"#{ENGING_VERSION}"
    pod 'MMXEngineBase','4.5.2'
    
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
      if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
        target.build_configurations.each do |config|
            config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        end
      end
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end


