require_relative 'spec_helper'

describe Alfred::Feedback::Item do
  context 'when no item attributes are added' do
    it 'should generate correct XML' do
      element = described_class.new.to_xml
      expect(element.has_attributes?).to be(false)
      expect(element.has_elements?).to be(false)
    end
  end

  context 'when all item attributes added, but no subelements' do
    it 'should generate correct XML' do
      element = described_class.new.tap do |item|
        item.uid = 'uid here'
        item.arg = 'arg here'
        item.autocomplete = 'autocomplete here'
        item.type = 'type here'
        item.valid = true
      end.to_xml

      expect(element.name).to eql('item')
      expect(element.attribute('uid').value).to eql('uid here')
      expect(element.attribute('arg').value).to eql('arg here')
      expect(element.attribute('autocomplete').value).to eql('autocomplete here')
      expect(element.attribute('type').value).to eql('type here')
      expect(element.attribute('valid').value).to eql('yes')
    end
  end
end
