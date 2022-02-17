class AlumnosController < ApplicationController
  require 'ficha_alumno.rb'

  def index
      @alumnos = Usuario.where(debaja: [false,  nil]).all
  end

  def procesos
      if params[:proceso].blank?
          proceso = 2
      else
          proceso = params[:proceso]
      end
      @proceso = proceso
      @procesos = Proceso.all
      if proceso then
          @procesoEstados = ProcesoEstado.where(proceso_id: proceso).all
          @procesoLista = Array.new(Usuario.activo.count)
          Usuario.activo.order(:nombre).each_with_index do |usr, idx|
              @procesoLista[idx] = Array.new
              @procesoLista[idx][2] = usr
              @procesoLista[idx][1] = Array.new
              @procesoLista[idx][0] = ProcesoEstadoAlumno.where(usuario_id: usr.id, procesoEstado_id: ProcesoEstado.where(proceso_id: proceso)).count.to_s + usr.nombre
              ProcesoEstado.where(proceso_id: proceso).each_with_index do |prcs, i|
                  @procesoLista[idx][1][i] = Array.new
                  @procesoLista[idx][1][i][0] = prcs
                  @procesoLista[idx][1][i][1] = ProcesoEstadoAlumno.where(usuario_id: usr.id, procesoEstado_id: prcs.id).first
              end
          end
      else
          @procesoEstados = ProcesoEstado.all
      end
  end

  def procesosAlta
      proceso =  params[:proceso]
      alumno  =  params[:alumno]
      if ProcesoEstadoAlumno.exists?(Usuario_id: alumno, procesoEstado_id: proceso) then
          ProcesoEstadoAlumno.find_by(Usuario_id: alumno, procesoEstado_id: proceso).delete
      else
          ProcesoEstadoAlumno.new(Usuario_id: alumno, procesoEstado_id: proceso).save
      end
      redirect_to alumnos_procesos_path(proceso: proceso)
  end

  def business
      @fecha = params[:fecha].to_datetime
      @fechaFin = DateTime.now
      @alumnos = Usuario.where(debaja: [false,  nil]).where(created_at: @fecha.beginning_of_month..@fechaFin.end_of_month).all
  end

  def show
      @id = params[:id]
      @almn = Usuario.find(params[:id])
      @claseAlumno = ClaseAlumno.where(usuario_id: @id)
      @estados = ClaseAlumnoEstado.order(:id).all

      @clases = []
      @claseAlumno.each do |cl|
        clase = Hash.new {}
        clase["fechaClase"] =  cl.clase.diaHora
        clase["clase"] = cl.clase
        clase["claseAlumno"] = cl
        @clases << [ cl.clase.diaHora, clase]
      end
      respond_to do |format|
          format.html

          format.pdf do
            ficha = FichaAlumno.new(@almn)
            ficNombre = "ficha_" + @almn.nombre.sub(" ", "-")
            send_data ficha.render, filename: ficNombre, type: 'application/pdf', diposition: 'inline'
          end
      end
  end

  def ficha
      @id = params[:id]
      @almn = Usuario.find(params[:id])
  end

  def sepa
      @id = params[:id]
      @almn = Usuario.find(params[:id])
  end

  def regalo
      usr= Usuario.find(params[:id])
      usr.regalo = (not usr.regalo)
      usr.save
      redirect_to alumnos_index_path
  end


  private

end
