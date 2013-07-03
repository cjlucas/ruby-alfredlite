require 'rexml/document'

module Alfred
  class Workflow
    def feedback_items
      @feedback_items ||= Feedback::ItemArray.new
    end

    def feedback_xml
      doc = REXML::Document.new
      doc << REXML::Element.new('items')
      feedback_items.each { |item| doc.root << item.to_xml }

      doc
    end
  end
end

module Alfred
  module Feedback
    class ItemArray < Array
      def prioritize!
        sort! { |a,b| a.priority <=> b.priority }.reverse!
      end
      
      def prioritize
        dup.prioritize!
      end
    end

    class Item
      # Compatibility Note:
      #   In Ruby 1.8, Object#type is defined, to workaround this the type 
      #   attribute can be accessed via #item_type
      ATTRIBUTES  = [:uid, :arg, :valid, :autocomplete, :item_type]
      XML_ATTRIBUTES_MAP = {
        :item_type => :type,
      }
      CHILD_NODES = {
        :title => [], 
        :subtitle  => [], 
        :icon => [:type],
      }

      (ATTRIBUTES + CHILD_NODES.keys).each { |attr| attr_accessor attr }
      CHILD_NODES.each do |k,v|
        v.each { |attr| attr_accessor "#{k}_#{attr}" }
      end

      attr_accessor :priority

      def initialize
        @item_type = 'file'
        @priority = 0
      end

      def valid=(valid)
        @valid = valid ? 'yes' : 'no'
      end

      def to_xml
        item_node = REXML::Element.new('item')
        ATTRIBUTES.each do |attrib|
          value = method(attrib).call
          xml_attrib = XML_ATTRIBUTES_MAP.fetch(attrib, attrib)
          #item_node[xml_attrib.to_s] = value unless value.nil?
          item_node.add_attribute(xml_attrib.to_s, value) unless value.nil?
        end

        CHILD_NODES.each do |node_name, node_attribs|
          value = method(node_name).call
          unless value.nil?
            item_node << REXML::Element.new(node_name.to_s).tap do |child|
              child.text = value

              node_attribs.each do |attrib|
                attr = "#{node_name}_#{attrib}"
                value = method(attr).call
                child.add_attribute(attr, value) unless value.nil?
              end
            end
          end
        end

        item_node
      end
    end
  end
end
