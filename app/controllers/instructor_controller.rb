class InstructorController < ApplicationController
  def index
      @instructores = Instructor.all
  end

  def show
      @id = params[:id]
      fecha = "01/01/2022".to_datetime

      @instructor = Instructor.find(params[:id])
      @clases = Clase.where(instructor_id: 2).where(diaHora: fecha.beginning_of_month..fecha.end_of_month).order(:diaHora)
  end
end
