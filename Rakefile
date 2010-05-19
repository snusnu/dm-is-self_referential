require 'rake'

begin

  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    gem.name        = 'dm-is-self_referential'
    gem.summary     = 'Declaratively specify self referential m:m relationships in datamapper models'
    gem.description = gem.summary
    gem.email       = 'gamsnjaga@gmail.com'
    gem.homepage    = 'http://github.com/snusnu/dm-is-self_referential'
    gem.authors     = [ "Martin Gamsjaeger (snusnu)" ]

    gem.add_dependency             'dm-core', '~> 1.0.0.rc1'

    gem.add_development_dependency 'rspec',   '~> 1.3'
    gem.add_development_dependency 'yard',    '~> 0.5'
  end

  Jeweler::GemcutterTasks.new

  FileList['tasks/**/*.rake'].each { |task| import task }
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end
