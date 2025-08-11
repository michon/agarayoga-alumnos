# app/controllers/clase_alumno_controller.rb
class ClaseAlumnoController < ApplicationController
  before_action :authenticate_usuario!
  before_action :set_clase_alumno, only: [:show, :edit, :update, :destroy]

  def edit
    unless AlumnosPolicy.new(current_usuario).puede_gestionar_clases?
      render file: "public/401.html", status: :unauthorized
      return
    end

    @estados = ClaseAlumnoEstado.all
    # Renderiza un formulario simple para cambiar el estado
    render partial: 'form_edit_estado', layout: false
  end

  def update
    unless AlumnosPolicy.new(current_usuario).puede_gestionar_clases?
      render file: "public/401.html", status: :unauthorized
      return
    end

    if @clase_alumno.update(clase_alumno_params)
      redirect_back fallback_location: root_path, notice: 'Estado actualizado correctamente'
    else
      redirect_back fallback_location: root_path, alert: 'Error al actualizar estado'
    end
  end

  def destroy
    unless AlumnosPolicy.new(current_usuario).puede_gestionar_clases?
      render file: "public/401.html", status: :unauthorized
      return
    end

    @clase_alumno.destroy
    redirect_back fallback_location: root_path, notice: 'Alumno eliminado de la clase'
  end

  def show
    redirect_to alumnos_index_path()
  end

  private

  def set_clase_alumno
    @clase_alumno = ClaseAlumno.find(params[:id])
  end

  def clase_alumno_params
    params.require(:clase_alumno).permit(:claseAlumnoEstado_id)
  end
end
