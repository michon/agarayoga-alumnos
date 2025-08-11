# -*- encoding: utf-8 -*-
# stub: simple_calendar 3.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "simple_calendar".freeze
  s.version = "3.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/excid3/simple_calendar/blob/main/CHANGELOG.md", "homepage_uri" => "https://github.com/excid3/simple_calendar", "source_code_uri" => "https://github.com/excid3/simple_calendar" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Chris Oliver".freeze]
  s.date = "2025-01-09"
  s.description = "A simple Rails calendar".freeze
  s.email = ["excid3@gmail.com".freeze]
  s.homepage = "https://github.com/excid3/simple_calendar".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.5".freeze
  s.summary = "A simple Rails calendar".freeze

  s.installed_by_version = "3.3.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rails>.freeze, [">= 6.1"])
  else
    s.add_dependency(%q<rails>.freeze, [">= 6.1"])
  end
end
