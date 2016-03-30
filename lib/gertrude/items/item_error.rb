class ItemError
  class ItemTypeNotDefined < ArgumentError
  end

  class NoReservedItems < ArgumentError
  end

  class ItemsNotUnique < StandardError
  end

  class InvalidItem < ArgumentError
  end

  class NoAvailableItems < StandardError
  end
end