require 'active_model'

class TestModel
  extend ActiveModel::Callbacks
  include ActiveModel::Dirty
  include ActiveModel::AttributeMethods

  define_model_callbacks :create, :update, :destroy, :save

  attr_reader :id
  attr_reader :attributes
  attr_accessor :persisted

  def initialize(id, attributes = {})
    @id = id
    @attributes = attributes
  end

  def to_key
    @id
  end

  def attribute(name)
    if @attributes.keys.include?(name.to_sym)
      @attributes[name.to_sym]
    end
  end

  def method_missing(sym, *args, &block)
    if @attributes.keys.include?(sym)
      @attributes[sym]
    else
      super
    end
  end

  def <=>(other)
    self.to_key <=> other.to_key
  end

  def ==(other)
    other ? self.to_key == other.to_key : false
  end

  def save
    run_callbacks :save do
      @persisted ? update : create
      @previously_changed = changes
      @changed_attributes.clear
    end
    self
  end

  def destroy
    run_callbacks :destroy do
      @@database ||= {}
      @@database[@id] = nil
    end
  end

  def update_attributes(attributes)
    attributes.keys.each do |key|
      unless @attributes[key] == attributes[key]
        self.send("#{key}_will_change!")
      end
    end
    @attributes.merge!(attributes)
    save
  end

  def self.create(id, attributes = {})
    self.new(id, attributes).save
  end

  def self.find(*ids)
    @@database ||= {}
    ids.flatten.map do |id|
      if @@database[id]
        doc = self.new(id, @@database[id])
        doc.persisted = true
        doc
      end
    end
  end

  def self.reset
    @@database = {}
  end

protected

  def create
    run_callbacks :create do
      @@database ||= {}
      @@database[@id] = @attributes
    end
  end

  def update
    run_callbacks :update do
      @@database ||= {}
      @@database[@id] = @attributes
    end
  end

end
