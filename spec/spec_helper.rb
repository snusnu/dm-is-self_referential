require 'dm-core/spec/setup'
require 'dm-core/spec/lib/adapter_helpers'
require 'dm-core/spec/lib/pending_helpers'

require 'dm-is-self_referential'
require 'dm-migrations'
require 'dm-validations'

DataMapper::Spec.setup

SUPPORTS_M2M = %w[sqlite postgres mysql oracle sqlserver].include?(DataMapper::Spec.adapter_name)

Spec::Runner.configure do |config|
  config.extend(DataMapper::Spec::Adapters::Helpers)
  config.include(DataMapper::Spec::PendingHelpers)
end
