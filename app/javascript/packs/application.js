// app/javascript/packs/application.js

// 1. ORDEN CORRECTO DE IMPORTS (primero CSS, luego JS)
import 'bootstrap-icons/font/bootstrap-icons.css'  // Bootstrap Icons CSS primero
import '@fortawesome/fontawesome-free/css/all.css' // Font Awesome CSS
import 'stylesheets/application.scss'             // Tus estilos
import "channels"
import "../stylesheets/simple_calendar";
import '@hotwired/turbo-rails'
import "packs/clases_interaccion"

// 2. IMPORTS DE JAVASCRIPT
import 'jquery'
import '@rails/ujs'
import '@popperjs/core'                // Necesario para dropdowns/tooltips
import * as bootstrap from 'bootstrap' // Importación explícita
import * as echarts from 'echarts'
import 'echarts/theme/dark'
import '@fortawesome/fontawesome-free/js/all' // JS de Font Awesome

// 3. STIMULUS CONFIGURATION - AÑADE ESTO
import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

const stimulusApp = Application.start()
const context = require.context("../controllers", true, /\.js$/)
stimulusApp.load(definitionsFromContext(context))

// 4. CONFIGURACIÓN GLOBAL
window.echarts = echarts
window.bootstrap = bootstrap  // Exporta bootstrap al ámbito global
window.Stimulus = stimulusApp // Opcional: expone Stimulus para debugging

// 5. INICIALIZACIÓN CON TURBO (actualizado para Turbo moderno)
document.addEventListener('turbo:load', () => {
  // Dropdowns (usa data-bs-toggle para Bootstrap 5)
  document.querySelectorAll('[data-bs-toggle="dropdown"]').forEach(el => {
    new bootstrap.Dropdown(el)
  })

  // Tooltips - IMPORTANTE: cambia a data-bs-toggle
  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(el => {
    new bootstrap.Tooltip(el)
  })
})

// Backward compatibility con Turbolinks (opcional)
document.addEventListener('turbolinks:load', () => {
  document.dispatchEvent(new Event('turbo:load'))
})
