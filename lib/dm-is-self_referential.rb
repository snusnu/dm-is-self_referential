module DataMapper
  module Is

    module SelfReferential

      NATIVELY_SUPPORTED = false

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

        source_fk = Extlib::Inflection.foreign_key(options[:source]).to_sym
        target_fk = Extlib::Inflection.foreign_key(options[:target]).to_sym

        intermediate_model.class_eval do
          include DataMapper::Resource
          property source_fk, Integer, :key => true
          property target_fk, Integer, :key => true
          belongs_to options[:source], source_model
          belongs_to options[:target], target_model
        end

        intermediate_children = "#{self.name.snake_case}_#{options[:children]}".to_sym
        intermediate_parents  = "#{self.name.snake_case}_#{options[:parents ]}".to_sym

        has n, intermediate_children, intermediate_model, :child_key => [ source_fk ]
        has n, intermediate_parents,  intermediate_model, :child_key => [ target_fk ]

        if NATIVELY_SUPPORTED # have the code handy once the feature arrives in dm-core

          has n, options[:children], self, :through => intermediate_children, :via => :target
          has n, options[:parents ], self, :through => intermediate_parents,  :via => :source

        else

          define_method options[:children] do
            children_ids = self.send(intermediate_children).map { |r| r.send(target_fk) }
            self.class.all(:id => children_ids)
          end

          define_method options[:parents] do
            parent_ids = self.send(intermediate_parents).map { |r| r.send(source_fk) }
            self.class.all(:id => parent_ids)
          end

        end

      end

    end

  end
  Model.append_extensions(Is::SelfReferential)
end
