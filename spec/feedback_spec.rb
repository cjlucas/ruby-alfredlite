require File.expand_path('../spec_helper.rb', __FILE__)

Item = Alfred::Feedback::Item

describe Item do
  it 'adds attributes and child nodes properly' do
    item = Item.new.tap do |item|
      item.title        = 'this is the title'
      item.subtitle     = 'this is the subtitle'
      item.arg          = 'this is the arg'
      item.valid        = false
      item.uid          = 'alfredlite-43223'
      item.autocomplete = 'autocompleter'
      item.icon         = '/path/to/icon.png'
      item.icon_type    = 'fileicon'
    end
    xml = item.to_xml
    
    # check attributes
    Item::ATTRIBUTES.each do |attrib|
      xml_attrib = Item::XML_ATTRIBUTES_MAP.fetch(attrib, attrib)
      xml.attributes[xml_attrib.to_s].should eq(item.method(attrib).call)
    end

    # child nodes
    Item::CHILD_NODES.keys do |node_name|
      nodes = xml.children.select {|child| child.name.eql?(node_name.to_s)}
      nodes.count.should eq(1)
      nodes.first.name.should eq(node_name)
    end
  end



  #it "Doesn't add attributes and nodes that are nil" do
    #item = Item.new
  #end
end

describe Alfred::Feedback::ItemArray do
  it 'prioritizes items properly' do
    workflow = Alfred::Workflow.new(nil)
    [['second item', 5],
     ['third item', 0],
     ['first item', 10]].each do |item_info|
       workflow.feedback_items << Item.new.tap do |item|
         item.title = item_info[0]
         item.priority = item_info[1]
       end
     end
    
    workflow.feedback_items.prioritize!
    workflow.feedback_items[0].title.should eq('first item')
    workflow.feedback_items[1].title.should eq('second item')
    workflow.feedback_items[2].title.should eq('third item')
  end
end
