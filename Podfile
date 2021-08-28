source 'https://github.com/cosmos33/MMSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'
#source 'https://cdn.cocoapods.org'

platform :ios, '11.0'

inhibit_all_warnings!

use_frameworks! :linkage => :static

target :MDRecordSDK do
    pod 'MMFrameworks', :source => 'https://github.com/cosmos33/MMSpecs.git'
    pod 'Toast', '~> 4.0.0'
    pod 'MBProgressHUD', '~> 1.1.0'
    pod 'MJRefresh'
    pod 'SDWebImage'
    pod 'SDWebImage/WebP'
    pod 'Masonry'
    pod 'pop'
    pod 'YYImage'
    pod 'ReactiveCocoa', '2.5'
    pod 'Mantle', '2.1.0'
    pod 'ZipArchive'
    pod 'JPImageresizerView', '0.5.0'

    pod 'MMVideoSDK', '2.5.0'
    pod 'MMMedia','2.5.0'
    pod 'MMCV','3.0.0-s'
     pod 'MetalPetal/Static', '1.13.0'
#  pod 'MetalPetal', '1.13.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end


