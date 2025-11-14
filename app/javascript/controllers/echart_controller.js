import { Controller } from "@hotwired/stimulus"
import * as echarts from "echarts"

export default class extends Controller {
  static values = {
    years: Array,
    months: Array,
    data: Object,
    datosAlumnos: Object,
    tipo: { type: String, default: "combinado" }
  }

  connect() {
    console.log("🎯 EChart CONNECTED", {
      element: this.element,
      tipo: this.tipoValue,
      years: this.yearsValue,
      months: this.monthsValue,
      hasData: !!this.dataValue,
      hasDatosAlumnos: !!this.datosAlumnosValue
    })

    this.initChart()
  }

  initChart() {
    console.log("🔄 INIT CHART for element:", this.element)

    if (!this.element.offsetWidth) {
      console.log("⚠️ Element without width, retrying...")
      setTimeout(() => this.initChart(), 100)
      return
    }

    try {
      console.log("📈 Creating ECharts instance...")
      this.chart = echarts.init(this.element)
      const options = this.buildOptions()
      console.log("⚙️ Chart options:", options)

      this.chart.setOption(options)
      console.log("✅ Chart initialized successfully")

      // Usar ResizeObserver para manejar cambios de tamaño
      this.resizeObserver = new ResizeObserver(() => this.chart?.resize())
      this.resizeObserver.observe(this.element)
    } catch (error) {
      console.error("❌ Error initializing chart:", error)
    }
  }

  buildOptions() {
    const nombres_meses = this.monthsValue.map(m => {
      const indice_mes = parseInt(m, 10)
      return this.obtener_nombre_mes(indice_mes) || m
    })

    // DETERMINAR QUÉ MOSTRAR SEGÚN EL TIPO
    switch(this.tipoValue) {
      case "ingresos":
        return this.opcionesIngresos(nombres_meses)
      case "alumnos":
        return this.opcionesAlumnos(nombres_meses)
      default:
        return this.opcionesCombinado(nombres_meses)
    }
  }

  opcionesIngresos(nombres_meses) {
    const series = this.yearsValue.map(year => ({
      name: `${year} - Ingresos`,
      type: 'bar',
      data: this.monthsValue.map(mes => this.dataValue[year]?.[mes] || 0)
    }))

    return {
      tooltip: {
        trigger: 'axis',
        axisPointer: { type: 'shadow' },
        formatter: params => {
          let resultado = params[0].axisValue
          params.forEach(param => {
            resultado += `<br/>${param.seriesName}: ${param.value.toLocaleString('es-AR', {style: 'currency', currency: 'ARS'})}`
          })
          return resultado
        }
      },
      legend: {
        data: series.map(s => s.name),
        bottom: 0
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '10%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        data: nombres_meses
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

  opcionesAlumnos(nombres_meses) {
    const series = this.yearsValue.map(year => ({
      name: `${year} - Alumnos`,
      type: 'line',
      data: this.monthsValue.map(mes => this.datosAlumnosValue[year]?.[mes] || 0)
    }))

    return {
      tooltip: {
        trigger: 'axis',
        axisPointer: { type: 'shadow' },
        formatter: params => {
          let resultado = params[0].axisValue
          params.forEach(param => {
            resultado += `<br/>${param.seriesName}: ${param.value} alumnos`
          })
          return resultado
        }
      },
      legend: {
        data: series.map(s => s.name),
        bottom: 0
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '10%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        data: nombres_meses
      },
      yAxis: {
        type: 'value',
        name: 'Alumnos'
      },
      series: series
    }
  }

  opcionesCombinado(nombres_meses) {
    const series_ingresos = this.yearsValue.map(year => ({
      name: `${year} - Ingresos`,
      type: 'bar',
      data: this.monthsValue.map(mes => this.dataValue[year]?.[mes] || 0),
      yAxisIndex: 0
    }))

    const series_alumnos = this.yearsValue.map(year => ({
      name: `${year} - Alumnos`,
      type: 'line',
      data: this.monthsValue.map(mes => this.datosAlumnosValue[year]?.[mes] || 0),
      yAxisIndex: 1
    }))

    const todas_las_series = [...series_ingresos, ...series_alumnos]

    return {
      tooltip: {
        trigger: 'axis',
        axisPointer: { type: 'cross' },
        formatter: params => {
          let resultado = params[0].axisValue
          params.forEach(param => {
            if (param.seriesName.includes('Ingresos')) {
              resultado += `<br/>${param.seriesName}: ${param.value.toLocaleString('es-AR', {style: 'currency', currency: 'ARS'})}`
            } else {
              resultado += `<br/>${param.seriesName}: ${param.value} alumnos`
            }
          })
          return resultado
        }
      },
      legend: {
        data: todas_las_series.map(s => s.name),
        bottom: 0
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '10%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        data: nombres_meses
      },
      yAxis: [
        {
          type: 'value',
          name: 'Ingresos',
          position: 'left',
          axisLabel: {
            formatter: value => value.toLocaleString('es-AR', {style: 'currency', currency: 'ARS'})
          }
        },
        {
          type: 'value',
          name: 'Alumnos',
          position: 'right'
        }
      ],
      series: todas_las_series
    }
  }

  obtener_nombre_mes(indice_mes) {
    const nombres_meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ]
    return nombres_meses[indice_mes - 1]
  }

  disconnect() {
    this.chart?.dispose()
    this.resizeObserver?.disconnect()
  }
}
