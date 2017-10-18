Pod::Spec.new do |spec|
  spec.name             = 'SelectableTextView'
  spec.version          = '1.0.0'
  spec.license          = { :type => 'MIT' }
  spec.homepage         = 'https://github.com/jhurray/SelectableTextView'
  spec.authors          = { 'Jeff Hurray' => 'jhurray33@gmail.com' }
  spec.summary          = 'A text view that supports selection and expansion'
  spec.source           = { :git => 'https://github.com/jhurray/SelectableTextView.git', :tag => spec.version.to_s }
  spec.source_files     = 'Source/**/*.swift', 'Frameworks/SelectableTextView.h'
  spec.social_media_url = 'https://twitter.com/jeffhurray'
  spec.platform     = :ios, '8.0'
  spec.requires_arc = true
  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
  spec.requires_arc     = true
end
