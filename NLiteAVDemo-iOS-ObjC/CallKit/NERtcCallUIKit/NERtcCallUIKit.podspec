#
# Be sure to run `pod lib lint NERtcCallUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
require_relative "../../PodConfigs/config_podspec.rb"
require_relative "../../PodConfigs/config_third.rb"
require_relative "../../PodConfigs/config_local_core.rb"
require_relative "../../PodConfigs/config_local_common.rb"
require_relative "../../PodConfigs/config_local_im.rb"

Pod::Spec.new do |s|
  s.name             = 'NERtcCallUIKit'
  s.version          = '2.2.0'
  s.summary          = 'Netease XKit'
  s.homepage         = YXConfig.homepage
  s.license          = YXConfig.license
  s.author           = YXConfig.author
  s.ios.deployment_target = YXConfig.deployment_target
  
  if ENV["USE_SOURCE_FILES"] == "true"
    s.source = { :git => "https://github.com/netease-kit/" }
    s.source_files = 'NERtcCallUIKit/Classes/**/*'
    s.resource = 'NERtcCallUIKit/Assets/**/*'
    s.dependency NERtcCallKit.name
    s.dependency SDWebImage.name
    s.dependency NECoreKit.name
    s.dependency NECommonKit.name
    s.dependency NECommonUIKit.name
  else
    s.source = { :http => "https://yx-web-nosdn.netease.im/package/NECoreKit_iOS_v9.4.0.framework.zip?download=NECoreKit_iOS_v9.4.0.framework.zip" }
    
    s.subspec 'NOS' do |nos|
      nos.vendored_frameworks = "NERtcCallUIKit.framework"
      nos.dependency NERtcCallKit.NOS
      nos.dependency SDWebImage.name
      nos.dependency NECoreKit.name
      nos.dependency NECommonKit.name
      nos.dependency NECommonUIKit.name
    end
    
    s.subspec 'NOS_Special' do |nos|
      nos.vendored_frameworks = 'NERtcCallUIKit.framework'
      nos.dependency NERtcCallKit.NOS_Special, "2.2.0"
      nos.dependency SDWebImage.name
      nos.dependency NECoreKit.name
      nos.dependency NECommonKit.name
      nos.dependency NECommonUIKit.name
    end
    
    s.subspec 'FCS' do |fcs|
      fcs.vendored_frameworks = 'NERtcCallUIKit.framework'
      fcs.dependency NERtcCallKit.FCS
      fcs.dependency SDWebImage.name
      fcs.dependency NECoreKit.name
      fcs.dependency NECommonKit.name
      fcs.dependency NECommonUIKit.name
    end
    
    s.subspec 'FCS_Special' do |fcs|
      fcs.vendored_frameworks = 'NERtcCallUIKit.framework'
      fcs.dependency NERtcCallKit.FCS_Special, "2.2.0"
      fcs.dependency SDWebImage.name
      fcs.dependency NECoreKit.name
      fcs.dependency NECommonKit.name
      fcs.dependency NECommonUIKit.name
    end
    s.default_subspecs = 'NOS'
  end
  
  YXConfig.pod_target_xcconfig(s)
  
end
