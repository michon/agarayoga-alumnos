// app/javascript/packs/application.js

// 1. ORDEN CORRECTO DE IMPORTS (primero CSS, luego JS)
import 'bootstrap-icons/font/bootstrap-icons.css'  // Bootstrap Icons CSS primero
import '@fortawesome/fontawesome-free/css/all.css' // Font Awesome CSS
import 'stylesheets/application.scss'             // Tus estilos
import "controllers"

// 2. IMPORTS DE JAVASCRIPT
import 'jquery'
import '@rails/ujs'
import '@popperjs/core'                // Necesario para dropdowns/tooltips
import * as bootstrap from 'bootstrap' // Importación explícita
import * as echarts from 'echarts'
import 'echarts/theme/dark'
import '@fortawesome/fontawesome-free/js/all' // JS de Font Awesome

// 3. CONFIGURACIÓN GLOBAL
window.echarts = echarts
window.bootstrap = bootstrap  // Exporta bootstrap al ámbito global

// 4. INICIALIZACIÓN CON TURBO
document.addEventListener('turbolinks:load', () => {
  // Dropdowns (usa data-bs-toggle para Bootstrap 5)
  document.querySelectorAll('[data-bs-toggle="dropdown"]').forEach(el => {
    new bootstrap.Dropdown(el)
  })

  // Tooltips - IMPORTANTE: cambia a data-bs-toggle
  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(el => {
    new bootstrap.Tooltip(el)
  })
})
