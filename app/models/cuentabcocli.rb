class Cuentabcocli < ActiveRecord::Base
  establish_connection :external_reporting_table
end 
