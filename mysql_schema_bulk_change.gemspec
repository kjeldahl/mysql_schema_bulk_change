# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mysql_schema_bulk_change}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jacob Kjeldahl"]
  s.cert_chain = ["/Users/jacobkjeldahl/.gem/gem-public_cert.pem"]
  s.date = %q{2009-04-28}
  s.description = %q{This extension to the MysqlAdapter in ActiveRecord enables bulk updates to schema definitions.  Pr. default when calling connection#add_column the change will be executed a once, but Mysql allows for multiple changes to be executed in one SQL statement (http://dev.mysql.com/doc/refman/5.1/en/alter-table.html). The advantage of this is that it takes a lot less time, especially if the table is large.}
  s.email = ["jkj@lenio.dk"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "features/development.feature", "features/step_definitions/common_steps.rb", "features/support/env.rb", "lib/mysql_schema_bulk_change.rb", "lib/mysql_schema_bulk_change/mysql_adapter.rb", "script/console", "script/destroy", "script/generate", "spec/mysql_schema_bulk_change_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/rspec.rake"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jacob_kjeldahl/mysql_schema_bulk_change}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{mysql_schema_bulk_change}
  s.rubygems_version = %q{1.3.1}
  s.signing_key = %q{/Users/jacobkjeldahl/.gem/gem-private_key.pem}
  s.summary = %q{This extension to the MysqlAdapter in ActiveRecord enables bulk updates to schema definitions}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 2.3.2"])
      s.add_development_dependency(%q<newgem>, [">= 1.3.0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<activerecord>, [">= 2.3.2"])
      s.add_dependency(%q<newgem>, [">= 1.3.0"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 2.3.2"])
    s.add_dependency(%q<newgem>, [">= 1.3.0"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
