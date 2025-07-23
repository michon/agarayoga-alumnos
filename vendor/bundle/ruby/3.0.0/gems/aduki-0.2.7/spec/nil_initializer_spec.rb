require "aduki"
require "spec_helper"

describe Aduki::Initializer do

  it "silently accepts nil initializer parameter" do
    contraption = Assembly.new

    expect(contraption.name  ).to be_nil
    expect(contraption.colour).to be_nil
    expect(contraption.height).to be_nil
    expect(contraption.weight).to be_nil
  end

  it "silently accepts empty-string initializer parameter" do
    contraption = Assembly.new ""

    expect(contraption.name  ).to be_nil
    expect(contraption.colour).to be_nil
    expect(contraption.height).to be_nil
    expect(contraption.weight).to be_nil
  end
end
