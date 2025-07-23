require "aduki"
require "spec_helper"

describe Aduki::Initializer do

  PROPS = {
    "name"            => "Willy",
    "email"           => "willy@wonka.softify.com",
    "item"            => "HXB5H",
    "thing"           => "0",
    "gadget.name"     => "My Big Gadget",
    "gadget.price"    => "21",
    "gadget.supplier" => "Apple, Inc.",
    "machines[0].name" => "The First Machine",
    "machines[0].weight" => "88",
    "machines[0].speed" => "142",
    "machines[0].builder.name"   => "The First Machine Builder",
    "machines[0].builder.email"  => "wibble@bump",
    "machines[0].builder.phone"  => "4099",
    "machines[0].builder.office" => "2nd floor room 12",
    "machines[0].assemblies[0].name"   => "first machine, first assembly", # the array index orders items without respecting the exact position
    "machines[0].assemblies[1].name"   => "first machine, second assembly",
    "machines[0].assemblies[2].name"   => "first machine, third assembly",
    "machines[0].assemblies[0].colour" => "red",
    "machines[0].assemblies[1].colour" => "green",
    "machines[0].assemblies[2].colour" => "blue",
    "machines[0].assemblies[0].size"   => "pretty large",
    "machines[0].assemblies[1].size"   => "sort of medium",
    "machines[0].assemblies[2].size"   => "miniscule",
    "machines[0].dimensions[0]"   => "2346.56",
    "machines[0].dimensions[1]"   => "6456.64",
    "machines[0].dimensions[2]"   => "3859.39",
    "machines[0].dimensions[3]"   => "2365.68",
    "machines[0].team.lead"       => "Shakespeare", # there is no class definition for #team, so Aduki will apply a hash with properties #lead, #code, #design
    "machines[0].team.code"       => "Chaucer",
    "machines[0].team.design"     => "Jobs",
    "machines[0].helpers.jim.name"   => "Jim Appleby",
    "machines[0].helpers.jim.email"  => "Jim.Appleby@example.com",
    "machines[0].helpers.jim.phone"  => "123 456 789",
    "machines[0].helpers.jim.office" => "Elephant & Castle",
    "machines[0].helpers.ben.name"   => "Ben Barnes",
    "machines[0].helpers.ben.email"  => "Ben.Barnes@example.com",
    "machines[0].helpers.ben.phone"  => "123 456 790",
    "machines[0].helpers.ben.office" => "Cockney",
    "machines[0].helpers.pat.name"   => "Patrick O'Brien",
    "machines[0].helpers.pat.email"  => "Patrick.O.Brien@example.com",
    "machines[0].helpers.pat.phone"  => "123 456 791",
    "machines[0].helpers.pat.office" => "Hammersmith",
    "machines[1].name"           => "The Second Machine",
    "machines[1].weight"         => "34",
    "machines[1].speed"          => "289",
    "machines[1].builder.name"   => "The Second Machine Builder",
    "machines[1].builder.email"  => "waggie@bump",
    "machines[1].builder.phone"  => "4101",
    "machines[1].builder.office" => "3rd floor room 23",
    "machines[1].assemblies[98].name"   => "second machine, first assembly",  # the array index orders items but the position is not respected
    "machines[1].assemblies[98].colour" => "purple",
    "machines[1].assemblies[98].size"   => "pretty small",
    "machines[1].assemblies[1].name"   => "second machine, second assembly",
    "machines[1].assemblies[1].colour" => "turquoise",
    "machines[1].assemblies[1].size"   => "large-ish",
    "machines[1].assemblies[99].name"   => "second machine, third assembly",
    "machines[1].assemblies[99].colour" => "magenta",
    "machines[1].assemblies[99].size"   => "gigantic",
    "machines[1].dimensions[20]"   => "1985.85",
    "machines[1].dimensions[30]"   => "7234.92",
    "machines[1].dimensions[40]"   => "9725.52",
    "machines[1].dimensions[50]"   => "3579.79",
    "machines[1].team.lead"       => "Joyce",
    "machines[1].team.code"       => "O'Brien",
    "machines[1].team.design"     => "Moore",
    "machines[1].team.muffins"    => "MacNamara",
    "contraptions[0].x"          => "19",
    "contraptions[0].y"          => "0.003",
    "contraptions[1].x"          => "12",
    "contraptions[1].y"          => "0.0012",
    "contraptions[2].x"          => "24",
    "contraptions[2].y"          => "0.00063",
    "contraptions[3].x"          => "16",
    "contraptions[3].y"          => "0.00091",
    "countries[0]"               => "France",
    "countries[1]"               => "Sweden",
    "countries[2]"               => "Germany",
    "countries[3]"               => "Ireland",
    "countries[4]"               => "Spain",
  }

  it "sets a bunch of properties from a hash of property paths" do
    props = PROPS

    model = Model.new props

    expect(model.name).to eq "Willy"
    expect(model.email).to eq "willy@wonka.softify.com"
    expect(model.item).to eq "HXB5H"
    expect(model.thing).to eq "0"
    expect(model.gadget.name).to eq "My Big Gadget"
    expect(model.gadget.price).to eq "21"
    expect(model.gadget.supplier).to eq "Apple, Inc."
    expect(model.gadget.speaker).to be_a Speaker
    expect(model.gadget.speaker.ohms).to eq nil
    expect(model.machines[0].name).to eq "The First Machine"
    expect(model.machines[0].weight).to eq "88"
    expect(model.machines[0].speed).to eq "142"
    expect(model.machines[0].builder.name).to eq "The First Machine Builder"
    expect(model.machines[0].builder.email).to eq "wibble@bump"
    expect(model.machines[0].builder.phone).to eq "4099"
    expect(model.machines[0].builder.office).to eq "2nd floor room 12"
    expect(model.machines[0].assemblies[0].name).to eq "first machine, first assembly"
    expect(model.machines[0].assemblies[0].colour).to eq "red"
    expect(model.machines[0].assemblies[0].size).to eq "pretty large"
    expect(model.machines[0].assemblies[1].name).to eq "first machine, second assembly"
    expect(model.machines[0].assemblies[1].colour).to eq "green"
    expect(model.machines[0].assemblies[1].size).to eq "sort of medium"
    expect(model.machines[0].assemblies[2].name).to eq "first machine, third assembly"
    expect(model.machines[0].assemblies[2].colour).to eq "blue"
    expect(model.machines[0].assemblies[2].size).to eq "miniscule"
    expect(model.machines[0].dimensions[0]).to eq "2346.56"
    expect(model.machines[0].dimensions[1]).to eq "6456.64"
    expect(model.machines[0].dimensions[2]).to eq "3859.39"
    expect(model.machines[0].dimensions[3]).to eq "2365.68"
    expect(model.machines[0].team).to eq({ "lead" => "Shakespeare", "code" => "Chaucer", "design" => "Jobs"})
    expect(model.machines[0].helpers["jim"]).to be_a MachineBuilder
    expect(model.machines[0].helpers["jim"].name).to eq "Jim Appleby"
    expect(model.machines[0].helpers["jim"].email).to eq "Jim.Appleby@example.com"
    expect(model.machines[0].helpers["jim"].phone).to eq "123 456 789"
    expect(model.machines[0].helpers["jim"].office).to eq "Elephant & Castle"
    expect(model.machines[0].helpers["ben"]).to be_a MachineBuilder
    expect(model.machines[0].helpers["ben"].name).to eq "Ben Barnes"
    expect(model.machines[0].helpers["ben"].email).to eq "Ben.Barnes@example.com"
    expect(model.machines[0].helpers["ben"].phone).to eq "123 456 790"
    expect(model.machines[0].helpers["ben"].office).to eq "Cockney"
    expect(model.machines[0].helpers["pat"]).to be_a MachineBuilder
    expect(model.machines[0].helpers["pat"].name).to eq "Patrick O'Brien"
    expect(model.machines[0].helpers["pat"].email).to eq "Patrick.O.Brien@example.com"
    expect(model.machines[0].helpers["pat"].phone).to eq "123 456 791"
    expect(model.machines[0].helpers["pat"].office).to eq "Hammersmith"
    expect(model.machines[1].name).to eq "The Second Machine"
    expect(model.machines[1].weight).to eq "34"
    expect(model.machines[1].speed).to eq "289"
    expect(model.machines[1].builder.name).to eq "The Second Machine Builder"
    expect(model.machines[1].builder.email).to eq "waggie@bump"
    expect(model.machines[1].builder.phone).to eq "4101"
    expect(model.machines[1].builder.office).to eq "3rd floor room 23"
    expect(model.machines[1].assemblies[0].name).to eq "second machine, second assembly"
    expect(model.machines[1].assemblies[0].colour).to eq "turquoise"
    expect(model.machines[1].assemblies[0].size).to eq "large-ish"
    expect(model.machines[1].assemblies[1].name).to eq "second machine, first assembly"
    expect(model.machines[1].assemblies[1].colour).to eq "purple"
    expect(model.machines[1].assemblies[1].size).to eq "pretty small"
    expect(model.machines[1].assemblies[2].name).to eq "second machine, third assembly"
    expect(model.machines[1].assemblies[2].colour).to eq "magenta"
    expect(model.machines[1].assemblies[2].size).to eq "gigantic"
    expect(model.machines[1].dimensions[0]).to eq "1985.85"
    expect(model.machines[1].dimensions[1]).to eq "7234.92"
    expect(model.machines[1].dimensions[2]).to eq "9725.52"
    expect(model.machines[1].dimensions[3]).to eq "3579.79"
    expect(model.machines[1].team).to eq({ "lead" => "Joyce", "code" => "O'Brien", "design" => "Moore", "muffins" => "MacNamara"})
    expect(model.contraptions[0].x).to eq "19"
    expect(model.contraptions[0].y).to eq "0.003"
    expect(model.contraptions[1].x).to eq "12"
    expect(model.contraptions[1].y).to eq "0.0012"
    expect(model.contraptions[2].x).to eq "24"
    expect(model.contraptions[2].y).to eq "0.00063"
    expect(model.contraptions[3].x).to eq "16"
    expect(model.contraptions[3].y).to eq "0.00091"
    expect(model.countries[0]).to eq "France"
    expect(model.countries[1]).to eq "Sweden"
    expect(model.countries[2]).to eq "Germany"
    expect(model.countries[3]).to eq "Ireland"
    expect(model.countries[4]).to eq "Spain"

    sensibly_indexed_props = props.merge({
                                           "machines[1].assemblies[0].name"   => "second machine, second assembly",
                                           "machines[1].assemblies[0].colour" => "turquoise",
                                           "machines[1].assemblies[0].size"   => "large-ish",
                                           "machines[1].assemblies[1].name"   => "second machine, first assembly",
                                           "machines[1].assemblies[1].colour" => "purple",
                                           "machines[1].assemblies[1].size"   => "pretty small",
                                           "machines[1].assemblies[2].name"   => "second machine, third assembly",
                                           "machines[1].assemblies[2].colour" => "magenta",
                                           "machines[1].assemblies[2].size"   => "gigantic",
                                           "machines[1].dimensions[0]"   => "1985.85",
                                           "machines[1].dimensions[1]"   => "7234.92",
                                           "machines[1].dimensions[2]"   => "9725.52",
                                           "machines[1].dimensions[3]"   => "3579.79",
                                         })

    silly_keys = [ "machines[1].assemblies[98].name",
                   "machines[1].assemblies[98].colour",
                   "machines[1].assemblies[98].size",
                   "machines[1].assemblies[99].name",
                   "machines[1].assemblies[99].colour",
                   "machines[1].assemblies[99].size",
                   "machines[1].dimensions[20]",
                   "machines[1].dimensions[30]",
                   "machines[1].dimensions[40]",
                   "machines[1].dimensions[50]"]

    silly_keys.each { |k| sensibly_indexed_props.delete k }

    expect(Aduki.to_aduki(model)).to eq sensibly_indexed_props
  end

  it "initializes attributes of pre-initialized nested objects" do
    props = {
      "name"                => "Brackish Water",
      "gadget.name"         => "The Loud Gadget",
      "gadget.speaker.ohms" => "29",
      "gadget.speaker.dates[1]" => "2015-03-12",
      "gadget.speaker.dates[2]" => "2015-06-08",
      "gadget.speaker.dates[3]" => "2015-06-21",
    }

    model = Model.new props

    expect(model.name).to eq "Brackish Water"
    expect(model.gadget.name).to eq "The Loud Gadget"
    expect(model.gadget.speaker).to be_a Speaker
    expect(model.gadget.speaker.ohms).to eq "29"

    expect(model.gadget.speaker.dates).to eq [ Date.parse("2015-03-12"), Date.parse("2015-06-08"), Date.parse("2015-06-21") ]
  end

  it "handles pre-initialized arrays without a given array type" do
    props = {
      "name"                => "Brackish Water",
      "gadget.name"         => "The Loud Gadget",
      "gadget.speaker.ohms" => "29",
      "gadget.speaker.dimensions[1]" => "12",
      "gadget.speaker.dimensions[2]" => "8",
      "gadget.speaker.dimensions[3]" => "21",
    }

    model = Model.new props

    expect(model.gadget.speaker.dimensions).to eq [ "12", "8", "21" ]
  end

  it "handles pre-initialized arrays with a previously-set array type" do
    props = {
      "name"                => "Brackish Water",
      "gadget.name"         => "The Loud Gadget",
      "gadget.speaker.ohms" => "29",
      "gadget.speaker.threads[1]" => "12.4",
      "gadget.speaker.threads[2]" => "8.16",
      "gadget.speaker.threads[3]" => "21.42",
    }

    model = Model.new props

    expect(model.gadget.speaker.threads).to eq [ 12.4, 8.16, 21.42 ]
  end

  it "handles pre-initialized hashes" do
    props = {
      "name"                => "Brackish Water",
      "gadget.name"         => "The Loud Gadget",
      "gadget.variables.x" => "29",
      "gadget.variables.y" => "12.4",
      "gadget.variables.z" => "8.16",
    }

    model = Model.new props

    expect(model.gadget.variables).to eq({ "x"=> "29", "y" => "12.4", "z" => "8.16"})
  end

  it "handles pre-initialized hashes with more complex subkeys" do
    props = {
      "name"                => "Brackish Water",
      "gadget.name"         => "The Loud Gadget",
      "gadget.variables.x[4]" => "24",
      "gadget.variables.x[7]" => "27",
      "gadget.variables.x[3].length" => "3",
      "gadget.variables.x[3].width"  => "13",
      "gadget.variables.x[3].depth[0]"       => "23",
      "gadget.variables.x[3].depth[1].high"  => "23+10",
      "gadget.variables.x[3].depth[1].low"   => "23-10",
      "gadget.variables.x[3].depth[2]"       => "33",
      "gadget.variables.y.fortune"   => "flavours",
      "gadget.variables.y.help"      => "F1",
      "gadget.variables.y.pandora"   => "boxy",
      "gadget.variables.z" => "8.16",
    }

    model = Model.new props

    expected = {
      "x"=> [
             nil,
             nil,
             nil,
             {
               "length" => "3",
               "width" => "13",
               "depth" => [
                           "23",
                           { "high" => "23+10", "low" => "23-10"},
                           "33"
                          ],
             },
             "24",
             nil,
             nil,
             "27"
            ],
      "y" => {
        "fortune" => "flavours",
        "help" => "F1",
        "pandora" => "boxy"},
      "z" => "8.16"
    }
    expect(model.gadget.variables).to eq expected
  end

  it "creates a new hash by recursively splitting string keys on separator-character" do
    props = {
      "name"                => "Brackish Water",
      "gadget.name"         => "The Loud Gadget",
      "gadget.variables.x[4]" => "24",
      "gadget.variables.x[7]" => "27",
      "gadget.variables.x[3].length" => "3",
      "gadget.variables.x[3].width"  => "13",
      "gadget.variables.x[3].depth[0]"       => "23",
      "gadget.variables.x[3].depth[1].high"  => "23+10",
      "gadget.variables.x[3].depth[1].low"   => "23-10",
      "gadget.variables.x[3].depth[2]"       => "33",
      "gadget.variables.y.fortune"   => "flavours",
      "gadget.variables.y.help"      => "F1",
      "gadget.variables.y.pandora"   => "boxy",
      "gadget.variables.z" => "8.16",
    }

    hash = Aduki::RecursiveHash.new.copy props
    expected = {
      "name" => "Brackish Water",
      "gadget" => {
        "name" => "The Loud Gadget",
        "variables" => {
          "x"=> [
                 nil,
                 nil,
                 nil,
                 {
                   "length" => "3",
                   "width" => "13",
                   "depth" => [
                               "23",
                               { "high" => "23+10", "low" => "23-10"},
                               "33"
                              ],
                 },
                 "24",
                 nil,
                 nil,
                 "27"
                ],
          "y" => {
            "fortune" => "flavours",
            "help" => "F1",
            "pandora" => "boxy"},
          "z" => "8.16"
        }
      }
    }
    expect(hash).to eq expected
  end
end
