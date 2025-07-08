class ClaseAlumnoController < ApplicationController
  def destroy
    clAl = ClaseAlumno.find(params[:id])
    clAl.destroy
    redirect_to alumnos_index_path()
  end

  def show
    redirect_to alumnos_index_path()
  end
end
