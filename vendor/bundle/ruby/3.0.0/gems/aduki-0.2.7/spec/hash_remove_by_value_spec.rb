require 'spec_helper'

describe Hash do
  before { Aduki.install_monkey_patches }

  describe 'recursively_remove_by_value!' do
    class Unwanted < Struct.new(:name)
      def to_s; name; end
    end

    let(:h) {
      {
        :foo   =>  "bar",
        willy: Unwanted.new("wonka"),
        "titi" => [1,2,3, String, "yellow", Unwanted.new(999), 3.1415, {
                     a: :b,
                     c: :d,
                     2  => Unwanted.new(Hash),
                     3  => Unwanted.new(Array),
                     4  => Numeric,
                     6  => {
                       7     => "me",
                       8     => "you",
                       :foo  =>  Unwanted.new("enough!")}} ],
        thats: :it
      }
    }

    it "removes unwanted items" do
      h.recursively_remove_by_value! do |v|
        v.is_a? Unwanted
      end

      expected = {
        foo: "bar",
        thats: :it,
        "titi" => [1, 2, 3, String, "yellow", 3.1415, {:a=>:b, :c=>:d, 4=>Numeric, 6=>{7=>"me", 8=>"you"}}]
      }

      expect(h).to eq(expected)
    end

    it "removes more unwanted items" do
      h.recursively_remove_by_value! do |v|
        k = v.class
        true unless k <= String || k <= Symbol || k <= Hash || k <= Array || k <= Numeric
      end

      expected = {
        foo: "bar",
        thats: :it,
        "titi" => [1, 2, 3, "yellow", 3.1415, {:a=>:b, :c=>:d, 6=>{7=>"me", 8=>"you"}}]
      }

      expect(h).to eq(expected)
    end
  end
end
