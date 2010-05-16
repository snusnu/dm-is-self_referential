require 'dm-core'

begin
  require 'active_support/inflector'
rescue LoadError
  require 'extlib/inflection'
  class String
    def underscore
      Extlib::Inflection.underscore(self)
    end
  end
end

module DataMapper
  module Is

    module SelfReferential

      def is_self_referential(options = {})

        options = {
          :through     => "#{self.name}To#{self.name}",
          :children    => :children,
          :parents     => :parents,
          :source      => :source,
          :target      => :target
        }.merge!(options)

        intermediate_model_name = options[:through]

        source_model       = self
        intermediate_model = Object.full_const_set(options[:through], Class.new)
        target_model       = self

        source_fk = ActiveSupport::Inflector.foreign_key(options[:source]).to_sym
        target_fk = ActiveSupport::Inflector.foreign_key(options[:target]).to_sym

        intermediate_model.class_eval do
          include DataMapper::Resource
          belongs_to options[:source], source_model, :key => true
          belongs_to options[:target], target_model, :key => true
        end

        intermediate_children = "#{self.name.underscore}_#{options[:children]}".to_sym
        intermediate_parents  = "#{self.name.underscore}_#{options[:parents ]}".to_sym

        has n, intermediate_children, intermediate_model, :child_key => [ source_fk ]
        has n, intermediate_parents,  intermediate_model, :child_key => [ target_fk ]

        has n, options[:children], self, :through => intermediate_children, :via => :target
        has n, options[:parents ], self, :through => intermediate_parents,  :via => :source

      end

    end

  end
  Model.append_extensions(Is::SelfReferential)
end
