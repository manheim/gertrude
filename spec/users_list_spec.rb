require 'spec_helper'

describe "Items List" do
  context 'given a valid config file' do
    describe '#load_items!' do
      let(:hash) { {type: {test: {hello: 'world', foo: 'bar'}, basic: {basic1: {}, basic2: {}}}} }
      let(:duplicate_hash) { {type: {test: {hello: 'world', foo: 'bar'}}, type2: {test: {hello: 'world'}}} }

      it 'should add a unique key 2nd level to the given hash' do
        allow(YAML).to receive(:load_file).with('').and_return(hash)
        expect(ItemsList.new.load_items!('')[:type][:test].keys).to include ItemsList::RESERVE_KEY
      end

      it 'should set @items to a hash' do
        allow(YAML).to receive(:load_file).with('').and_return(hash)
        items = ItemsList.new
        items.load_items!('')
        expect(items.instance_variable_get('@items')).to be_a_kind_of Hash
      end

      it 'should raise an error if duplicate keys' do
        allow(YAML).to receive(:load_file).with('').and_return(duplicate_hash)
        items = ItemsList.new
        expect { items.load_items!('') }.to raise_error ItemError::ItemsNotUnique
      end
    end
  end

  context 'given an invalid config file' do
    describe '#load_items!' do
      it 'should raise an error' do
        expect { ItemsList.new.load_items!('blah123') }.to raise_error(Errno::ENOENT)
      end
    end
  end
end
