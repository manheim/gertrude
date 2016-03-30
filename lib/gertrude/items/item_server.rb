class ItemServer < Sinatra::Base

  items_list = ItemsList.new
  ARGV[1].nil? ? (raise 'yml file required to start gertrude') : items_list.load_items!(ARGV[1])

  error ::ItemError::ItemTypeNotDefined do |type|
    error 422, "Item type not defined: #{type}"
  end

  error ::ItemError::NoReservedItems do
    halt 422, 'No items currently reserved'
  end

  error ::ItemError::InvalidItem do |item|
    halt 422, "Item does not exist in the service: #{item}"
  end

  error ::ItemError::NoAvailableItems do |type|
    halt 422, "No #{type} items available to reserve"
  end

  get '/reserve/item' do
    default_timeout = 50
    items_list.get_item(params[:type], params[:timeout] || default_timeout).to_json
  end

  get '/release/item' do
    (!items_list.release_item(params[:item])).to_json
  end

  get '/reserved_items_list' do
    "Reserved Items: #{items_list.get_reserved_items}"
  end

  get '/release_all_items' do
    "Items released: #{items_list.release_all_items}"
  end

end


