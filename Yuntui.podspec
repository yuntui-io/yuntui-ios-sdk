
Pod::Spec.new do |s|
  s.name         = "Yuntui"
  s.version      = "0.2.0"
  s.summary      = "yuntui ios sdk"
  s.homepage     = "https://github.com/yuntui-io/yuntui-ios-sdk"
  s.license      = "MIT"
  s.author       = { "ltebean" => "yucong1118@gmail.com" }
  s.source       = { :git => "git@github.com:yuntui-io/yuntui-ios-sdk.git", :tag => "0.2.0"}
  s.source_files = "yuntui-ios-sdk/Sources/*.{h,m}"
  s.requires_arc = true
  s.platform     = :ios, '8.0'
end


