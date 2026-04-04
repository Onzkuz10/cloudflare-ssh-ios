Pod::Spec.new do |s|
  s.name         = 'CFTunnel'
  s.version      = '0.1.0'
  s.summary      = 'gomobile-generated Cloudflare tunnel framework'
  s.homepage     = 'https://github.com/ankcorn/cloudflare-ssh-ios'
  s.license      = { :type => 'MIT' }
  s.author       = 'Thomas Ankcorn'
  s.platform     = :ios, '15.1'
  s.source       = { :path => '.' }
  s.vendored_frameworks = 'CFTunnel.xcframework'
end
