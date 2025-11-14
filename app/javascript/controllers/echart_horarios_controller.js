// app/javascript/controllers/echart_horarios_controller.js
import { Controller } from "@hotwired/stimulus"
import * as echarts from "echarts"

export default class extends Controller {
  static values = {
    data: Array // [["Horario nombre", cantidad], ...]
  }

  connect() {
    console.log("EChart horarios controller connected", this.dataValue)
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
      console.error("Error initializing horarios chart:", error)
      this.element.innerHTML = '<p class="text-center text-danger">Error al cargar el gráfico de horarios</p>'
    }
  }

  buildOptions() {
    // Los datos vienen como array de arrays: [["Horario", cantidad], ...]
    const horariosData = this.dataValue.slice(0, 8) // Limitar a 8 horarios máximo
    
    // Ordenar por cantidad descendente
    horariosData.sort((a, b) => b[1] - a[1])
    
    const horarios = horariosData.map(item => item[0])
    const cantidades = horariosData.map(item => item[1])

    return {
      title: {
        text: 'Horarios Más Frecuentados',
        left: 'center',
        textStyle: {
          fontSize: 14,
          fontWeight: 'bold'
        }
      },
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow'
        },
        formatter: '{b}: {c} clases'
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        top: '15%',
        containLabel: true
      },
      xAxis: {
        type: 'value',
        name: 'Nº de Clases'
      },
      yAxis: {
        type: 'category',
        data: horarios,
        axisLabel: {
          interval: 0,
          formatter: function(value) {
            // Acortar textos largos para mejor visualización
            return value.length > 30 ? value.substring(0, 30) + '...' : value
          }
        }
      },
      series: [{
        name: 'Clases asistidas',
        type: 'bar',
        data: cantidades,
        itemStyle: {
          color: function(params) {
            // Colores alternados para mejor distinción
            const colors = ['#36A2EB', '#FF6384', '#4BC0C0', '#FF9F40', '#9966FF', '#FFCD56', '#C9CBCF']
            return colors[params.dataIndex % colors.length]
          }
        },
        label: {
          show: true,
          position: 'right',
          formatter: '{c}'
        }
      }]
    }
  }

  disconnect() {
    this.chart?.dispose()
    this.resizeObserver?.disconnect()
  }
}
