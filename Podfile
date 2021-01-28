source 'https://github.com/cosmos33/MMSpecs.git'
source 'https://cdn.cocoapods.org'

platform :ios, '10.0'

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
    pod 'JPImageresizerView'
    
    pod 'MMVideoSDK', '2.3.4.3'
    pod 'MMMedia', '2.3.2.3.16'
    pod 'MMFileService', '1.3.3'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end


