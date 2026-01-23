# app/services/income_combiner.rb
class IncomeCombiner
  def self.combined_data
    # Datos históricos (estáticos hasta abril 2025)
    historical = HISTORICAL_INCOME_DATA.select { |d| d[:date] < Date.new(2025, 5, 1) }

    # Obtener meses completos desde mayo 2025 hasta el mes actual
    start_date = Date.new(2025, 5, 1)
    end_date = Date.today
    months = (start_date..end_date).select { |d| d.day == 1 } # Todos los primeros de mes

    # Calcular totales por mes natural
    current = months.map do |month_start|
      month_end = month_start.end_of_month
      usuarios_excluidos = Usuario.unscoped.where(grupoAlumno_id: [7, 8]).pluck(:id)
      total = Recibo.where(vencimiento: month_start..month_end)
                   .where.not(usuario_id: usuarios_excluidos)
                   .sum(:importe)
                   .to_f

      { date: month_start, amount: total }
    end

    # Combinar y ordenar
    (historical + current).sort_by { |d| d[:date] }
  end
end
