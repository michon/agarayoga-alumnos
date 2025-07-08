class HorarioAlumnoController < ApplicationController

  def destroy
    @horario_alumno = HorarioAlumno.find(params[:id])
    alumno_id = @horario_alumno.usuario_id
    @horario_alumno.destroy

    # Permite explícitamente los parámetros de búsqueda y filtro
    permitted_params = params.permit(q: {}).to_h
    permitted_params[:q] ||= {} # Asegura que :q existe como hash

    redirect_to alumnos_index_path(permitted_params.merge(anchor: "alumno-#{alumno_id}")),
                notice: 'Clase eliminada del horario correctamente'
    rescue ActiveRecord::RecordNotFound
      redirect_to alumnos_index_path, alert: 'No se encontró la clase a eliminar'
  end
end

