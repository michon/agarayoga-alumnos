# app/helpers/stats_helper.rb
module StatsHelper
  def asistencia_mensual_chart_data
    return {} unless @attendance_data
    
    {
      labels: @attendance_data.map { |d| d[:semana] },
      datasets: [
        {
          label: 'Tasa de Asistencia (%)',
          data: @attendance_data.map { |d| d[:rate] },
          borderColor: '#6f42c1',
          backgroundColor: 'rgba(111, 66, 193, 0.1)',
          tension: 0.4
        }
      ]
    }
  end
  
  def asistencia_instructor_chart_data
    return {} unless @attendance_data
    
    {
      labels: @attendance_data.map { |d| d[:dia] },
      datasets: [
        {
          label: 'Asistencias',
          data: @attendance_data.map { |d| d[:attended] },
          backgroundColor: 'rgba(111, 66, 193, 0.7)',
          borderColor: '#6f42c1',
          borderWidth: 1
        },
        {
          label: 'Total Clases',
          data: @attendance_data.map { |d| d[:total] },
          backgroundColor: 'rgba(108, 117, 125, 0.3)',
          borderColor: '#6c757d',
          borderWidth: 1,
          type: 'line'
        }
      ]
    }
  end
end
