require "aduki"
require "spec_helper"

describe Aduki::Initializer do

  class SomeTimeAgo < Aduki::Initializable
    attr_accessor :days
    def to_date ; Date.today - days         ; end
    def to_time ; Time.now - (days * 86400) ; end
  end

  it "assigns a Date attribute" do
    props = {
      "x" => "The X",
      "y" => "The Y",
      "planned" => "1945-01-19",
    }

    contraption = Contraption.new props

    expect(contraption.planned).to be_a Date
    expect(contraption.planned.year).to eq 1945
    expect(contraption.planned.month).to eq 1
    expect(contraption.planned.day).to eq 19
  end

  it "assigns a Date attribute from something like a Date (ActiveSupport::TimeWithZone, DateTime, Time)" do
    contraption = Contraption.new "planned" => SomeTimeAgo.new(days: 36)
    expect(contraption.planned).to eq(Date.today - 36)

    contraption = Contraption.new "planned" => (Time.now - (86400 * 64))
    expect(contraption.planned).to eq(Date.today - 64)
  end

  it "assigns a Time attribute" do
    props = {
      "x" => "The X",
      "y" => "The Y",
      "updated" => "1945-01-19 15:43",
    }

    contraption = Contraption.new props

    expect(contraption.updated).to be_a Time
    expect(contraption.updated.year).to eq 1945
    expect(contraption.updated.month).to eq 1
    expect(contraption.updated.day).to eq 19
    expect(contraption.updated.hour).to eq 15
    expect(contraption.updated.min).to eq 43
    expect(contraption.updated.sec).to eq 0
  end

  it "assigns a Time attribute from something like a Time" do
    contraption = Contraption.new updated: SomeTimeAgo.new(days: 72.5)
    expect(contraption.updated).to be_a Time
    expected = (Time.now - 72.5 * 86400)
    expect(contraption.updated.to_i).to eq(expected.to_i)

    contraption = Contraption.new updated: (Date.today - 88)
    expect(contraption.updated).to be_a Time
    expect(contraption.updated).to eq((Date.today - 88).to_time)
  end
end
