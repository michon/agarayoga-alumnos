// app/javascript/packs/clases_interaccion.js
function setupClaseInteractions() {
  // Filtrado por estado
  document.querySelectorAll('.filter-btn').forEach(btn => {
    btn.addEventListener('click', function() {
      const target = this.dataset.target;
      const card = this.closest('.card');

      // Actualizar botones activos
      card.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
      this.classList.add('active');

      // Mostrar/ocultar alumnos
      card.querySelectorAll('.list-group-item').forEach(item => {
        item.style.display = (target === 'all' || item.classList.contains(target)) ? '' : 'none';
      });
    });
  });

  // Cambio masivo de estado
  document.querySelectorAll('.estado-btn').forEach(btn => {
    btn.addEventListener('click', function() {
      const form = this.closest('form');
      const estadoId = this.dataset.estado;
      const claseId = form.querySelector('input[name="clase_id"]').value;
      const checkedBoxes = form.querySelectorAll('input[name="alumno_ids[]"]:checked');

      if (checkedBoxes.length === 0) {
        alert('Selecciona al menos un alumno');
        return;
      }

      const alumnoIds = Array.from(checkedBoxes).map(cb => cb.value);

      fetch(form.action, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          alumno_id: alumnoIds,
          nuevo_estado_id: estadoId
        })
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          location.reload();
        } else {
          alert('Error: ' + data.errors.join(', '));
        }
      })
      .catch(error => {
        console.error('Error:', error);
        alert('Error al actualizar estados');
      });
    });
  });
}

// Ejecutar tanto en DOMContentLoaded como en turbo:load
document.addEventListener('DOMContentLoaded', setupClaseInteractions);
document.addEventListener('turbo:load', setupClaseInteractions);
document.addEventListener('turbo:render', setupClaseInteractions);
