require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'

require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-is-self_referential'

ENV["SQLITE3_SPEC_URI"]  ||= 'sqlite3::memory:'
ENV["MYSQL_SPEC_URI"]    ||= 'mysql://localhost/dm-is-self_referential_test'
ENV["POSTGRES_SPEC_URI"] ||= 'postgres://postgres@localhost/dm-is-self_referential_test'


def setup_adapter(name, default_uri = nil)
  begin
    DataMapper.setup(name, ENV["#{ENV['ADAPTER'].to_s.upcase}_SPEC_URI"] || default_uri)
    true
  rescue Exception => e
    if name.to_s == ENV['ADAPTER']
      warn "Could not load do_#{name}: #{e}"
    end
    false
  end
end

ENV['ADAPTER'] ||= 'sqlite3'

# have the logger handy ...
# DataMapper::Logger.new(STDOUT, :debug)
setup_adapter(:default)

spec_dir = Pathname(__FILE__).dirname.to_s
Dir[ spec_dir + "/lib/**/*.rb"      ].each { |rb| require(rb) }
Dir[ spec_dir + "/fixtures/**/*.rb" ].each { |rb| require(rb) }
Dir[ spec_dir + "/shared/**/*.rb"   ].each { |rb| require(rb) }

Spec::Runner.configure do |config|

end
