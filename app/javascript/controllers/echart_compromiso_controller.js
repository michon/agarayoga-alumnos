// app/javascript/controllers/echart_compromiso_controller.js
import { Controller } from "@hotwired/stimulus"
import * as echarts from "echarts"

export default class extends Controller {
  static values = {
    data: Array
  }

  connect() {
    console.log("EChart compromiso controller connected", this.dataValue)
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

      this.resizeObserver = new ResizeObserver(() => this.chart?.resize())
      this.resizeObserver.observe(this.element)
    } catch (error) {
      console.error("Error initializing compromiso chart:", error)
      this.element.innerHTML = '<p class="text-center text-danger">Error al cargar el gráfico de compromiso</p>'
    }
  }

buildOptions() {
  const semanas = this.dataValue
  const semanasLabels = semanas.map((semana, index) => {
    try {
      // Intentar convertir a Date si es string
      const fecha = new Date(semana.fecha_inicio)
      // Verificar que la fecha sea válida
      if (isNaN(fecha.getTime())) {
        throw new Error('Fecha inválida')
      }
      return `Sem ${fecha.toLocaleDateString('es-ES', { day: '2-digit', month: 'short' })}`
    } catch (error) {
      // Fallback: usar número de semana si hay error con la fecha
      console.warn(`Error con fecha ${semana.fecha_inicio}:`, error)
      return `Sem ${index + 1}`
    }
  })

  return {
    title: {
      text: 'Compromiso vs Realidad Semanal',
      left: 'center',
      textStyle: {
        fontSize: 16,
        fontWeight: 'bold'
      }
    },
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      },
      formatter: function(params) {
        const semanaData = semanas[params[0].dataIndex]
        return `
          <b>${params[0].name}</b><br/>
          Compromiso: ${semanaData.compromiso} clases<br/>
          Realidad: ${semanaData.realidad} asistencias<br/>
          Ratio: ${semanaData.compromiso > 0 ? ((semanaData.realidad / semanaData.compromiso) * 100).toFixed(1) : 0}%
        `
      }
    },
    legend: {
      data: ['Compromiso (Clases agendadas)', 'Realidad (Asistencias)'],
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
      data: semanasLabels,
      axisLabel: {
        rotate: 45
      }
    },
    yAxis: {
      type: 'value',
      name: 'Nº de Clases'
    },
    series: [
      {
        name: 'Compromiso (Clases agendadas)',
        type: 'bar',
        data: semanas.map(s => s.compromiso),
        itemStyle: {
          color: '#36A2EB'
        }
      },
      {
        name: 'Realidad (Asistencias)',
        type: 'bar',
        data: semanas.map(s => s.realidad),
        itemStyle: {
          color: '#4BC0C0'
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
