#
# Be sure to run `pod lib lint Chorister.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Chorister"
  s.version          = "0.1.3"
  s.summary          = "An audio library that plays tunes from the web with streaming, store it in the cache, reuse it when it is possible"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
  Chorister enables iOS device to play tunes from the web with streaming.
  When the whole data is loaded, this library create a cache in order to reuse
  in the future. Chorister is created for Denkinovel iOS app(https://itunes.apple.com/jp/app/denkinovel/id1000108250?l=ja&ls=1&mt=8).
                       DESC

  s.homepage         = "https://github.com/katryo/Chorister"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Ryo Kato" => "katoryo55@gmail.com" }
  s.source           = { :git => "https://github.com/katryo/Chorister.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/katryo'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AwesomeCache', '~> 2.0'
end
