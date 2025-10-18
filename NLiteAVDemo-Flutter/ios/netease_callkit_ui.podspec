#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint callkit.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'netease_callkit_ui'
  s.version          = '0.0.1'
  s.summary          = 'callkit Flutter project.'
  s.description      = <<-DESC
callkit Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # 修复资源路径配置
  s.resource_bundles = {
    'NECallKitBundle' => ['Assets/**/*']
  }
  
  # 添加资源文件
  s.resources = ['Assets/**/*']

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.dependency 'NERtcCallKit/FCS_Special','3.7.1'
  s.dependency 'NERtcSDK','5.9.10'
  s.dependency 'SnapKit'
  s.dependency 'SDWebImage'


end
