Pod::Spec.new do |s|

  s.name         = 'DrawableView'
  s.version      = '0.0.3'
  s.summary      = 'A UIView subclass that allows the user to draw on it.'
  s.homepage     = 'https://github.com/EthanSchatzline/DrawableView'
  s.license      = { type: 'MIT', file: 'LICENSE' }
  s.author       = { 'ethanschatzline' => 'ethanschatzline@yahoo.com' }
  s.social_media_url   = 'http://twitter.com/ethanschatzline'
  s.platform     = :ios, '9.0'
  s.source       = { :git => 'https://github.com/EthanSchatzline/DrawableView.git', :tag => s.version.to_s }
  s.source_files  = 'DrawableView/*.swift'
  s.frameworks  = 'UIKit'

end
