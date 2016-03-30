$project_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
ARGV[1] = "#{$project_root}/spec/test_items_spec.yml"

require 'sinatra'
require 'pry'
require 'test-helpers/all'
require 'yaml'
require 'json'
require 'rspec'
require 'rack/test'
require_relative '../lib/gertrude/core_ext/hash'
require_relative '../lib/gertrude/items/item_error'
require_relative '../lib/gertrude/items/items_list'
require_relative '../lib/gertrude/items/item_server'

def app
  svr = ItemServer.new
  svr.settings.environment = :production
  svr
end

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = :documentation
  config.include Rack::Test::Methods
end