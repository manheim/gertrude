class ItemServer < Sinatra::Base

  def initialize
    super
    @items_list = ItemsList.new.load_items!(settings.file)
  end

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

  get '/' do
    @items_list.all_items.to_json
  end

  get '/reserve/item' do
    @items_list.get_item(params[:type], params[:timeout] || 50).to_json
  end

  get '/release/item' do
    (!@items_list.release_item(params[:item])).to_json
  end

  get '/reserved' do
    @items_list.get_reserved_items.to_json
  end

  get '/release' do
    @items_list.release_all_items
  end

  get '/available' do
    @items_list.get_available_items
  end
end




