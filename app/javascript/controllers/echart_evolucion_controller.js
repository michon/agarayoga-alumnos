import { Controller } from "@hotwired/stimulus"
import * as echarts from "echarts"

export default class extends Controller {
  static values = {
    labels: Array,
    values: Array,
    historical: Array
  }

  connect() {
    this.initChart()
  }

  initChart() {
    if (!this.element.offsetWidth) {
      setTimeout(() => this.initChart(), 100)
      return
    }

    try {
      this.chart = echarts.init(this.element)
      this.chart.setOption(this.chartOptions())
      
      new ResizeObserver(() => this.chart?.resize()).observe(this.element)
    } catch (error) {
      console.error("Error initializing evolution chart:", error)
    }
  }

  chartOptions() {
    const historicalData = this.valuesValue.map((v, i) => 
      this.historicalValue[i] ? v : null
    )
    
    const currentData = this.valuesValue.map((v, i) => 
      this.historicalValue[i] ? null : v
    )

    return {
      title: {
        text: 'Evolución de Ingresos (Histórico + Actual)',
        left: 'center',
        textStyle: {
          fontSize: 18,
          fontWeight: 'bold'
        }
      },
      tooltip: {
        trigger: 'axis',
        formatter: params => {
          const date = params[0].axisValue.replace(/\\n/g, ' ')
          const amount = params[0].value.toLocaleString('es-ES', {
            style: 'currency',
            currency: 'EUR'
          })
          const type = params[0].seriesName
          return `${date}<br/>${amount}<br/><small>${type}</small>`
        }
      },
      legend: {
        data: ['Histórico', 'Actual'],
        right: 20
      },
      xAxis: {
        type: 'category',
        data: this.labelsValue,
        axisLabel: {
          rotate: 45,
          formatter: value => value.replace(/\\n/g, '\n')
        },
        axisPointer: {
          label: {
            formatter: params => params.value.replace(/\\n/g, ' ')
          }
        }
      },
      yAxis: {
        type: 'value',
        axisLabel: {
          formatter: '{value} €'
        },
        splitLine: {
          lineStyle: {
            type: 'dashed'
          }
        }
      },
      series: [
        {
          name: 'Histórico',
          type: 'line',
          data: historicalData,
          symbol: 'circle',
          symbolSize: 6,
          lineStyle: {
            width: 2,
            color: '#7b9ce1'
          },
          itemStyle: {
            color: '#7b9ce1'
          },
          emphasis: {
            itemStyle: {
              color: '#3a4de9'
            }
          }
        },
        {
          name: 'Actual',
          type: 'line',
          data: currentData,
          symbol: 'circle',
          symbolSize: 8,
          lineStyle: {
            width: 3,
            color: '#4CAF50'
          },
          itemStyle: {
            color: '#4CAF50'
          },
          emphasis: {
            itemStyle: {
              color: '#2E7D32'
            }
          },
          markPoint: {
            data: [
              { type: 'max', name: 'Máximo' },
              { type: 'min', name: 'Mínimo' }
            ]
          }
        }
      ],
      dataZoom: [
        {
          type: 'inside',
          startValue: this.labelsValue[this.labelsValue.length - 13] // Mostrar último año
        },
        {
          start: 70,
          end: 100
        }
      ],
      grid: {
        top: '15%',
        right: '5%',
        left: '5%',
        bottom: '20%',
        containLabel: true
      }
    }
  }

  disconnect() {
    this.chart?.dispose()
  }
}
