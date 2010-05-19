require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Object

  def full_const_defined?(name)
    !!full_const_get(name) rescue false
  end

end

module RemixableHelper

  def clear_remixed_models(*models)
    models.each do |model|
      deepest_context, removable_const = (model =~ /^(.*::)(.*)$/) ? [$1, $2] : ["Object", model]

      if Object.full_const_defined?(model)
        if Object.full_const_defined?(deepest_context)
          deepest_context = Object.full_const_get(deepest_context)
          deepest_context.send(:remove_const, removable_const)
        end
      end
    end
  end

  alias :clear_remixed_model :clear_remixed_models

end

class User

  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true, :unique => true, :unique_index => true

end

module Main
  class Group
    include DataMapper::Resource

    property :id, Serial
    property :name, String, :required => true
  end

  class GroupHeritage
    include DataMapper::Resource

    property :parent_group_id, Integer, :key => true
    property :child_group_id, Integer, :key => true
  end
end

describe 'every self referential m:m relationship', :shared => true do

  it "should establish a 1:m relationship to the intermediate model" do
    relationship = @model.relationships(:default)[@intermediate_name]
    relationship.is_a?(DataMapper::Associations::OneToMany::Relationship).should be_true
  end

  it "should establish a m:m relationship to the target model" do
    relationship = @model.relationships(:default)[@target_name]
    relationship.is_a?(DataMapper::Associations::ManyToMany::Relationship).should be_true
  end


  it "should establish a method to retrieve children for an individual parent" do
    @source_instance.respond_to?(@children_accessor).should be_true
  end

  it "should establish a method to retrieve parents for an individual child" do
    @source_instance.respond_to?(@parents_accessor).should be_true
  end


  it "should return a DataMapper::Collection when calling the children accessor" do
    @source_instance.send(@children_accessor).is_a?(DataMapper::Collection).should be_true
  end

  it "should return a DataMapper::Collection when calling the parents accessor" do
    @source_instance.send(@parents_accessor).is_a?(DataMapper::Collection).should be_true
  end

  it "should be able to return all children" do
    pending_if 'M:M operations are not supported in_memory and on yaml', !SUPPORTS_M2M do
      @child_1 = @model.create(:name => 'Bars')
      @child_2 = @model.create(:name => 'Lisichka')
      @intermediate_model.create(@intermediate_source => @source_instance, @intermediate_target => @child_1)
      @intermediate_model.create(@intermediate_source => @source_instance, @intermediate_target => @child_2)
      @source_instance.send(@children_accessor).size.should == 2
    end
  end

  it "should be able to return all parents" do
    pending_if 'M:M operations are not supported in_memory and on yaml', !SUPPORTS_M2M do
      @parent_1 = @model.create(:name => 'Belka')
      @parent_2 = @model.create(:name => 'Strelka')
      @intermediate_model.create(@intermediate_target => @source_instance, @intermediate_source => @parent_1)
      @intermediate_model.create(@intermediate_target => @source_instance, @intermediate_source => @parent_2)
      @source_instance.send(@parents_accessor).size.should == 2
    end
  end

end

describe DataMapper::Is::SelfReferential do

  include RemixableHelper

  describe "with default options" do

    before(:each) do

      clear_remixed_models 'UserToUser'

      User.is :self_referential
      DataMapper.auto_migrate!

      @model               = User
      @intermediate_model  = UserToUser # implicitly test intermediate model generation
      @intermediate_source = :source
      @intermediate_target = :target
      @children_accessor   = :children
      @parents_accessor    = :parents

      @intermediate_name   = "user_#{@children_accessor}".to_sym
      @target_name         = @children_accessor

      @source_instance     = User.create(:name => 'Laika')

    end

    it_should_behave_like 'every self referential m:m relationship'

  end

  describe "with explict intermediate model name and default options" do

    before(:each) do

      clear_remixed_models 'Friendship'

      User.is :self_referential, :through => 'Friendship'
      DataMapper.auto_migrate!

      @model               = User
      @intermediate_model  = Friendship # implicitly test intermediate model generation
      @intermediate_source = :source
      @intermediate_target = :target
      @children_accessor   = :children
      @parents_accessor    = :parents

      @intermediate_name   = "user_#{@children_accessor}".to_sym
      @target_name         = @children_accessor

      @source_instance     = User.create(:name => 'Laika')

    end

    it_should_behave_like 'every self referential m:m relationship'

  end

  describe "with explict intermediate model name and customized options" do

    before(:each) do

      clear_remixed_models 'UserRelationship'

      User.is :self_referential, :through => 'UserRelationship',
        :children => :child_users,
        :parents  => :parent_users,
        :source   => :parent_user,
        :target   => :child_user

      DataMapper.auto_migrate!

      @model               = User
      @intermediate_model  = UserRelationship # implicitly test intermediate model generation
      @intermediate_source = :parent_user
      @intermediate_target = :child_user
      @children_accessor   = :child_users
      @parents_accessor    = :parent_users

      @intermediate_name   = "user_#{@children_accessor}".to_sym
      @target_name         = @children_accessor

      @source_instance     = User.create(:name => 'Laika')

    end

    it_should_behave_like 'every self referential m:m relationship'

  end

  describe "with default options for nested model" do

    before(:each) do

      clear_remixed_models 'Main::GroupToGroup'

      Main::Group.is :self_referential
      DataMapper.auto_migrate!

      @model               = Main::Group
      @intermediate_model  = Main::GroupToGroup # implicitly test intermediate model generation
      @intermediate_source = :source
      @intermediate_target = :target
      @children_accessor   = :children
      @parents_accessor    = :parents

      @intermediate_name   = "main_group_#{@children_accessor}".to_sym
      @target_name         = @children_accessor

      @source_instance     = Main::Group.create(:name => 'Laika')

    end

    it_should_behave_like 'every self referential m:m relationship'

  end


  describe "with explict intermediate nested model name and customized options" do

   before(:each) do

      clear_remixed_models 'Main::GroupHeritage'

      Main::Group.is :self_referential, :through => 'Main::GroupHeritage',
        :children => :child_groups,
        :parents  => :parent_groups,
        :source   => :parent_group,
        :target   => :child_group

      DataMapper.auto_migrate!

      @model               = Main::Group
      @intermediate_model  = Main::GroupHeritage # implicitly test intermediate model generation
      @intermediate_source = :parent_group
      @intermediate_target = :child_group
      @children_accessor   = :child_groups
      @parents_accessor    = :parent_groups

      @intermediate_name   = "main_group_#{@children_accessor}".to_sym
      @target_name         = @children_accessor

      @source_instance     = Main::Group.create(:name => 'Laika')

    end

    it_should_behave_like 'every self referential m:m relationship'

  end


end
