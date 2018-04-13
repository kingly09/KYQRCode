#
# Be sure to run `pod lib lint KYQRCode.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KYQRCode'
  s.version          = '0.1.7'
  s.summary          = 'KYQRCode 是一个基于Objective-C封装的二维码扫描条形码/识别生成二维码框架 .'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.homepage         = 'https://github.com/kingly09/KYQRCode'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kingly09' => 'libintm@163.com' }
  s.source           = { :git => 'https://github.com/kingly09/KYQRCode.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '8.0'

  s.source_files = 'KYQRCode/Classes/**/*'
  s.resource_bundles = {
     'KYQRCode' => ['KYQRCode/Assets/**/*']
  }
  s.requires_arc = true
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
