# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
 :address => "shx12.guebs.net",
 :port => 25,
 :domain => "agarayoga.eu" ,
 :authentication => :login,
 :user_name => "web@agarayoga.eu" ,
 :password => "kkdvkgorda1968",
 :enable_starttls_auto => false
}
