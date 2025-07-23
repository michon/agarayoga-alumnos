require "aduki"
require "aduki/attr_finder"
require "spec_helper"

describe Aduki::AttrFinder do
  it "generates code for a single attribute" do
    txt = Aduki::AttrFinder.attr_finder_text :find, :id, "widget_holder", "WidgetHolder"
    expected = <<EXPECTED
remove_method :widget_holder_id  if method_defined?(:widget_holder_id)
remove_method :widget_holder_id= if method_defined?(:widget_holder_id=)
remove_method :widget_holder       if method_defined?(:widget_holder)
remove_method :widget_holder=      if method_defined?(:widget_holder=)

attr_reader :widget_holder_id

def widget_holder_id= x
  @widget_holder_id= x
  @widget_holder = nil
end

def widget_holder
  @widget_holder ||= WidgetHolder.find(@widget_holder_id) unless @widget_holder_id.nil? || @widget_holder_id == ''
  @widget_holder
end

def widget_holder= x
  @widget_holder = x
  @widget_holder_id = x ? x.id : nil
end
EXPECTED

    expect(txt).to eq expected
  end

  it "generates code for multiple attributes" do
    txt = Aduki::AttrFinder.attr_finders_text :open, :time, :happy_hour, widget: "WidgetHolder::Base"
    expected = <<EXPECTED
remove_method :happy_hour_time  if method_defined?(:happy_hour_time)
remove_method :happy_hour_time= if method_defined?(:happy_hour_time=)
remove_method :happy_hour       if method_defined?(:happy_hour)
remove_method :happy_hour=      if method_defined?(:happy_hour=)

attr_reader :happy_hour_time

def happy_hour_time= x
  @happy_hour_time= x
  @happy_hour = nil
end

def happy_hour
  @happy_hour ||= HappyHour.open(@happy_hour_time) unless @happy_hour_time.nil? || @happy_hour_time == ''
  @happy_hour
end

def happy_hour= x
  @happy_hour = x
  @happy_hour_time = x ? x.time : nil
end

remove_method :widget_time  if method_defined?(:widget_time)
remove_method :widget_time= if method_defined?(:widget_time=)
remove_method :widget       if method_defined?(:widget)
remove_method :widget=      if method_defined?(:widget=)

attr_reader :widget_time

def widget_time= x
  @widget_time= x
  @widget = nil
end

def widget
  @widget ||= WidgetHolder::Base.open(@widget_time) unless @widget_time.nil? || @widget_time == ''
  @widget
end

def widget= x
  @widget = x
  @widget_time = x ? x.time : nil
end
EXPECTED

    expect(txt).to eq expected
  end

  it "generates a one-to-many finder" do
    txt = Aduki::AttrFinder.one2many_attr_finder_text :purchase, :price, :birthday_gifts
    expected = <<EXPECTED
remove_method :birthday_gift_prices  if method_defined?(:birthday_gift_prices)
remove_method :birthday_gift_prices= if method_defined?(:birthday_gift_prices=)
remove_method :birthday_gifts       if method_defined?(:birthday_gifts)
remove_method :birthday_gifts=      if method_defined?(:birthday_gifts=)

attr_reader :birthday_gift_prices

def birthday_gift_prices= x
  @birthday_gift_prices = x
  @birthday_gifts      = nil
end

def birthday_gifts
  @birthday_gifts ||= BirthdayGift.purchase @birthday_gift_prices unless @birthday_gift_prices.nil?
  @birthday_gifts
end

def birthday_gifts= x
  @birthday_gift_prices = x ? x.map(&:price) : nil
  @birthday_gifts      = x
end
EXPECTED
    expect(txt).to eq expected
  end

  it "generates a one-to-many finder with alternative class name" do
    txt = Aduki::AttrFinder.one2many_attr_finder_text :purchase, :price, :birthday_gifts, class_name: "ToyShop"
    expected = <<EXPECTED
remove_method :birthday_gift_prices  if method_defined?(:birthday_gift_prices)
remove_method :birthday_gift_prices= if method_defined?(:birthday_gift_prices=)
remove_method :birthday_gifts       if method_defined?(:birthday_gifts)
remove_method :birthday_gifts=      if method_defined?(:birthday_gifts=)

attr_reader :birthday_gift_prices

def birthday_gift_prices= x
  @birthday_gift_prices = x
  @birthday_gifts      = nil
end

def birthday_gifts
  @birthday_gifts ||= ToyShop.purchase @birthday_gift_prices unless @birthday_gift_prices.nil?
  @birthday_gifts
end

def birthday_gifts= x
  @birthday_gift_prices = x ? x.map(&:price) : nil
  @birthday_gifts      = x
end
EXPECTED
    expect(txt).to eq expected
  end
end
