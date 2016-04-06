require 'spec_helper'

describe('item server') do
  let (:item) { {'danny7' => {'user_name' => 'danny9', 'rep_id' => '100014624', 'profile_id' => '8192'}} }
  let (:hash) { {type: {test: {hello: 'world', foo: 'bar'}, basic: {basic1: {}, basic2: {}}}} }

  it('should reserve an item') do
    allow_any_instance_of(ItemsList).to receive(:get_item).with('admin', 30).and_return(item)
    get '/reserve/item?type=admin'
    expect(last_response.body).to eql item.to_json
  end

  it('should release an item') do
    allow_any_instance_of(ItemsList).to receive(:release).with('danny7').and_return(false)
    get '/release/item?item=danny7'
    expect(last_response.body).to eql 'true'
  end

  it('should release all items') do
    allow_any_instance_of(ItemsList).to receive(:release_all_items).and_return("All Items Released.")
    get '/release'
    expect(last_response.body).to eql "\"All Items Released.\""
  end

  it('should return a list of reserved items') do
    allow_any_instance_of(ItemsList).to receive(:get_reserved_items).and_return('danny7')
    get '/reserved'
    expect(last_response.body).to eql "\"danny7\""
  end

  it('should return a list of available items') do
    allow_any_instance_of(ItemsList).to receive(:get_available_items).and_return('johnny5')
    get '/available'
    expect(last_response.body).to eql "\"johnny5\""
  end

  it('should return Item Type Not Defined error if item type does not exist') do
    allow_any_instance_of(ItemsList).to receive(:get_item).with('foo', 30).and_raise(ItemError::ItemTypeNotDefined.new('foo'))
    get '/reserve/item?type=foo'
    expect(last_response.status).to eql 422
    expect(last_response.body).to eql 'Item type not defined: foo'
  end

  it('should return No Available Items error if item type does not exist') do
    allow_any_instance_of(ItemsList).to receive(:get_item).with('foo', 30).and_raise(ItemError::NoAvailableItems.new('foo'))
    get '/reserve/item?type=foo'
    expect(last_response.status).to eql 422
    expect(last_response.body).to eql "No foo items available to reserve"
  end

  it('should return No Reserved Items error if no items in reserved list') do
    allow_any_instance_of(ItemsList).to receive(:get_reserved_items).and_raise(ItemError::NoReservedItems)
    get '/reserved'
    expect(last_response.status).to eql 422
    expect(last_response.body).to eql 'No items currently reserved'
  end

  it('should return Invalid Item error if item does not exist') do
    allow_any_instance_of(ItemsList).to receive(:release).with('foo').and_raise(ItemError::InvalidItem.new('foo'))
    get '/release/item?item=foo'
    expect(last_response.status).to eql 422
    expect(last_response.body).to eql 'Item does not exist in the service: foo'
  end

  it('should raise No Reserved Items error if no items reserved') do
    allow_any_instance_of(ItemsList).to receive(:release_all_items).and_raise(ItemError::NoReservedItems)
    get '/release'
    expect(last_response.status).to eql 422
    expect(last_response.body).to eql 'No items currently reserved'
  end

  it('should return all items') do
    allow_any_instance_of(ItemsList).to receive(:get_all_items).and_return(hash)
    get '/'
    expect(last_response.body).to eql hash.to_json
  end
end