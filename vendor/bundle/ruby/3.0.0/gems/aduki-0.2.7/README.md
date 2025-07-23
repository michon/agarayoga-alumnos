# Aduki

Aduki is an attribute setter inspired only a little bit by the "Bean" concept in Java. Here's the idea:

    props = {
      "name" => "Wilbur",
      "size" => "3",
      "gadgets[0].id"         => "FHB5S",
      "gadgets[0].position.x" => "0.45",
      "gadgets[0].position.y" => "0.97",
      "gadgets[1].id"         => "SVE21",
      "gadgets[1].position.x" => "0.31",
      "gadgets[1].position.y" => "0.34",
    }

    model = Model.new props

At this point, #model is an instance of Model with its #name, and #size properties initialized as you would expect, and its #gadgets is an array of length 2, with each object initialized as you would expect.


## Installation

Add this line to your application's Gemfile:

    gem 'aduki'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aduki

## Usage

For a complete example, please see the specs.

#### Initializing attributes

    class Assembly
      include Aduki::Initializer
      attr_accessor :name, :colour, :size
    end

    a = Assembly.new name: "Cooker", colour: "blue", size: "4"

    a.name   # => "Cooker"
    a.colour # => "blue"
    a.size   # => "4"

So far, so unsurprising. Let's tell aduki that `size` is an integer

    class Machine

    class Assembly
      include Aduki::Initializer
      attr_accessor :name, :colour
      aduki size: Integer
    end

    a = Assembly.new name: "Cooker", colour: "blue", size: "4"

    a.name   # => "Cooker"
    a.colour # => "blue"
    a.size   # => 4

Yay!

#### Nested object types

Suppose you have a Machine that uses an Assembly instance

    class Machine
      include Aduki::Initializer
      attr_accessor :name, :speed
      aduki :assembly => Assembly
    end

    class Assembly
      include Aduki::Initializer
      attr_accessor :name, :colour
      aduki size: Integer
    end

    props = {
      "name"            => "Guillotine",
      "speed"           => "fast",
      "assembly.name"   => "blade",
      "assembly.colour" => "steely-blue",
      "assembly.size"   => "12",
    }

    m = Machine.new props

    m.name            # => "Guillotine"
    m.assembly.name   # => "blade"
    m.assembly.colour # => "steely-blue"
    m.assembly.size   # => 12

However, in this configuration, if you don't specify attributes for the Assembly, it will be nil:

    props = {
      "name"            => "Guillotine",
      "speed"           => "fast",
    }

    m = Machine.new props

    m.name            # => "Guillotine"
    m.assembly        # => nil

You can specify an initializer for `assembly` thus:

    class Machine
      include Aduki::Initializer
      attr_accessor :name, :speed
      aduki_initialize :assembly, Assembly
    end

    props = {
      "name"            => "Guillotine",
      "speed"           => "fast",
    }

    m = Machine.new props

    m.name            # => "Guillotine"
    m.assembly.name   # => nil


#### Nested array types

What if your Machine needs an array of Assembly instances?

    class Machine
      include Aduki::Initializer
      attr_accessor :name, :speed
      aduki :assemblies => Assembly
    end

    props = {
      "name"                 => "Truck",
      "assemblies[0].name"   => "cabin",
      "assemblies[0].colour" => "orange",
      "assemblies[0].size"   => "12",
      "assemblies[1].name"   => "trailer",
      "assemblies[1].colour" => "green",
      "assemblies[1].size"   => "48",
    }

    m = Machine.new props

    m.name                 # => "Truck"
    m.assemblies[0].name   # => "cabin"
    m.assemblies[0].colour # => "orange"
    m.assemblies[0].size   # => 12
    m.assemblies[1].name   # => "trailer"
    m.assemblies[1].colour # => "green"
    m.assemblies[1].size   # => 48

However, like before, if there are no `assemblies` declarations in the initializer parameter, the `assemblies` attribute will be nil:

    props = {
      "name"                 => "Truck",
    }

    m = Machine.new props

    m.name         # => "Truck"
    m.assemblies   # => nil


If you want to be sure to always have an array, even empty, do this:

    class Machine
      include Aduki::Initializer
      attr_accessor :name, :speed
      aduki_initialize :assemblies, Array, Assembly
    end

    props = {
      "name"                 => "Truck",
    }

    m = Machine.new props

    m.name         # => "Truck"
    m.assemblies   # => []


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
