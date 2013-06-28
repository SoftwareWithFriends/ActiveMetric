$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "active_metric/version"


# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "active_metric"
  s.version     = ActiveMetric::VERSION
  s.authors     = ["Ryan McGarvey", "Eric Jones", "Aldric Giacomoni", "Bob Nadler, Jr.", "Tim Johnson", "Eric Liu"]
  s.email       = ["mcgarvey.ryan@gmail.com", "ejones@cyrusinnovation.com", "trevoke@gmail.com", "bnadlerjr@gmail.com", "timjohnson@chubtoad.com", "liukke@gmail.com"]
  s.homepage    = "http://github.com/SoftwareWithFriends/ActiveMetric"
  s.summary     = "ActiveMetric is a mongo based statistics calculator and persistance layer"
  s.description = "ActiveMetric is a mongo based statistics calculator and persistance layer"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

end
