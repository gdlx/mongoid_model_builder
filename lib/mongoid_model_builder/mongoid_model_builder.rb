module Mongoid
  module ModelBuilder
    class << self

      # Load models definitions from Ruby configuration file.
      def load source, options = {}
        source = eval File.read source if source.is_a? String

        raise "Source must be a hash or a ruby file containing a hash" unless source.is_a? Hash

        result = []

        models = OpenCascade[source]
        models.each do |name, model_options|
          build name, model_options, options[:force]
          result << name.constantize
        end

        return result
      end

      private

      # Build a model class
      def build name, options, force
        # Parent class
        parent_model = options.extends? ? options.extends.constantize : Object

        # Handle existing classes
        if Object.const_defined? name
          raise "Class '#{name}' already exists." unless force
          Object.send(:remove_const, name) rescue nil
        end

        # Create model class
        @model = Object.const_set name, Class.new(parent_model)

        # Include Mongoid::Document by default
        includes = ['Mongoid::Document']
        if options.includes?
          raise "Includes list must be an Array (found #{options.includes.class})" unless options.includes.is_a? Array
          includes |= options.includes
        end

        add_includes includes
        add_fields options.fields

        return @model
      end

      # Appends code to current model class
      def model_append source
        source = source.join("\n") if source.is_a? Array
        raise "model_append only accepts String or Array source" unless source.is_a? String
        @model.class_eval source
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
        fields.each do |field, options|
          field = field.to_s

          # Retrieve parent field options if not overloaded
          if @model.superclass.respond_to?('fields') && @model.superclass.fields.has_key?(field)
            parent_field = @model.superclass.fields[field]
            options.type = parent_field.type unless options.type?
            options._default = parent_field.default_val unless options._default?
          end

          a = []
          a << "field :#{field}"
          a << ":type => #{options.type.inspect}" if options.type?
          a << ":default => #{options._default.inspect}" if options._default?
          model_append a.join(', ')

          # Length option automatically creates a maximum length validator
          if options._length?
            options.validators._length.maximum = options._length
          end
          add_validators(field, options.validators) if options.validators?
        end
      end

      # Handle model validators
      def add_validators field_name, validators
        a = []
        a << "validates :#{field_name}"
        validators.each do |validator, options|
          a << ":#{validator} => #{options.inspect}"
        end
        model_append a.join(', ')
      end
    end
  end
end
