require 'spec_helper'

describe Hash do
  before { Aduki.install_monkey_patches }

  describe 'recursively_delete_keys!' do
    it "deletes the specified keys from itself and all nested hashes, even sub-nested in arrays" do
      h = {
        site_id: "foo",
        "site_id" => :bar,
        things: {
          site_id: "toto",
          "site_id" => :titi,
          2 => [ { a: 12, b: 53, site_id: 99 },
                 { a: 13, b: 54, site_id: 98 },
                 { a: 14, b: 55, site_id: 97 },
                 { a: 14, b: 56, site_id: 96 } ],
          toto: :titi
        },
        others: [ { name: "Walter", site_id: 95 } ]
      }

      h.recursively_delete_keys! :site_id, "site_id"

      expect(h).to eq({
        things: {
          2 => [ { a: 12, b: 53 },
                 { a: 13, b: 54 },
                 { a: 14, b: 55 },
                 { a: 14, b: 56 } ],
          toto: :titi
        },
        others: [ { name: "Walter" } ]
      })
    end
  end

  describe 'recursively_stringify_keys!' do
    it "changes all keys to strings" do
      h = {
        foo: "bar",
        12 => 13,
        Date.parse("2013-04-05") => "yes",
        nil => "gotcha",
        [:foo] => "arrrrr"
      }

      expected = {
        "foo" => "bar",
        "12" => 13,
        "2013-04-05" => "yes",
        "" => "gotcha",
        "[:foo]" => "arrrrr"
      }

      h.recursively_stringify_keys!

      expect(h).to eq expected
    end
  end
end
