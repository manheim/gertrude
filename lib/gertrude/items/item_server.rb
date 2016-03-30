class ItemServer < Sinatra::Base

  set :port, 8080
  set :show_exceptions, false
  set :logging, false
 # Process.daemon

  items_list = ItemsList.new
  items_list.load_items!(ARGV[1])

  error ::ItemError::ItemTypeNotDefined do |type|
    error 422, "Item type not defined: #{type}"
  end

  error ::ItemError::NoReservedItems do
    halt 422, "No items currently reserved"
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

  get '/stop_service' do
    system "kill -9 #{Process.pid}"
  end
end


