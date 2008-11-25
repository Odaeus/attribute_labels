# AttributeLabels
module AttributeLabels
  module ActiveRecordLabels
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        class << self
          alias_method_chain :human_attribute_name, :labels
          alias_method_chain :validates_presence_of, :labels

          define_method :labels do
            @labels ||= {}
          end

          define_method :required_attributes do
            @required_attributes ||= []
          end
        end
      end
    end

    def label_for(attr_name)
      self.class.label_for(attr_name)
    end

    module ClassMethods
      def label(labels)
        unless labels.is_a?(Hash)
          raise 'Was expecting a hash of attribute -> label pairs.'
        end

        labels.each do |attr, label|
          self.labels[attr.to_s] = label
        end
      end

      def label_for(attr_name)
        attr_name = attr_name.to_s
        labels[attr_name] || attr_name.humanize
      end

      def human_attribute_name_with_labels(name)
        name = name.to_s
        self.labels[name] || human_attribute_name_without_labels(name)
      end

      def validates_presence_of_with_labels(*attr_names)
        # Can't cope with :if or :unless parameters
        unless attr_names.is_a?(Array) && attr_names.last.is_a?(Hash) &&
            (attr_names.last[:if] || attr_names.last[:unless])
          self.required_attributes += attr_names.map {|name| name.to_s }
        end
        validates_presence_of_without_labels(*attr_names)
      end
    end
  end

  module ActionViewLabels
    module InstanceTagLabels
      def self.included(base)
        base.class_eval do
          alias_method_chain :to_label_tag, :labels
        end
      end

      def to_label_tag_with_labels(text = nil, options = {})
        if text.nil? && object.respond_to?(:labels)
          text = object.labels[method_name]
        end

        text = text || method_name.humanize

        # Add an asterisk if it's a required attribute
        if text && object.respond_to?(:required_attributes) &&
            object.required_attributes.include?(method_name)
          text << '*'
        end
        to_label_tag_without_labels(text, options)
      end
    end
  end
end
