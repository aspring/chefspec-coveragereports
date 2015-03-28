require 'bundler/gem_tasks'
require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop) do |t|
  # Specify the files we will look at
  t.patterns = [File.join('{lib}', '**', '*.rb')]

  # Do not fail on error
  t.fail_on_error = false
end
