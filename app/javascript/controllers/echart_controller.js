import { Controller } from "@hotwired/stimulus"
import * as echarts from "echarts"

export default class extends Controller {
  static values = {
    years: Array,
    months: Array,
    data: Object
  }

  connect() {
    console.log("EChart controller connected", {
      years: this.yearsValue,
      months: this.monthsValue,
      data: this.dataValue
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
    }
  }

  buildOptions() {
    const monthNames = this.monthsValue.map(m => {
      const monthIndex = parseInt(m, 10)
      return this.getMonthName(monthIndex) || m
    })

    const series = this.yearsValue.map(year => ({
      name: year,
      type: 'bar',
      data: this.monthsValue.map(month => this.dataValue[year]?.[month] || 0),
      emphasis: { focus: 'series' }
    }))

    return {
      tooltip: {
        trigger: 'axis',
        axisPointer: { type: 'shadow' },
        formatter: params => {
          let result = params[0].axisValue
          params.forEach(param => {
            result += `<br/>${param.seriesName}: ${param.value.toLocaleString('es-AR', {style: 'currency', currency: 'ARS'})}`
          })
          return result
        }
      },
      legend: { data: this.yearsValue },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: {
        type: 'category',
        data: monthNames
      },
      yAxis: {
        type: 'value',
        axisLabel: {
          formatter: value => value.toLocaleString('es-AR', {style: 'currency', currency: 'ARS'})
        }
      },
      series: series
    }
  }

  getMonthName(monthIndex) {
    const monthNames = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ]
    return monthNames[monthIndex - 1] // -1 porque los meses van de 1 a 12
  }

  disconnect() {
    this.chart?.dispose()
    this.resizeObserver?.disconnect()
  }
}
