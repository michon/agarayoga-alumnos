class InstructorController < ApplicationController
  def index
      @instructores = Instructor.all
  end

  def show
      @id = params[:id]
      @instructor = Instructor.find(params[:id])
      @clases = Clase.where(instructor_id: 2).where(diaHora: DateTime.now.beginning_of_month..DateTime.now.end_of_month).order(:diaHora)
  end
end
