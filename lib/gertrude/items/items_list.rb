class ItemsList
  include TestHelpers::Wait

  attr_accessor :items
  RESERVE_KEY = "reserved_#{SecureRandom.hex(4)}".to_sym

  def load_items!(yml)
    config = YAML.load_file(yml)
    config.each_key do |type|
      config[type].each_key do |item|
        config[type][item] = {} if config[type][item].nil?
        config[type][item][RESERVE_KEY] = false
      end
    end
    raise ItemError::ItemsNotUnique.new unless unique_keys_across_items?(config)
    @items = config.deep_stringify_keys!
    self
  end

  def unique_keys_across_items?(config)
    item_keys = []
    config.each_value { |v| item_keys.push(v.keys) }
    item_keys.flatten!
    item_keys.count == item_keys.uniq.count
  end

  def get_item(type, timeout, expiration)
    raise ItemError::ItemTypeNotDefined.new(type) unless @items.has_key? type
    loop_for_item(type, timeout, expiration)
  end

  def release_item(item)
    raise ItemError::InvalidItem.new(item) unless @items.has_deep_key?(item)
    @items.deep_find(item)[RESERVE_KEY] = false
    @items.deep_find(item).delete(:reserved_time)
  end

  def get_reserved_items
    reserved_items.join(", ")
  end

  def get_available_items
    available_items.join(",")
  end

  def get_all_items
    list = Marshal.load(Marshal.dump(@items))
    list.each_key do |type|
      list[type].each do |item|
        list[type][item[0]] = sanitize_response({item[0] => item[1]})
      end
    end
    list
  end

  def release_all_items
    raise ItemError::NoReservedItems if reserved_items.empty?
    @items.each_key do |type|
      @items[type].each_key do |item|
        @items[type][item][RESERVE_KEY] = false if @items[type][item][RESERVE_KEY]
        @items[type][item].delete(:reserved_time) if @items[type][item][:reserved_time]
      end
    end
    true
  end

  def available_items
    available_items = []
    @items.each_key do |type|
      @items[type].each_key do |item|
        available_items << item unless @items[type][item][RESERVE_KEY]
      end
    end
    available_items
  end

  def reserved_items
    taken_items = []
    @items.each_key do |type|
      @items[type].each_key do |item|
        taken_items << item if @items[type][item][RESERVE_KEY]
      end
    end
    taken_items
  end

  def loop_for_item(type, timeout, expiration)
    clear_expired_reservations
    item = wait_until(timeout: timeout) do
      item = get_available_item(type)
      raise ItemError::NoAvailableItems if item.empty?
      item
    end
    reserve_item(type, item.keys.first, expiration)
    sanitize_response(item)
  end

  def sanitize_response(item)
    x = Marshal.load(Marshal.dump(item))
    x.first.last.delete(RESERVE_KEY)
    x
  end

  def reserve_item(type, item_key, expiration)
    @items[type][item_key][:reserved_time] = Time.now + expiration if expiration != 0
    @items[type][item_key][RESERVE_KEY] = true
  end

  def get_available_item(type)
    Hash[*@items[type].select { |item| !@items[type][item][RESERVE_KEY] }.first]
  end

  def clear_expired_reservations
    @items.each_key do |type|
      @items[type].each_key do |item|
        if @items[type][item].has_key? :reserved_time
          release_item(item) if (@items[type][item][:reserved_time] < Time.now)
        end
      end
    end
  end
end