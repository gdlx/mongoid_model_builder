module Mongoid
  module ModelBuilder
    class << self
      # Load models definitions from Ruby configuration file.
      def load models, options = {}

        # Try to read file if a String is provided
        models = eval File.read models if models.is_a? String

        raise "Models list must be an Array or a ruby file containing an Array" unless models.is_a? Array

        result = []
        @code  = []
        models.each do |model|
          result << build(model, options[:force])
        end

        return @code.join("\n") if options[:code]
        return result
      end

      private

      # Build a model class
      def build model, force
        # Handle existing classes
        if Object.const_defined? model[:name]
          raise "Class '#{model[:name]}' already exists." unless force
          Object.send(:remove_const, model[:name]) rescue nil
        end

        # Set parent class
        parent = model[:extends] ? model[:extends].constantize : Object

        # Create model class
        @model = Object.const_set model[:name], Class.new(parent)
        @code << "class #{model[:name]} < #{parent}"

        # Include Mongoid::Document by default
        includes = %w(Mongoid::Document)
        if model[:includes]
          raise "Includes list must be an Array (#{model[:includes].class} provided)" unless model[:includes].is_a? Array
          includes |= model[:includes]
        end

        add_includes includes
        add_fields model[:fields]

        @code << 'end'

        return @model
      end

      # Appends code to current model class
      def model_append source
        source = source.join("\n") if source.is_a? Array
        raise "model_append only accepts String or Array source (#{source.class} provided)" unless source.is_a? String
        @model.class_eval source
        @code << source
      end

      # Handle class includes
      def add_includes includes
        a = []
        includes.uniq.each do |value|
          a << "include #{value.constantize}"
        end
        model_append a
      end

      # Handle model fields
      def add_fields fields
        raise "Fields list must be an Array (#{fields.class} provided)" unless fields.is_a? Array

        fields.each do |field|
          add_field field
        end
      end

      def add_field field
        raise "Field must be a Hash (#{field.class} provided)" unless field.is_a? Hash

        # Retrieve parent field options if not overloaded
        if @model.superclass.respond_to?('fields') && @model.superclass.fields.has_key?(field[:name])
          parent = @model.superclass.fields[field[:name]]
          field[:type]     = parent.type        unless field[:type]
          field[:default]  = parent.default_val unless field[:default]
          field[:label]    = parent.label       unless field[:label]
          field[:localize] = parent.localized?  unless field[:localize]
        end

        # Field definition
        allowed_options = [:type, :default, :localize, :label]
        model_append "field :#{field[:name]}, #{field.slice(allowed_options)}"

        # Length option automatically creates a maximum length validator
        field = {:validators => {:length => {:maximum => field[:length]}}}.deep_merge(field) if field[:length]
        add_validators field
      end

      # Handle model validators
      def add_validators field
        return unless field[:validators]
        raise "Field validators list must be a Hash (#{field[:validators].class} provided)" unless field[:validators].is_a? Hash

        model_append "validates :#{field[:name]}, #{field[:validators]}"
      end
    end
  end
end
