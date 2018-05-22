require_relative 'spec_helper'

describe 'items list' do
  let(:item_list) { ItemsList.new }
  let(:item) { {'danny7' => {'user_name' => 'danny9', 'rep_id' => '100014624', 'profile_id' => '8192'}} }

  before(:each) do
    item_list.items = {
      'admin' => {
        'danny7' => {
          'user_name' => 'danny9', 'rep_id' => '100014620', 'profile_id' => '8190', ItemsList::RESERVE_KEY.to_sym => false
        },
        'johnny5' => {
          'user_name' => 'danny7', 'rep_id' => '100014624', 'profile_id' => '8192', ItemsList::RESERVE_KEY.to_sym => false
        },
        '5015806226' => {
          'user_name' => '5015806226', 'rep_id' => '100014698', 'profile_id' => '8193', ItemsList::RESERVE_KEY.to_sym => false
        }
      }
    }
  end

  describe '#unique_keys_across_items' do
    it 'should raise Item Type Not Defined' do
      expect { item_list.get_item(:blah, 1, 10) }.to raise_error(ItemError::ItemTypeNotDefined)
    end

    it 'should return true if unique keys' do
      expect(item_list.unique_keys_across_items?(item_list.items)).to be true
    end

    it 'should return false if duplicate keys' do
      item_list.items.merge!({'basic' => {'danny7' => {'user_name' => 'danny7'}}})
      expect(item_list.unique_keys_across_items?(item_list.items)).to be false
    end
  end

  describe '#get_item' do
    it 'should raise an error if type not defined' do
      expect { item_list.get_item('foo', 0.01, 3) }.to raise_error ItemError::ItemTypeNotDefined
    end

    it 'should return an item' do
      allow(item_list).to receive(:loop_for_item).with('admin', 0.01, 3).and_return(item)
      expect(item_list.get_item('admin', 0.01, 3)).to eql item
    end
  end

  describe '#release_item' do
    it 'should release an item' do
      item_list.items['admin']['danny7'][ItemsList::RESERVE_KEY] = true
      expect(item_list.release_item('danny7')).to be nil
      expect(item_list.items['admin']['danny7'][ItemsList::RESERVE_KEY]).to be false
      expect(item_list.items['admin']['danny7']).to_not have_key :reserved_time
    end

    it('should raise Invalid Item error when trying to release non reserved item') do
      expect { item_list.release_item('foo') }.to raise_error(ItemError::InvalidItem)
    end

    it('should release an item that is all numeric characters') do
      item_list.items['admin']['5015806226'][ItemsList::RESERVE_KEY] = true
      expect(item_list.release_item(5015806226)).to be nil
      expect(item_list.items['admin']['5015806226'][ItemsList::RESERVE_KEY]).to be false
    end
  end

  describe '#get_reserved_items' do
    it 'should return a string of reserved items' do
      allow(item_list).to receive(:reserved_items).and_return(%w(danny7 johnny5))
      expect(item_list.get_reserved_items).to eql 'danny7, johnny5'
    end
  end

  describe '#get_available_items' do
    it 'should return a string of reserved items' do
      allow(item_list).to receive(:available_items).and_return(%w(danny7))
      expect(item_list.get_available_items).to eql 'danny7'
    end
  end

  describe '#get_all_items' do
    it 'should return a string of reserved items' do
      allow(item_list).to receive(:all_items).and_return(item_list.items)
      response_hash = {"admin" => {"danny7" => {"danny7" => {"user_name" => "danny9", "rep_id" => "100014620", "profile_id" => "8190"}}, "johnny5" => {"johnny5" => {"user_name" => "danny7", "rep_id" => "100014624", "profile_id" => "8192"}}, "5015806226" => {"5015806226" => {'user_name' => '5015806226', 'rep_id' => '100014698', 'profile_id' => '8193'}}}}
      expect(item_list.get_all_items).to eql response_hash
    end
  end

  describe '#release_all_items' do
    it 'should release all items' do
      allow(item_list).to receive(:reserved_items).and_return(['danny7'])
      item_list.items['admin']['danny7'][ItemsList::RESERVE_KEY] = true
      item_list.items['admin']['johnny5'][ItemsList::RESERVE_KEY] = true
      item_list.release_all_items
      expect(item_list.items['admin']['danny7'][ItemsList::RESERVE_KEY]).to be false
      expect(item_list.items['admin']['johnny5'][ItemsList::RESERVE_KEY]).to be false
      expect(item_list.items['admin']['danny7']).to_not have_key :reserved_time
      expect(item_list.items['admin']['johnny5']).to_not have_key :reserved_time
    end

    it('should return true') do
      allow(item_list).to receive(:reserved_items).and_return(['danny7'])
      item_list.items['admin']['danny7'][ItemsList::RESERVE_KEY] = true
      item_list.items['admin']['johnny5'][ItemsList::RESERVE_KEY] = true
      expect(item_list.release_all_items).to be true
    end

    it('should raise No Reserved Items if no items are reserved') do
      expect { item_list.release_all_items }.to raise_error(ItemError::NoReservedItems)
    end
  end

  describe '#reserved_items' do
    it 'should return an array of reserved items' do
      item_list.items['admin']['danny7'][ItemsList::RESERVE_KEY] = true
      expect(item_list.reserved_items).to eql ['danny7']
    end
  end

  describe '#available_items' do
    it 'should return an array of available items' do
      item_list.items['admin']['danny7'][ItemsList::RESERVE_KEY] = true
      expect(item_list.available_items).to eql ['johnny5', '5015806226']
    end
  end

  describe '#loop_for_item' do
    it 'should reserve an item' do
      allow(item_list).to receive(:get_available_item).with('admin').and_return(item)
      allow(item_list).to receive(:reserve_item).with('admin', 'danny7', 3).and_return(item_list.items['admin']['danny7'][ItemsList::RESERVE_KEY] = true)
      allow(item_list).to receive(:sanitize_response).with(item)
      item_list.loop_for_item('admin', 0.01, 3)
      expect(item_list.items['admin']['danny7'][ItemsList::RESERVE_KEY]).to be true
    end

    it 'should return a sanitized response' do
      allow(item_list).to receive(:get_available_item).with('admin').and_return(item)
      allow(item_list).to receive(:reserve_item).with('admin', 'danny7', 3)
      allow(item_list).to receive(:sanitize_response).with(item).and_return(item)
      expect(item_list.loop_for_item('admin', 0.01, 3)['danny7'].keys).to_not include ItemsList::RESERVE_KEY
    end

    it 'should return a hash' do
      allow(item_list).to receive(:get_available_item).with('admin').and_return(item)
      allow(item_list).to receive(:reserve_item).with('admin', 'danny7', 3)
      allow(item_list).to receive(:sanitize_response).with(item).and_return(item)
      expect(item_list.loop_for_item('admin', 0.01, 3)).to be_a_kind_of Hash
    end

    it 'should raise a timeout error if not items available' do
      allow(item_list).to receive(:get_available_item).with('admin').and_return([])
      expect { item_list.loop_for_item('admin', 0.01, 3) }.to raise_error ItemError::NoAvailableItems
    end
  end

  describe '#sanitize_response' do
    it 'should not include reserve key' do
      item = {'danny7' => {'user_name' => 'danny9', 'rep_id' => '100014624', 'profile_id' => '8192', ItemsList::RESERVE_KEY.to_sym => false}}
      expect(item_list.sanitize_response(item)['danny7'].keys).to_not include ItemsList::RESERVE_KEY
    end
  end

  describe '#reserve_item' do
    it 'should reserve an item' do
      expect(item_list.reserve_item('admin', 'danny7', 3)).to be true
      expect(item_list.items['admin']['danny7'][ItemsList::RESERVE_KEY]).to be true
    end
  end

  describe '#get_available_item' do
    it 'should get next available item' do
      item_list.items['admin']['danny7'][ItemsList::RESERVE_KEY] = true
      expect(item_list.get_available_item('admin')).to eql({"johnny5" => {"user_name" => "danny7", "rep_id" => "100014624", "profile_id" => "8192", ItemsList::RESERVE_KEY.to_sym => false}})
    end
  end

  describe '#load_items!' do
    let(:hash) { {type: {test: {hello: 'world', foo: 'bar'}, basic: {basic1: {}, basic2: {}}}} }
    let(:numeric_hash) { {numeric: {12345 => {hello: 'world', foo: 'bar'}, 967979 => {basic1: {}, basic2: {}}}} }
    let(:duplicate_hash) { {type: {test: {hello: 'world', foo: 'bar'}}, type2: {test: {hello: 'world'}}} }

    it 'should add a unique key 2nd level to the given hash' do
      allow(YAML).to receive(:load_file).with('').and_return(hash)
      expect(ItemsList.new.load_items!('').items["type"]["test"].keys).to include ItemsList::RESERVE_KEY.to_s
    end

    it 'should set @items to provided hash' do
      allow(YAML).to receive(:load_file).with('').and_return(hash)
      items = ItemsList.new
      items.load_items!('')
      expect(items.instance_variable_get('@items')).to eql hash
    end

    it 'should raise an error if duplicate keys' do
      allow(YAML).to receive(:load_file).with('').and_return(duplicate_hash)
      items = ItemsList.new
      expect { items.load_items!('') }.to raise_error ItemError::ItemsNotUnique
    end

    it 'should raise an error on invalid config file' do
      expect { ItemsList.new.load_items!('blah123') }.to raise_error(Errno::ENOENT)
    end

    it 'should convert numeric keys to strings' do
      allow(YAML).to receive(:load_file).with('').and_return(numeric_hash)
      expect(ItemsList.new.load_items!('').items["numeric"].keys).to include(*["12345", "967979"])
    end
  end

  describe '#clear_expire_reservations' do
    it 'should clear expired reservations' do
      item_list.items['admin']['danny7'][:reserved_time] = Time.now - 10
      item_list.items['admin']['danny7'][ItemsList::RESERVE_KEY] = true
      item_list.clear_expired_reservations
      expect(item_list.items['admin']['danny7'][ItemsList::RESERVE_KEY]).to be false
      expect(item_list.items['admin']['danny7']).to_not have_key :reserved_time
    end

    it 'should not clear active reservations' do
      item_list.items['admin']['danny7'][:reserved_time] = Time.now + 180
      item_list.items['admin']['danny7'][ItemsList::RESERVE_KEY] = true
      item_list.clear_expired_reservations
      expect(item_list.items['admin']['danny7'][ItemsList::RESERVE_KEY]).to be true
      expect(item_list.items['admin']['danny7']).to have_key :reserved_time
    end

  end

end