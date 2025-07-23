# -*- encoding: utf-8 -*-
# stub: aduki 0.2.7 ruby lib

Gem::Specification.new do |s|
  s.name = "aduki".freeze
  s.version = "0.2.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Conan Dalton".freeze]
  s.date = "2019-04-30"
  s.description = "recursive attribute setting for ruby objects".freeze
  s.email = ["conan@conandalton.net".freeze]
  s.homepage = "https://github.com/conanite/aduki".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.5".freeze
  s.summary = "set object attributes recursively from an attributes hash".freeze

  s.installed_by_version = "3.3.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.1"])
    s.add_development_dependency(%q<rspec_numbering_formatter>.freeze, [">= 0"])
  else
    s.add_dependency(%q<rspec>.freeze, ["~> 3.1"])
    s.add_dependency(%q<rspec_numbering_formatter>.freeze, [">= 0"])
  end
end
