// app/javascript/controllers/echart_controller.js
import { Controller } from "@hotwired/stimulus";
import * as echarts from "echarts";

export default class extends Controller {
  initialize() {
    this.options = JSON.parse(this.element.dataset.echartOptions);
  }

  connect() {
    console.log("🟢 Controlador conectado");
    this.initChart();
  }

  initChart() {
    if (!this.element.offsetWidth) {
      setTimeout(() => this.initChart(), 100);
      return;
    }

    this.chart = echarts.init(this.element);
    this.chart.setOption(this.options);
    window.addEventListener('resize', () => this.chart.resize());
  }

  disconnect() {
    this.chart?.dispose();
  }
}
