# AttributeLabels
module AttributeLabels
  module ActiveRecordLabels
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        class << self
          alias_method_chain :human_attribute_name, :labels
          alias_method_chain :validates_presence_of, :labels
        end
        cattr_accessor :required_attributes
        self.required_attributes = []
      end
    end

    module ClassMethods
      def label(labels)
        unless labels.is_a?(Hash)
          raise 'Was expecting a hash of attribute -> label pairs.'
        end
        unless respond_to?(:labels)
          init_labels
        end
        labels.each do |attr, label|
          self.labels[attr.to_s] = label
        end
      end

      def init_labels
        cattr_accessor :labels
        self.labels = {}
      end

      def human_attribute_name_with_labels(name)
        name = name.to_s
        self.labels[name] || human_attribute_name_without_labels(name)
      end

      def validates_presence_of_with_labels(*attr_names)
        # Can't cope with :if parameters
        unless attr_names.is_a?(Array) && attr_names.last.is_a?(Hash) && attr_names.last[:if]
          self.required_attributes += attr_names
        end
        validates_presence_of_without_labels(attr_names)
      end
    end
  end

  module ActionViewLabels
    module FormHelper
      def label(method, text = nil, options = {})
        if text == nil && options[:object].respond_to?(:labels)
          text = options[:object].labels[method.to_s]
        end
        InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_label_tag(text, options)
      end
    end
    module FormBuilderLabels
      def self.included(base)
        base.class_eval do
          alias_method_chain :label, :attribute_labels
        end
      end

      def label_with_attribute_labels(method, text = nil, options = {})
        if text == nil && @object.respond_to?(:labels)
          text = @object.labels[method.to_s]
        end
        label_without_attribute_labels(method, text, options)
      end
    end
  end
end
