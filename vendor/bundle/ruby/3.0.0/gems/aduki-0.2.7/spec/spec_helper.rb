require 'aduki'

RSpec.configure do |config|
  # config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.order = 'random'
end

class City < Struct.new(:name)
  CITIES = { }
  def self.aduki_find value
    CITIES[value]
  end

  def register
    CITIES[name] = self
  end
end

City.new("paris"    ).register
City.new("madrid"   ).register
City.new("stockholm").register
City.new("dublin"   ).register

class Gift < Aduki::Initializable
  GIFTS = { }
  attr_accessor :name, :price
  def self.lookup name
    name.is_a?(String) ? GIFTS[name] : name.map { |n| GIFTS[n] }
  end
  def register
    GIFTS[name] = self
  end
end

Gift.new(name: "dinner"    , price: :cheap    ).register
Gift.new(name: "massage"   , price: :cheap    ).register
Gift.new(name: "med_cruise", price: :expensive).register
Gift.new(name: "whiskey"   , price: :medium   ).register
Gift.new(name: "cigars"    , price: :medium   ).register

class Politician < Aduki::Initializable
  attr_accessor :name
  attr_finder :aduki_find, :name, :city
  attr_many_finder :lookup, :name, :gifts
  attr_many_finder :make?, :ohms, :spks, :class_name => "Speaker"
end

class Contraption
  include Aduki::Initializer
  attr_accessor :x, :y, :planned, :updated
  aduki :planned => Date, :updated => Time
end

class Assembly
  include Aduki::Initializer
  attr_writer :weight
  attr_accessor :name, :colour, :size, :height
  aduki :height => Integer, :weight => Float
end

class MachineBuilder
  include Aduki::Initializer
  attr_accessor :name, :email, :phone, :office, :city
  aduki :city => City
end

class Speaker
  include Aduki::Initializer
  attr_accessor :ohms, :diameter, :dimensions
  aduki threads: Float
  aduki_initialize :dates, Array, Date
  aduki_initialize :dimensions, Array, nil
  aduki_initialize :threads, Array, nil

  def self.make? ohms
    ohms.is_a?(Integer) ? Speaker.new(ohms: ohms) : ohms.map { |o| make? o }
  end
end

class Gadget
  include Aduki::Initializer
  attr_accessor :name, :price, :supplier, :variables
  attr_writer :wattage
  aduki_initialize :speaker, Speaker
  aduki_initialize :variables, Aduki::RecursiveHash, nil

  def watts
    @wattage
  end
end

class Machine
  include Aduki::Initializer
  attr_reader :builder
  attr_accessor :name, :weight, :speed, :team
  attr_accessor :dimensions
  aduki :assemblies => Assembly, :builder => MachineBuilder
  aduki :helpers => { :key => MachineBuilder }
end

class Model
  include Aduki::Initializer

  attr_accessor :name, :email, :item, :thing, :gadget
  attr_accessor :machines, :contraptions, :countries
  aduki :gadget => Gadget
  aduki :machines => Machine
  aduki :contraptions => Contraption
end
