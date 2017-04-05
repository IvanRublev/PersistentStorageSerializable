#
# Be sure to run `pod lib lint PersistentStorageSerializable.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PersistentStorageSerializable'
  s.version          = '1.1.0'
  s.summary          = 'Swift library that makes easier to serialize the user\'s preferences class/struct with system User Defaults or Property List file on disk.'

  s.description      = <<-DESC
    Number of protocols from this pod helps to serialize swift class or structure to persistent storage like User Defaults or Keychain. The class/structure must contain properties of simple data type only. These types are: Data, String, Int, Float, Double, Bool, URL, Date, Array, or Dictionary<String, *>.
    Adopt the PersistentStorageSerializable protocol from your struct. Then call pullFromUserDefaults() or  pushToUserDefaults() on instance of your struct.
                       DESC

  s.homepage         = 'https://github.com/IvanRublev/PersistentStorageSerializable'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'IvanRublev' => 'ivan@ivanrublev.me' }
  s.source           = { :git => 'https://github.com/IvanRublev/PersistentStorageSerializable.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'

  s.source_files = 'PersistentStorageSerializable/Classes/**/*'

  s.frameworks = 'Foundation'
  s.dependency 'Reflection', '~> 0.14'

end
