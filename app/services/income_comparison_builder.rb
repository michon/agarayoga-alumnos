# app/services/income_comparison_builder.rb
class IncomeComparisonBuilder
  def self.yearly_comparison_data
    combined = IncomeCombiner.combined_data
    
    # Organizar por año y mes
    data = combined.each_with_object({}) do |item, hash|
      year = item[:date].year.to_s
      month = item[:date].month.to_s.rjust(2, '0')
      
      hash[year] ||= {}
      hash[year][month] = item[:amount]
    end
    
    # Rellenar meses faltantes con 0 y ordenar
    data.each do |year, months|
      (1..12).each do |m|
        month = "%02d" % m
        months[month] ||= 0
      end
      data[year] = months.sort.to_h
    end
    
    data.sort.to_h
  end

end
