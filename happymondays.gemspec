# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "happymondays/version"

Gem::Specification.new do |s|
  s.name        = "happymondays"
  s.version     = Happymondays::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Michael Krisher"]
  s.email       = ["mike@mikekrisher.com"]
  s.homepage    = ""
  s.summary     = %q{gem providing an easy api for changing the start and end days for Ruby's Date object}
  s.description = %q{gem allows for easy changing of week start day from Monday to any other day and setting a duration in days for the number of days in a work week}

  s.rubyforge_project = "happymondays"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
