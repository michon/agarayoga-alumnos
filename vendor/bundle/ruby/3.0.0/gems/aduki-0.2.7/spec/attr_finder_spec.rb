require "aduki"
require "spec_helper"

describe Aduki::AttrFinder do
  it "assigns a value using attr_finder" do
    props = {
      "name"           => "Eamonn de Valera",
      "city_name"      => "dublin",
      "gift_names[0]"  => "dinner",
      "gift_names[1]"  => "whiskey",
      "gift_names[2]"  => "cigars",
      "spk_ohms[0]"    => 101,
      "spk_ohms[1]"    => 104,
      "spk_ohms[2]"    =>  98,
    }

    politician = Politician.new props

    expect(politician.name).to eq "Eamonn de Valera"
    expect(politician.city).to eq City::CITIES["dublin"]
    expect(politician.city.name).to eq "dublin"
    expect(politician.gifts).to eq [Gift.lookup("dinner"), Gift.lookup("whiskey"), Gift.lookup("cigars")]

    expect(politician.spks)                  .to be_a Array
    expect(politician.spks.map(&:class).uniq).to eq [Speaker]
    expect(politician.spks.map(&:ohms))      .to eq [101, 104, 98]
  end

  it "does not override a value with unknown identifier" do
    politician = Politician.new city: City.new(""), gifts: [Gift.new(name: "")]

    expect(politician.city.name).to eq ""
    expect(politician.gifts.map(&:name)).to eq [""]
  end
end
