Gertrude
========

Gertrude is your librarian. It's a simple rest service that feeds you unique items, that you define, by type. Those items are reserved
until you release them back to the service.

As an example, this can be used to limit conflicts in users when testing. Testers (or automation) can request users
from the service, and use them for testing. The service won't provide that specific user to another request, until the original
requester releases it back to the service. Check your stuff back in to Gertrude. Dont be that guy.

How do I use this?
------------------

 - Install the gem.
 - Define your items in a yaml file, by type.
 - Start the service, using your created yaml file.
 - Request items from the service.
 - Use the requested items to your hearts content.
 - Release the item back to the service when you are done.
 - ???
 - PROFIT.

Define items in a yaml file, by type
------------------------------------

Create a yaml file, using the following format:
```ruby
---
item_type1:
  type1_item1:
    item1_property1: property1_value
    items1_property2: property2_value
  type1_item2:
    item2_property1: property1_value
    items2_property2: property2_value
```

Example (for an implementation to provide users):
```ruby
---
admin:
  admin1:
    password: admin_password_1
    other: admin_other
  admin2:
    password: admin_password_2
    other: admin_other
  admin3:
    password: admin_password_3
    other: admin_other
basic:
  basic1:
  basic2:
  basic3:
custom_user:
  john_smith:
    password: jsmithpw
    rep_id: 8675309
    other_info:
      - foo
      - bar
          - baz
```

Alternately, you can replace the "all_items.yml" file in the repo with your yaml file, and then start the service.

Install the Gem
--------------

Install the gem
```ruby
$gem install gertrude
```

Start service, using created yaml file
--------------------------------------

Start the service. In this example, we use rack:
```ruby
$gertrude start -f path/to/yml
```

Request items from the service
------------------------------

Routes are as follows (please replace with your host address, item type, and port)

See all available items, and their properties.
```ruby
  http://0.0.0.0:8080/
```

Get a list of all items available for reservation
```ruby
  http://0.0.0.0:8080/available
```

Reserve an item.
```ruby
  http:/0.0.0.0:8080/reserve/item?type=admin
```

Gertrude will return you the requested item as a hash.
```ruby
 {'admin1' => {'password' => 'admin_password_1', 'other' => 'admin_other'}
```

You can pass a timeout, in seconds (default is 30). Sometimes you have to wait for an item to become available.
```ruby
  http://0.0.0.0:8080/reserve/item?type=admin&timeout=120
```

Get a list of all items that are currently reserved.
```ruby
  http://0.0.0.0:8080/reserved
```

Use the requested items to your hearts content
---------------------------------------------

Enjoy your item, for however long you need to. Go ahead. Have a blast.

Release the item back to the service when you are done
------------------------------------------------------

Release an item back to the service. You can't keep it forever.
```ruby
  http://0.0.0.0:8080/release/item?item=admin1
```

Release all currently reserved items.
```ruby
  http://0.0.0.0:8080/release
```
