import { Controller } from "@hotwired/stimulus"
import * as echarts from "echarts"

export default class extends Controller {
  static values = {
    data: Array,
    title: String
  }

  connect() {
    console.log("EChart asistencias controller connected", {
      data: this.dataValue,
      title: this.titleValue
    })

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
      console.error("Error initializing chart:", error)
      this.element.innerHTML = '<p class="text-center text-danger">Error al cargar el gráfico</p>'
    }
  }

buildOptions() {
  const chartData = this.dataValue.map(item => ({
    name: item.name,
    value: item.total_clases, // Usar total de clases como valor
    porcentaje: item.porcentaje, // Mantener porcentaje para el tooltip
    itemStyle: item.itemStyle
  }))

  return {
    title: {
      text: this.titleValue || 'Distribución de clases por instructor',
      left: 'center',
      textStyle: {
        fontSize: 16,
        fontWeight: 'bold'
      }
    },
    tooltip: {
      trigger: 'item',
      formatter: (params) => {
        const originalData = this.dataValue.find(item => item.name === params.name)
        return `<b>${params.name}</b><br/>` +
               `Total clases: ${params.value}<br/>` +
               `Asistencias: ${originalData?.asistencias || 0}<br/>` +
               `Faltas: ${originalData?.faltas || 0}<br/>` +
               `Avisos: ${originalData?.avisos || 0}<br/>` +
               `Porcentaje asistencia: ${originalData?.porcentaje || 0}%`
      }
    },
    legend: {
      orient: 'horizontal',
      bottom: 10,
      data: chartData.map(item => item.name)
    },
    series: [{
      name: 'Clases por instructor',
      type: 'pie',
      radius: '70%',
      data: chartData,
      emphasis: {
        itemStyle: {
          shadowBlur: 10,
          shadowOffsetX: 0,
          shadowColor: 'rgba(0, 0, 0, 0.5)'
        }
      },
      label: {
        formatter: '{b}: {c} clases ({d}%)', // {c} = cantidad, {d} = porcentaje del total
        fontSize: 12
      }
    }]
  }
}
  disconnect() {
    this.chart?.dispose()
    this.resizeObserver?.disconnect()
  }
}
