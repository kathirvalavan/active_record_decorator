Gem::Specification.new do |s|
  s.name        = 'active_record_decorator'
  s.version     = '0.0.2'
  s.date        = '2022-08-20'
  s.summary     = "Activerecord utilities/extensions"
  s.description = "Activerecord utilities/extensions that will helps to make day-to-day application development easily."
  s.authors     = ["kathir"]
  s.email       = 'kathirvalavan.ict@gmail.com'
  s.files       = ["lib/active_record_decorator.rb"]
  s.homepage    =
    'https://rubygems.org/gems/active_record_decorator'
  s.license       = 'MIT'
  s.metadata    = { "source_code_uri" => "https://github.com/kathirvalavan/active_record_decorator" }
  s.required_ruby_version = ">= 2.3"
  s.add_runtime_dependency(%q<activesupport>, [">= 4.2"])
  s.add_development_dependency "bundler", "~> 1.15"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec", "~> 3.0"
end