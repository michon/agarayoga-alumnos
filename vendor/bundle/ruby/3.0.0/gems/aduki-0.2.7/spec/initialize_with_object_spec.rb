require "aduki"
require "spec_helper"

describe Aduki::Initializer do

  it "assigns pre-built objects" do
    m = Model.new gadget: Gadget.new(name: "bongo")
    expect(m.gadget.name).to eq "bongo"
  end
end
