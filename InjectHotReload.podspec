Pod::Spec.new do |s|
  s.name = "InjectHotReload"
  s.version = "1.4.0"
  s.summary = "Hot Reloading for Swift applications! "

  s.homepage = "https://github.com/krzysztofzablocki/Inject"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Krzysztof Zablocki" => "krzysztof.zablocki@pixle.pl" }
  s.source = { :git => "https://github.com/krzysztofzablocki/Inject.git", :tag => s.version.to_s }

  s.ios.deployment_target = "11.0"
  s.osx.deployment_target = "10.15"
  s.tvos.deployment_target = "16.0"

  s.swift_version = "5.0"

  s.source_files = "Sources/Inject/**/*"
end
