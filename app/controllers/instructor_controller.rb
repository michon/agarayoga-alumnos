class InstructorController < ApplicationController
  def index
      @instructores = Instructor.all
  end

  def show
      @id = params[:id]
      @fecha = "01/02/2022".to_datetime
      @fecha = params[:fecha].to_datetime

      @instructor = Instructor.find(params[:id])
      @clases = Clase.where(instructor_id: @id).where(diaHora: @fecha.beginning_of_month..@fecha.end_of_month).order(:diaHora)
      @total = 0

      @recibos = Reciboscli.all
     #Deberia comprobar la tabla reciboscli de la facturación para ver si no tiene recibos pendientes.
     #En caso afirmativo, se cuenta para pagar a Raquel
     #En caso negativo no.
     #Luego el proceso normal si tiene menos de 7 12 e si son 7 u 8  18 y si mp 20

     @clases.each do |cl|
       if cl.claseAlumno.count < 7
               @total = @total + 12
           elsif cl.claseAlumno.count < 9
               @total = @total + 18
           else
              @total  = @total + 20
       end
     end
  end

end
