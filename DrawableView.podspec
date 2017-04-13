Pod::Spec.new do |s|

  s.name         = 'DrawableView'
  s.version      = '0.0.1'
  s.summary      = 'A Swift framework for a UIView that can be drawn on.'
  s.homepage     = 'https://github.com/EthanSchatzline/DrawableView'
  s.license      = { :type => 'MIT' }
  s.author       = { 'ethanschatzline' => 'ethanschatzline@yahoo.com' }
  s.social_media_url   = 'http://twitter.com/ethanschatzline'
  s.platform     = :ios, '9.0'
  s.source       = { :git => 'https://github.com/EthanSchatzline/DrawableView.git', :tag => '#{s.version}' }
  s.source_files  = 'DrawableView.swift'
  s.frameworks  = 'UIKit'

end
