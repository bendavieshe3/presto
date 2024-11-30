# frozen_string_literal: true
# FILE: lib/presto/core/parameters/definition.rb

module Presto
    module Core
      module Parameters
        class Definition
          VALID_TYPES = [:float, :integer, :string, :enum, :boolean].freeze
  
          attr_reader :name, :type, :description, :default, :constraints
  
          def initialize(name:, type:, description:, default: nil, constraints: nil)
            validate_initialization_args(name, type, description)
            @name = name.to_sym
            @type = type.to_sym
            @description = description
            @default = default
            @constraints = constraints
          end
  
          def validate(value)
            # nil values are valid if there's a default
            return if value.nil? && !default.nil?
            
            validate_type(value)
            validate_constraints(value) if constraints
          end
  
          def to_h
            {
              name: name,
              type: type,
              description: description,
              default: default,
              constraints: constraints
            }
          end
  
          private
  
          def validate_initialization_args(name, type, description)
            raise ArgumentError, "Name is required" if name.nil? || name.empty?
            raise ArgumentError, "Type is required" if type.nil?
            raise ArgumentError, "Description is required" if description.nil? || description.empty?
            raise ArgumentError, "Invalid type: #{type}" unless VALID_TYPES.include?(type.to_sym)
          end
  
          def validate_type(value)
            case type
            when :float
              unless value.is_a?(Numeric)
                raise InvalidParameterError.new("#{name} must be a number", parameter_name: name)
              end
            when :integer
              unless value.is_a?(Integer)
                raise InvalidParameterError.new("#{name} must be an integer", parameter_name: name)
              end
            when :string
              unless value.is_a?(String)
                raise InvalidParameterError.new("#{name} must be a string", parameter_name: name)
              end
            when :boolean
              unless [true, false].include?(value)
                raise InvalidParameterError.new("#{name} must be true or false", parameter_name: name)
              end
            when :enum
              unless value.is_a?(String)
                raise InvalidParameterError.new("#{name} must be a string", parameter_name: name)
              end
            end
          end
  
          def validate_constraints(value)
            case type
            when :float, :integer
              validate_numeric_constraints(value)
            when :string
              validate_string_constraints(value)
            when :enum
              validate_enum_constraints(value)
            end
          end
  
          def validate_numeric_constraints(value)
            if constraints[:min] && value < constraints[:min]
              raise InvalidParameterError.new(
                "#{name} must be greater than or equal to #{constraints[:min]}", 
                parameter_name: name
              )
            end
            if constraints[:max] && value > constraints[:max]
              raise InvalidParameterError.new(
                "#{name} must be less than or equal to #{constraints[:max]}", 
                parameter_name: name
              )
            end
          end
  
          def validate_string_constraints(value)
            if constraints[:min_length] && value.length < constraints[:min_length]
              raise InvalidParameterError.new(
                "#{name} must be at least #{constraints[:min_length]} characters",
                parameter_name: name
              )
            end
            if constraints[:max_length] && value.length > constraints[:max_length]
              raise InvalidParameterError.new(
                "#{name} must be no more than #{constraints[:max_length]} characters",
                parameter_name: name
              )
            end
          end
  
          def validate_enum_constraints(value)
            unless constraints[:values]&.include?(value)
              raise InvalidParameterError.new(
                "#{name} must be one of: #{constraints[:values].join(', ')}", 
                parameter_name: name
              )
            end
          end
        end
      end
    end
  end