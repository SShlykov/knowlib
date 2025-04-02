ChartJS = {
  mounted() {
    this.initializeChart();
  },
  updated() {
    this.initializeChart();
  },
  initializeChart() {
    // Читаем JSON-конфигурацию графика из data-атрибута
    let configData = this.el.dataset.chartConfig;
    if (!configData) return;

    let config;
    try {
      config = JSON.parse(configData);
    } catch (error) {
      console.error("Неверная конфигурация графика", error);
      return;
    }

    // Создаем новый график Chart.js
    this.chart = new Chart(this.el.getContext("2d"), config);
  },
  destroyed() {
    if (this.chart) {
      this.chart.destroy();
    }
  },
};

export default ChartJS;
