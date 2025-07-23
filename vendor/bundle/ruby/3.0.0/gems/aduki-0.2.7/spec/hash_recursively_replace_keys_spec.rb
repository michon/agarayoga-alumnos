require 'spec_helper'

describe Hash do
  before { Aduki.install_monkey_patches }

  describe 'recursively_replace_keys!' do
    it "destructively replaces keys with upcase symbol equivalents" do
      h0 = { "x/y/z" => [1,2,3], "p-q-r" => 123 }
      a = [h0, h0, 10, 11, 12]
      hsh = {
        "Foo_BAR" => 1,
        HEYHO: 2,
        "Tweedlé Dum" => 3,
        "4" => 4,
        "  20 something?" => true,
        "** more fun 2 !! **" => true,
        "ça và" => true,
        "((a b c))" => true,
        :nana => {
          "a b c" => 1,
          "surprise! :)" => a
        }
      }
      expected = {
        :FOO_BAR               => 1,
        :HEYHO                 => 2,
        :"TWEEDLé DUM"         => 3,
        :"4"                   => 4,
        :"20 SOMETHING?"       => true,
        :"** MORE FUN 2 !! **" => true,
        :"çA Và"               => true,
        :"((A B C))"           => true,
        :NANA                  => {
          :"A B C"             => 1,
          :"SURPRISE! :)"      =>
          [
           {
             :"X/Y/Z"          => [1,2,3],
             :"P-Q-R"          => 123
           },
           {
             :"X/Y/Z"          => [1,2,3],
             :"P-Q-R"          => 123
           },
           10,
           11,
           12
          ]
        }
      }

      hsh.recursively_replace_keys! { |k| k.to_s.strip.upcase.to_sym }
      expect(hsh).to eq expected
    end
  end
end
