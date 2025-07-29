import { Controller } from "@hotwired/stimulus";
import * as echarts from "echarts";

export default class extends Controller {
  initialize() {
    try {
      this.options = JSON.parse(this.element.dataset.echartOptions);
      // Asegurar que las opciones tengan estructura mínima requerida
      this.options = this.validateOptions(this.options);
    } catch (error) {
      console.error("Error parsing chart options:", error);
      this.options = this.getDefaultOptions();
    }
  }

  validateOptions(options) {
    // Estructura mínima requerida
    if (!options.xAxis) {
      options.xAxis = { type: 'category' };
    }
    if (!options.yAxis) {
      options.yAxis = { type: 'value' };
    }
    if (!options.series) {
      options.series = [];
    }
    return options;
  }

  getDefaultOptions() {
    return {
      title: { text: 'Gráfico' },
      xAxis: { type: 'category', data: ['A', 'B', 'C'] },
      yAxis: { type: 'value' },
      series: [{ type: 'bar', data: [1, 2, 3] }]
    };
  }

  connect() {
    this.initChart();
  }

  initChart() {
    if (!this.element.offsetWidth) {
      setTimeout(() => this.initChart(), 100);
      return;
    }

    try {
      this.chart = echarts.init(this.element);
      this.chart.setOption(this.options);
      window.addEventListener('resize', this.resizeChart.bind(this));
    } catch (error) {
      console.error("Chart initialization error:", error);
      // Intento con opciones por defecto si falla
      this.chart?.setOption(this.getDefaultOptions());
    }
  }

  resizeChart() {
    this.chart?.resize();
  }

  disconnect() {
    window.removeEventListener('resize', this.resizeChart);
    this.chart?.dispose();
  }
}
