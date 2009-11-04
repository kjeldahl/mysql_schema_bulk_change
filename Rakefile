Rake.application.options.trace = true
%w[rubygems rake rake/clean fileutils newgem rubigen hoe].each { |f| require f }
require File.dirname(__FILE__) + '/lib/mysql_schema_bulk_change'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.new('mysql_schema_bulk_change', MysqlSchemaBulkChange::VERSION) do |p|
  p.developer('Jacob Kjeldahl', 'jkj@lenio.dk')
  p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  #p.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
  p.rubyforge_name       = p.name # TODO this is default value
  p.extra_deps         = [
    ['activerecord','>= 2.3.2'],
  ]
  p.extra_dev_deps = [
    ['newgem', ">= #{::Newgem::VERSION}"]
  ]
  
  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks' # load /tasks/*.rake
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
task :create_db do
  cmd_string = %[mysqladmin create kjeldahl_mysql_schema_bulk_change_test -u build]
  system cmd_string
end

def runcoderun?
  ENV["RUN_CODE_RUN"]
end

remove_task :default
if runcoderun?
  task :default => [:create_db, :spec]
else
  task :default => :spec
end
