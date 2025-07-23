require "aduki"
require "spec_helper"

describe Aduki do
  it "returns a plain hash structure" do
    hsh = { "foo" => "bar" }
    props = Aduki.to_aduki hsh
    expect(props).to eq({ "foo" => "bar" })
  end

  it "should flatten nested keys" do
    hsh = { "foo" => "bar", "bing" => { "boo" => "wogga", "tingle" => "wimp" } }
    props = Aduki.to_aduki hsh
    expect(props).to eq({
      "foo"         => "bar",
      "bing.boo"    => "wogga",
      "bing.tingle" => "wimp"
    })
  end

  it "flattens deeply nested keys" do
    hsh = {
      "foo" => "bar",
      "bing" => {
        "boo" => "wogga",
        "tingle" => "wimp",
        "harpoon" => {
          "shonk" => "twaddle",
          "scorn" => "shart"
        }} }
    props = Aduki.to_aduki hsh
    expect(props).to eq({
      "foo"         => "bar",
      "bing.boo"    => "wogga",
      "bing.tingle" => "wimp",
      "bing.harpoon.shonk" => "twaddle",
      "bing.harpoon.scorn" => "shart",
    })
  end

  it "flattens array keys also " do
    hsh = {
      "foo" => "bar",
      "bing" => {
        "boo" => "wogga",
        "tingle" => "wimp",
        "harpoon" => ["shonk",
                      "twaddle",
                      "scorn",
                      "shart" ]
      } }
    props = Aduki.to_aduki hsh
    expect(props).to eq({
      "foo"         => "bar",
      "bing.boo"    => "wogga",
      "bing.tingle" => "wimp",
      "bing.harpoon[0]" => "shonk",
      "bing.harpoon[1]" => "twaddle",
      "bing.harpoon[2]" => "scorn",
      "bing.harpoon[3]" => "shart",
    })
  end

  it "flattens nested arrays " do
    hsh = {
      "foo" => "bar",
      "bing" => {
        "boo" => "wogga",
        "tingle" => "wimp",
        "harpoon" => ["shonk",
                      "twaddle",
                      %w{alpha beta gamma},
                      { :wing => :tip, :tail => :fin } ]
      } }
    props = Aduki.to_aduki hsh
    expect(props).to eq({
      "foo"         => "bar",
      "bing.boo"    => "wogga",
      "bing.tingle" => "wimp",
      "bing.harpoon[0]" => "shonk",
      "bing.harpoon[1]" => "twaddle",
      "bing.harpoon[2][0]" => "alpha",
      "bing.harpoon[2][1]" => "beta",
      "bing.harpoon[2][2]" => "gamma",
      "bing.harpoon[3].wing" => :tip,
      "bing.harpoon[3].tail" => :fin,
    })
  end

  it "flattens aduki objects " do
    hsh = {
      "foo" => "bar",
      "bing" => {
        "boo" => "wogga",
        "tingle" => "wimp",
        "harpoon" => ["shonk",
                      "twaddle",
                      %w{alpha beta gamma},
                      { :wing => :tip, :tail => :fin } ]
      } }
    props = Aduki.to_aduki hsh
    expect(props).to eq({
      "foo"         => "bar",
      "bing.boo"    => "wogga",
      "bing.tingle" => "wimp",
      "bing.harpoon[0]" => "shonk",
      "bing.harpoon[1]" => "twaddle",
      "bing.harpoon[2][0]" => "alpha",
      "bing.harpoon[2][1]" => "beta",
      "bing.harpoon[2][2]" => "gamma",
      "bing.harpoon[3].wing" => :tip,
      "bing.harpoon[3].tail" => :fin,
    })
  end
end
