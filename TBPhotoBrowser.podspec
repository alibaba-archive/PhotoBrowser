#
#  Created by teambition-ios on 2020/7/27.
#  Copyright © 2020 teambition. All rights reserved.
#     

Pod::Spec.new do |s|
  s.name             = 'TBPhotoBrowser'
  s.version          = '0.15.2'
  s.summary          = 'A simple photo browser to display remote photos. Kingfisher is used to download and cache images. '
  s.description      = <<-DESC
  A simple photo browser to display remote photos. Kingfisher is used to download and cache images. 
                       DESC

  s.homepage         = 'https://github.com/teambition/PhotoBrowser'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'teambition mobile' => 'teambition-mobile@alibaba-inc.com' }
  s.source           = { :git => 'https://github.com/teambition/PhotoBrowser.git', :tag => s.version.to_s }

  s.swift_version = '5.0'
  s.ios.deployment_target = '10.0'

  s.source_files = 'PhotoBrowser/**/*.swift'
  s.ios.resource_bundle = { 'Images' => 'PhotoBrowser/Images.xcassets' }

  s.dependency 'Kingfisher', '~>5.0'
  
end
