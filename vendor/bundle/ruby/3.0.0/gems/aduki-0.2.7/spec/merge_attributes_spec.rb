require "aduki"
require "spec_helper"

describe Aduki::Initializer do
  it "initializes attributes of pre-initialized nested objects" do
    props = {
      "name"                => "Brackish Water",
      "gadget.name"         => "The Loud Gadget",
      "gadget.speaker.ohms" => "29",
      "gadget.speaker.dates[1]" => "2014-03-12",
      "gadget.speaker.dates[2]" => "2014-06-08",
      "gadget.speaker.dates[3]" => "2014-06-21",
    }

    model = Model.new props

    expect(model.name).                   to eq "Brackish Water"
    expect(model.gadget.name).            to eq "The Loud Gadget"
    expect(model.gadget.price).           to eq nil
    expect(model.gadget.speaker.ohms).    to eq "29"
    expect(model.gadget.speaker.diameter).to eq nil
    expect(model.gadget.speaker.dates).to eq [ Date.parse("2014-03-12"), Date.parse("2014-06-08"), Date.parse("2014-06-21") ]

    more_props = {
      "name"                    => "Smelly Brackish Water",
      "gadget.price"            => "42",
      "gadget.speaker.diameter" => "large",
      "gadget.speaker.dates[1]" => "2015-06-21",
      "gadget.speaker.dates[2]" => "2015-03-12",
      "gadget.speaker.dates[3]" => "2015-06-08",
    }

    Aduki.apply_attributes model, more_props

    expect(model.name).                   to eq "Smelly Brackish Water"
    expect(model.gadget.name).            to eq "The Loud Gadget"
    expect(model.gadget.price).           to eq "42"
    expect(model.gadget.speaker.ohms).    to eq "29"
    expect(model.gadget.speaker.diameter).to eq "large"
    expect(model.gadget.speaker.dates).to eq [ Date.parse("2014-03-12"), Date.parse("2014-06-08"), Date.parse("2014-06-21"), Date.parse("2015-06-21"), Date.parse("2015-03-12"), Date.parse("2015-06-08") ]
  end

  it "does not die when reader accessor is absent" do
    props = {
      "name"                => "Brackish Water",
      "gadget.wattage"      => "240",
      "gadget.name"         => "The Loud Gadget",
      "gadget.speaker.ohms" => "29"
    }

    model = Model.new props

    expect(model.name).                   to eq "Brackish Water"
    expect(model.gadget.name).            to eq "The Loud Gadget"
    expect(model.gadget.price).           to eq nil
    expect(model.gadget.watts).           to eq "240"
    expect(model.gadget.speaker.ohms).    to eq "29"
    expect(model.gadget.speaker.diameter).to eq nil
  end

  it "does not die when an existing value is present" do
    props = {
      "name"                => "Brackish Water",
      "gadget.wattage"      => "240",
      "gadget.name"         => "The Loud Gadget",
      "gadget.speaker.ohms" => "29"
    }

    model = Model.new props

    more_props = {
      "name"                    => "Smelly Brackish Water",
      "gadget.wattage"          => "120",
      "gadget.speaker.diameter" => "large"
    }

    Aduki.apply_attributes model, more_props

    expect(model.name).                   to eq "Smelly Brackish Water"
    expect(model.gadget.name).            to eq "The Loud Gadget"
    expect(model.gadget.price).           to eq nil
    expect(model.gadget.watts).           to eq "120"
    expect(model.gadget.speaker.ohms).    to eq "29"
    expect(model.gadget.speaker.diameter).to eq "large"
  end


  it "merges a hash attribute" do
    props = {
      "name"                => "Brackish Water",
      "gadget.name"         => "The Loud Gadget",
      "gadget.variables.x" => "29",
      "gadget.variables.y" => "12.4",
      "gadget.variables.z" => "8.16",
    }

    model = Model.new props

    more_props = {
      "gadget.variables.x.left"     => "strong",
      "gadget.variables.x.right"    => "central",
      "gadget.variables.y.left"     => "weak",
      "gadget.variables.y.right"    => "mirror",
      "gadget.variables.other"      => "central",
    }

    Aduki.apply_attributes model, more_props

    expected = {
      "x"=> {
        "left"  => "strong",
        "right" => "central",
      },
      "y" => {
        "left"  => "weak",
        "right" => "mirror",
      },
      "z" => "8.16",
      "other" => "central"
    }

    expect(model.gadget.variables).to eq expected
  end

end
