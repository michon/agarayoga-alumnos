import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    event.preventDefault();
    
    const link = event.currentTarget;
    const usuarioId = link.dataset.usuarioId;
    const currentNavidad = link.dataset.navidadCurrent === 'true';
    
    // Mostrar indicador de carga
    const icon = link.querySelector('span');
    const originalHTML = icon.innerHTML;
    icon.innerHTML = '⏳';
    
    fetch(link.href, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // Actualizar el icono
        if (data.navidad) {
          icon.className = 'color-indicator bg-success';
          icon.title = 'Navidad activa - Haz clic para desactivar';
          link.dataset.navidadCurrent = 'true';
          link.title = 'Navidad activa - Haz clic para desactivar';
        } else {
          icon.className = 'color-indicator bg-secondary';
          icon.title = 'Navidad inactiva - Haz clic para activar';
          link.dataset.navidadCurrent = 'false';
          link.title = 'Navidad inactiva - Haz clic para activar';
        }
        icon.innerHTML = '🎄';
      } else {
        alert('Error al actualizar');
        icon.innerHTML = originalHTML;
      }
    })
    .catch(error => {
      console.error('Error:', error);
      alert('Error nono al actualizar');
      icon.innerHTML = originalHTML;
    });
  }
}
