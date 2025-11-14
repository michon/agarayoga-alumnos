// app/javascript/controllers/echart_evolucion_tendencia_controller.js
import { Controller } from "@hotwired/stimulus"
import * as echarts from "echarts"

export default class extends Controller {
  static values = {
    data: Array // [{semana_key, semana_num, año, fecha_inicio, asistencias, media_movil, label}]
  }

  connect() {
    console.log("EChart evolucion-tendencia controller connected", this.dataValue)
    this.initChart()
  }

  initChart() {
    if (!this.element.offsetWidth) {
      setTimeout(() => this.initChart(), 100)
      return
    }

    try {
      this.chart = echarts.init(this.element)
      this.chart.setOption(this.buildOptions())

      // Usar ResizeObserver para manejar cambios de tamaño
      this.resizeObserver = new ResizeObserver(() => this.chart?.resize())
      this.resizeObserver.observe(this.element)
    } catch (error) {
      console.error("Error initializing evolucion-tendencia chart:", error)
      this.element.innerHTML = '<p class="text-center text-danger">Error al cargar el gráfico de evolución</p>'
    }
  }

  buildOptions() {
    const semanas = this.dataValue
    
    return {
      title: {
        text: 'Evolución y Tendencia de Asistencia Semanal',
        left: 'center',
        textStyle: { fontSize: 16, fontWeight: 'bold' }
      },
      tooltip: {
        trigger: 'axis',
        axisPointer: { type: 'shadow' }
      },
      legend: {
        data: ['Asistencias Semanales', 'Tendencia (media móvil 3 semanas)'],
        bottom: 10
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '15%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        data: semanas.map(s => s.label),
        axisLabel: { rotate: 45 }
      },
      yAxis: {
        type: 'value',
        name: 'Clases asistidas'
      },
      series: [
        {
          name: 'Asistencias Semanales',
          type: 'bar',
          data: semanas.map(s => s.asistencias),
          itemStyle: {
            color: '#36A2EB'
          }
        },
        {
          name: 'Tendencia (media móvil 3 semanas)',
          type: 'line',
          data: semanas.map(s => s.media_movil),
          smooth: true,
          symbol: 'circle',
          symbolSize: 8,
          lineStyle: {
            color: '#FF6384',
            width: 3
          },
          itemStyle: {
            color: '#FF6384'
          }
        }
      ]
    }
  }

  disconnect() {
    this.chart?.dispose()
    this.resizeObserver?.disconnect()
  }
}
