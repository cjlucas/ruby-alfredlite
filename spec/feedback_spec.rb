require File.expand_path('../spec_helper.rb', __FILE__)

describe Alfred::Feedback::Item do
  it 'adds attributes and child nodes properly' do
    item = Alfred::Feedback::Item.new.tap do |item|
      item.title = 'this is the title'
      item.subtitle = 'this is the subtitle'
      item.arg = 'this is the arg'
      item.valid = false
      item.uid = 'alfredlite-43223'
      item.autocomplete = 'autocompleter'
      item.icon = '/path/to/icon.png'
      item.icon_type = 'fileicon'
    end

    xml = item.to_xml
    puts xml

    # check attributes
    Alfred::Feedback::Item::ATTRIBUTES.each do |attrib|
      xml[attrib].should eq(item.method(attrib).call)
    end

    # child nodes
    Alfred::Feedback::Item::CHILD_NODES.keys do |node_name|
      nodes = xml.children.select {|child| child.name.eql?(node_name)}
      nodes.count.should eq(1)
      nodes.first.name.should eq(node_name)
    end
  end

  #it "Doesn't add attributes and nodes that are nil" do
    #item = Alfred::Feedback::Item.new
  #end
end
