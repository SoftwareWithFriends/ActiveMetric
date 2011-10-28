$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "active_metric/version"


# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "active_metric"
  s.version     = ActiveMetric::VERSION
  s.authors     = ["Ryan McGarvey", "Eric Jones", "Aldric Giacomoni", "Bob Nadler, Jr."]
  s.email       = ["mcgarvey.ryan@gmail.com", "ejones@cyrusinnovation.com", "trevoke@gmail.com", "bnadlerjr@gmail.com"]
  s.homepage    = "http://github.com/ryanmcgvarvey/activemetric"
  s.summary     = "Summary of ActiveMetric."
  s.description = "Description of ActiveMetric."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1"
  s.add_dependency "mongoid"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "mocha"
end
