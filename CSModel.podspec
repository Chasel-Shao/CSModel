
Pod::Spec.new do |s|
  s.name             = 'CSModel'
  s.version          = '0.1.0'
  s.summary          = 'CSModel is a concise and efficient model framework for iOS/OSX, and provides nested Model to compare values and copy values.'
  s.description      = <<-DESC
   CSModel is a concise and efficient model framework for iOS/OSX. '
   It Provides many data-model methods:
   * Converts json to any object, or convert any object to json.
   * Serializes a model to provide class info and object properties.
   * Implementations of `NSCoding`, `NSCopying` and `isEqual:`.
                       DESC
  s.homepage         = 'https://github.com/Chasel-Shao/CSModel.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Chasel-Shao' => '753080265@qq.com' }
  s.source           = { :git => 'https://github.com/Chasel-Shao/CSModel.git', :tag => s.version.to_s }
  s.requires_arc = true 
  s.ios.deployment_target = '8.0'

  s.source_files = 'CSModel/*.{h,m}'
  s.public_header_files = 'CSModel/*.{h}'
  s.frameworks = 'UIKit', 'CoreFoundation'

end
