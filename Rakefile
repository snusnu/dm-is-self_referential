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
  end

  Jeweler::GemcutterTasks.new

  FileList['tasks/**/*.rake'].each { |task| import task }
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end
