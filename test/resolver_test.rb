require File.expand_path('test/test_helper')
require File.expand_path('test/test_model')

class ResolverTest < Test::Unit::TestCase

  TestModel.send(:include, Resolver::Key)

  def setup
    Resolver.redis.flushall
    TestModel.reset
  end

  def test_can_set_a_namespace_through_a_url_like_string
    assert Resolver.redis
    assert_equal :resolver, Resolver.redis.namespace
    Resolver.redis = 'localhost:9736/namespace'
    assert_equal 'namespace', Resolver.redis.namespace
  end

  def test_key
    TestModel.key(:example)
    TestModel.create('one', :example => 'foo')
    TestModel.create('two', :example => 'foo')
    assert_equal [TestModel.new('one'), TestModel.new('two')], TestModel.find_by(:example, 'foo').sort
    assert_equal [], TestModel.find_by(:example, 'bar')
    assert_equal true, TestModel.exists_with?(:example, 'foo')
    assert_equal false, TestModel.exists_with?(:example, 'bar')
    assert_equal 2, TestModel.count_with(:example, 'foo')
    assert_equal 0, TestModel.count_with(:example, 'bar')
    TestModel.find('one').first.destroy
    TestModel.find('two').first.destroy
    assert_equal 0, TestModel.count_with(:example, 'foo')
    assert_equal false, TestModel.exists_with?(:example, 'foo')
  end

  def test_key_moving
    TestModel.key(:example)
    one = TestModel.create('one', :example => 'foo')
    assert_equal [one], TestModel.find_by(:example, 'foo')
    one.update_attributes(:example => 'bar')
    assert_equal [], TestModel.find_by(:example, 'foo')
    assert_equal [one], TestModel.find_by(:example, 'bar')
  end

  def test_unique_key
    TestModel.key(:example, :unique => true)
    TestModel.create('one', :example => 'foo')
    TestModel.create('two', :example => 'foo')
    assert_equal [TestModel.new('one')], TestModel.find_by(:example, 'foo')
    assert_equal true, TestModel.exists_with?(:example, 'foo')
    assert_equal false, TestModel.exists_with?(:example, 'bar')
    assert_equal 1, TestModel.count_with(:example, 'foo')
    assert_equal 0, TestModel.count_with(:example, 'bar')
    TestModel.find('one').first.destroy
    TestModel.find('two').first.destroy
    assert_equal 0, TestModel.count_with(:example, 'foo')
    assert_equal false, TestModel.exists_with?(:example, 'foo')
  end

end
