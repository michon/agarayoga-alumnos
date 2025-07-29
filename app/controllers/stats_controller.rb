class StatsController < ApplicationController

  #Comparación mensual através de los años
  def monthly_comparison
    @comparison_data = IncomeComparisonBuilder.yearly_comparison_data
    @years = @comparison_data.keys.sort
    @months = (1..12).map { |m| "%02d" % m }
  end

  #Gráfico de evolución de los ingresos bruto
  def evolucion_ingresos
    combined_data = IncomeCombiner.combined_data
    @paraver = combined_data


    @chart_data = {
      labels: combined_data.map { |d| I18n.l(d[:date], format: "%b %Y") },
      values: combined_data.map { |d| d[:amount] },
      # Para diferenciar históricos vs actuales en el gráfico
      is_historical: combined_data.map { |d| d[:date] < Date.new(2025, 5, 1) }
    }
  end
end
