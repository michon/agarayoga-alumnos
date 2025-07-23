require "aduki"
require "spec_helper"

describe Aduki::Initializer do

  it "assigns an integer attribute" do
    props = {
      "height"   => "123",
      "weight" => "12.345"
    }

    contraption = Assembly.new props

    expect(contraption.height).to eq 123
    expect(contraption.weight).to eq 12.345
  end
end
