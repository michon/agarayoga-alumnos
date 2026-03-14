// app/javascript/controllers/verificacion_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "contenido"]
  
  abrir(event) {
    event.preventDefault()
    const url = this.element.getAttribute('data-url')
    
    // Mostrar modal
    this.modalTarget.classList.add('show', 'd-block')
    this.modalTarget.style.background = 'rgba(0,0,0,0.5)'
    
    // Cargar contenido
    this.contenidoTarget.innerHTML = `
      <div class="modal-header">
        <h5 class="modal-title">Cargando verificación...</h5>
        <button type="button" class="btn-close" data-action="click->verificacion#cerrar"></button>
      </div>
      <div class="modal-body text-center p-4">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
      </div>
    `
    
    fetch(url, {
      headers: { 
        'Accept': 'text/html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => {
      if (!response.ok) throw new Error('Error ' + response.status)
      return response.text()
    })
    .then(html => {
      this.contenidoTarget.innerHTML = html
    })
    .catch(error => {
      this.contenidoTarget.innerHTML = `
        <div class="modal-header bg-danger text-white">
          <h5 class="modal-title">Error</h5>
          <button type="button" class="btn-close btn-close-white" data-action="click->verificacion#cerrar"></button>
        </div>
        <div class="modal-body">
          <div class="alert alert-danger">No se pudo cargar la verificación: ${error.message}</div>
        </div>
      `
    })
  }
  
  cerrar() {
    this.modalTarget.classList.remove('show', 'd-block')
    this.modalTarget.style.background = ''
    this.contenidoTarget.innerHTML = ''
  }
  
  // Cerrar al hacer click fuera del modal
  cerrarFuera(event) {
    if (event.target === this.modalTarget) {
      this.cerrar()
    }
  }
}
