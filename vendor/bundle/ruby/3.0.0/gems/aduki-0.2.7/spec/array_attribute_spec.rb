require "aduki"
require "spec_helper"

describe Aduki::Initializer do
  it "assigns an integer attribute of an object nested in an array attribute" do
    props = {
      "name"         => "Foo",
      "assemblies"   => [{ "name" => "A0", "height" => "10" }, { "name" => "A1", "height" => "20" }, { "name" => "A2", "height" => "30" }, ],
      "dimensions"   => [{ x: 1, y: 2, z: 34.5}, { x: 17, y: 23, z: 34.5}, ]
    }

    machine = Machine.new props

    expect(machine.name).to eq "Foo"

    expect(machine.assemblies[0].name).to eq "A0"
    expect(machine.assemblies[0].height).to eq 10

    expect(machine.assemblies[1].name).to eq "A1"
    expect(machine.assemblies[1].height).to eq 20

    expect(machine.assemblies[2].name).to eq "A2"
    expect(machine.assemblies[2].height).to eq 30

    expect(machine.dimensions[0][:x]).to eq 1
    expect(machine.dimensions[0][:y]).to eq 2
    expect(machine.dimensions[0][:z]).to eq 34.5

    expect(machine.dimensions[1][:x]).to eq 17
    expect(machine.dimensions[1][:y]).to eq 23
    expect(machine.dimensions[1][:z]).to eq 34.5
  end
end
