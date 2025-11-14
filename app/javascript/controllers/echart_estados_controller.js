// app/javascript/controllers/echart_estados_controller.js
import { Controller } from "@hotwired/stimulus"
import * as echarts from "echarts"

export default class extends Controller {
  static values = {
    data: Object // { "Asistió": X, "No viene (avisó)": Y, "Faltó": Z }
  }

  connect() {
    console.log("EChart estados controller connected", this.dataValue)
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
      console.error("Error initializing estados chart:", error)
      this.element.innerHTML = '<p class="text-center text-danger">Error al cargar el gráfico de estados</p>'
    }
  }

  buildOptions() {
    const data = this.dataValue
    const chartData = [
      { 
        name: 'Asistió', 
        value: data['Asistió'] || 0,
        itemStyle: { color: '#28a745' } // Verde success
      },
      { 
        name: 'No viene (avisó)', 
        value: data['No viene (avisó)'] || 0,
        itemStyle: { color: '#ffc107' } // Amarillo warning
      },
      { 
        name: 'Faltó', 
        value: data['Faltó'] || 0,
        itemStyle: { color: '#dc3545' } // Rojo danger
      },
      { 
        name: 'Viene', 
        value: data['Viene'] || 0,
        itemStyle: { color: '#007bff' } // Azul primary
      }
    ].filter(item => item.value > 0) // Solo mostrar estados con datos

    const total = chartData.reduce((sum, item) => sum + item.value, 0)

    return {
      tooltip: {
        trigger: 'item',
        formatter: '{b}: {c} ({d}%)'
      },
      legend: {
        orient: 'horizontal',
        bottom: 0,
        data: chartData.map(item => item.name)
      },
      series: [{
        name: 'Distribución de Estados',
        type: 'pie',
        radius: ['50%', '70%'], // Donut chart
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: true,
          formatter: '{b}: {c}',
          fontSize: 12
        },
        emphasis: {
          label: {
            show: true,
            fontSize: '14',
            fontWeight: 'bold'
          }
        },
        labelLine: {
          show: true
        },
        data: chartData
      }]
    }
  }

  disconnect() {
    this.chart?.dispose()
    this.resizeObserver?.disconnect()
  }
}
