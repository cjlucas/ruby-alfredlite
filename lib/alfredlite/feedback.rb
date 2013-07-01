require 'libxml'

module Alfred
  class Workflow
    include LibXML

    def feedback_items
      @feedback_items ||= []
    end

    def feedback_xml
      doc = XML::Document.new
      doc.root = XML::Node.new('items')
      feedback_items.each { |item| doc.root << item.to_xml }

      doc
    end
  end
end

module Alfred
  module Feedback
    class Item
      include LibXML
      ATTRIBUTES  = [:uid, :arg, :valid, :autocomplete, :type]
      CHILD_NODES = {
        :title => [], 
        :subtitle  => [], 
        :icon => [:type],
      }

      def initialize
        @type = 'file'
      end

      def valid=(valid)
        @valid = valid ? 'true' : 'false'
      end

      def to_xml
        item_node = XML::Node.new('item')
        ATTRIBUTES.each do |attrib|
          value = method(attrib).call
          item_node[attrib.to_s] = value unless value.nil?
        end

        CHILD_NODES.each do |node_name, node_attribs|
          value = method(node_name).call
          unless value.nil?
            item_node << XML::Node.new(node_name, value).tap do |child|
              node_attribs.each do |attrib|
                attr = self.class.child_attribute_name(node_name, attrib)
                value = method(attr).call
                child[attr] = value unless value.nil?
              end
            end
          end
        end

        item_node
      end

      private

      # generate getters and setters
      
      def self.child_attribute_name(child_node, attribute)
        "#{child_node}_#{attribute}"
      end

      def self.getter_unless_exists(attr, ivar = nil)
        getter = attr.to_sym
        ivar = "@#{attr}" if ivar.nil?
        
        unless instance_methods.include?(getter)
          define_method(getter) { instance_variable_get(ivar) }
        end
      end
      
      def self.setter_unless_exists(attr, ivar = nil)
        setter = "#{attr}=".to_sym
        ivar = "@#{attr}" if ivar.nil?
        
        unless instance_methods.include?(setter)
          define_method(setter) do |value|
            instance_variable_set(ivar, value)
          end
        end
      end

      ATTRIBUTES.each do |attrib|
        getter_unless_exists(attrib)
        setter_unless_exists(attrib)
      end

      CHILD_NODES.each do |name, attribs|
        getter_unless_exists(name)
        setter_unless_exists(name)
        
        attribs.each do |attrib|
          attr = child_attribute_name(name, attrib)
          getter_unless_exists(attr)
          setter_unless_exists(attr)
        end
      end

    end
  end
end