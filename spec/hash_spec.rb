require 'spec_helper'

describe('Hash') do
  before(:each) do
    @some_hash = {foo: {bar: {bat: 'thing'}}}
  end

  describe('#has_deep_key') do
    it('should return true if deep key exists') do
      expect(@some_hash.has_deep_key?(:bar)).to be true
    end

    it('should return false if deep key does not exist') do
      expect(@some_hash.has_deep_key?(:blah)).to be false
    end
  end

  describe('#has_deep_value') do
    it('should return true if deep value exists') do
      expect(@some_hash.has_deep_value?('thing')).to be true
    end

    it('should return false if deep value does not exist') do
      expect(@some_hash.has_deep_value?('not there')).to be false
    end
  end

  describe('#deep_find') do
    it('should return hash if key value is hash') do
      expect(@some_hash.deep_find(:bar)).to eql({bat: 'thing'})
    end

    it('should return value if key is not a hash') do
      expect(@some_hash.deep_find(:bat)).to eql 'thing'
    end

    it('should return first value for duplicate keys') do
      @some_hash = {foo: {bar: {foo: 'thing'}}}
      expect(@some_hash.deep_find(:foo)).to eql({bar: {foo: 'thing'}})
    end
  end
end

