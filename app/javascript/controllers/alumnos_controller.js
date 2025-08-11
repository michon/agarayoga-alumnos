import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  initialize() {
    console.log('Initialize:', this.element)
    // Referencia directa garantizada
    this.element._alumnosController = this
  }

  connect() {
    console.log('Connect:', this.element)
    console.log('Controlador accesible desde:', {
      elementRef: this.element._alumnosController === this,
      weakMap: window.StimulusApp?.controllers?.get(this.element) === this,
      stimulus: this.application.getControllerForElementAndIdentifier(this.element, 'alumnos') === this
    })
  }

  cambiarEstado(event) {
    event.preventDefault()
    console.log('Estado actual del controlador:', {
      element: this.element,
      instance: this,
      methods: Object.getOwnPropertyNames(Object.getPrototypeOf(this))
    })
    alert('Controlador funcionando correctamente!')
  }
}
