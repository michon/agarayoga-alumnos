// app/javascript/packs/chart_test.js
document.addEventListener('DOMContentLoaded', function() {
  // Configuración global de Chart.js
  Chart.defaults.font.family = "'Segoe UI', Tahoma, sans-serif";
  Chart.defaults.color = '#333';
  
  // Datos desde el controlador (usando data attributes)
  const chartData = {
    labels: JSON.parse(document.body.dataset.labels),
    values: JSON.parse(document.body.dataset.values),
    colors: JSON.parse(document.body.dataset.colors)
  };

  // 1. Gráfico de Barras
  const barCtx = document.getElementById('barChart');
  new Chart(barCtx, {
    type: 'bar',
    data: {
      labels: chartData.labels,
      datasets: [{
        label: 'Ventas 2023',
        data: chartData.values,
        backgroundColor: chartData.colors,
        borderWidth: 1
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false }
      }
    }
  });

  // 2. Gráfico Circular
  const pieCtx = document.getElementById('pieChart');
  new Chart(pieCtx, {
    type: 'pie',
    data: {
      labels: chartData.labels,
      datasets: [{
        data: chartData.values,
        backgroundColor: chartData.colors,
        hoverOffset: 10
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { position: 'right' }
      }
    }
  });
});
