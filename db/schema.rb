# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_06_18_153928) do

  create_table "active_storage_attachments", charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "almcsv", id: false, charset: "utf8", collation: "utf8_general_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.string "codigofacturacion", limit: 17
    t.string "COL 2", limit: 6
    t.string "COL 3", limit: 79
    t.string "COL 4", limit: 10
    t.string "COL 5", limit: 10
    t.string "COL 6", limit: 14
    t.string "email", limit: 35
    t.string "COL 8", limit: 79
    t.string "COL 9", limit: 6
    t.string "COL 10", limit: 22
    t.string "COL 11", limit: 10
    t.string "COL 12", limit: 4
    t.string "COL 13", limit: 24
    t.index ["email"], name: "email", unique: true
  end

  create_table "aulas", charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.string "nombre"
    t.integer "aforo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "cajas", charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.datetime "fecha"
    t.string "concepto"
    t.integer "importe_cents", default: 0, null: false
    t.string "importe_currency", default: "EUR", null: false
    t.integer "total_cents", default: 0, null: false
    t.string "total_currency", default: "EUR", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "usuario_id", null: false
    t.index ["usuario_id"], name: "index_cajas_on_usuario_id"
  end

  create_table "clase_alumno_estados", charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.string "nombre"
    t.string "color"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "clase_alumnos", charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.bigint "clase_id", null: false
    t.bigint "usuario_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "claseAlumnoEstado_id", default: 1, null: false
    t.datetime "diaHora"
    t.bigint "instructor_id", default: 1, null: false
    t.index ["claseAlumnoEstado_id"], name: "index_clase_alumnos_on_claseAlumnoEstado_id"
    t.index ["clase_id"], name: "index_clase_alumnos_on_clase_id"
    t.index ["instructor_id"], name: "index_clase_alumnos_on_instructor_id"
    t.index ["usuario_id"], name: "index_clase_alumnos_on_usuario_id"
  end

  create_table "clase_solicita", charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.bigint "clase_id", null: false
    t.bigint "usuario_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["clase_id"], name: "index_clase_solicita_on_clase_id"
    t.index ["usuario_id"], name: "index_clase_solicita_on_usuario_id"
  end

  create_table "clases", charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.datetime "diaHora"
    t.bigint "instructor_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "aula_id", null: false
    t.index ["aula_id"], name: "index_clases_on_aula_id"
    t.index ["instructor_id"], name: "index_clases_on_instructor_id"
  end

  create_table "grupos_alumnos", charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.string "nombre"
    t.string "codigoFacturacion"
  end

  create_table "horario_alumnos", charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.bigint "horario_id", null: false
    t.bigint "usuario_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["horario_id"], name: "index_horario_alumnos_on_horario_id"
    t.index ["usuario_id"], name: "index_horario_alumnos_on_usuario_id"
  end

  create_table "horarios", charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.integer "diaSemana", limit: 1
    t.integer "hora", limit: 2
    t.integer "minuto", limit: 2
    t.bigint "instructor_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "aula_id", null: false
    t.index ["aula_id"], name: "index_horarios_on_aula_id"
    t.index ["instructor_id"], name: "index_horarios_on_instructor_id"
  end

  create_table "inscripciones", charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.string "nombre"
    t.string "email"
    t.string "telefono"
    t.string "talleres"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "instructores", charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.string "nombre"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "usuario_id", null: false
    t.string "color"
    t.index ["usuario_id"], name: "index_instructores_on_usuario_id"
  end

  create_table "julios", charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.bigint "usuario_id"
    t.boolean "sem1"
    t.boolean "sem2"
    t.boolean "sem3"
    t.boolean "sem4"
    t.boolean "sem5"
    t.boolean "noviene"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "nombre"
    t.index ["usuario_id"], name: "index_julios_on_usuario_id"
  end

  create_table "proceso_estado_alumnos", charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.bigint "Usuario_id", null: false
    t.bigint "procesoEstado_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["Usuario_id"], name: "index_proceso_estado_alumnos_on_Usuario_id"
    t.index ["procesoEstado_id"], name: "index_proceso_estado_alumnos_on_procesoEstado_id"
  end

  create_table "proceso_estados", charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.bigint "proceso_id", null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "orden"
    t.index ["proceso_id"], name: "index_proceso_estados_on_proceso_id"
  end

  create_table "procesos", charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.string "nombre"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "pruebas", charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.bigint "clase_id", null: false
    t.string "nombre"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "movil"
    t.index ["clase_id"], name: "index_pruebas_on_clase_id"
  end

  create_table "recibo_estados", charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.string "nombre"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "color"
  end

  create_table "recibos", charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.bigint "usuario_id", null: false
    t.bigint "reciboEstado_id"
    t.decimal "importe", precision: 10
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "nombre"
    t.string "bic"
    t.string "iban"
    t.string "moneda"
    t.string "referencia"
    t.string "referenciaInformacion"
    t.date "mandatoFecha"
    t.string "sepaTipo"
    t.string "sepaSecuencia"
    t.boolean "batchBooking"
    t.string "serie"
    t.boolean "remesa"
    t.datetime "pago"
    t.datetime "vencimiento"
    t.string "factura"
    t.string "concepto"
    t.string "lugar"
    t.bigint "remesa_id"
    t.index ["remesa_id"], name: "index_recibos_on_remesa_id"
    t.index ["usuario_id"], name: "index_recibos_on_usuario_id"
  end

  create_table "remesa_recibos", charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.bigint "remesa_id", null: false
    t.datetime "vencimiento"
    t.datetime "emision"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "recibo_id"
    t.index ["recibo_id"], name: "index_remesa_recibos_on_recibo_id"
    t.index ["remesa_id"], name: "index_remesa_recibos_on_remesa_id"
  end

  create_table "remesas", charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.string "nombre"
    t.string "iban"
    t.string "bic"
    t.string "empresa"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "usuarios", charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "nombre"
    t.string "dni"
    t.string "telefono"
    t.string "movil"
    t.string "direccion"
    t.string "pais"
    t.string "localidad"
    t.string "provincia"
    t.string "iban"
    t.string "lugarfirma"
    t.date "fechafirma"
    t.boolean "debaja"
    t.string "codigofacturacion"
    t.string "cp"
    t.boolean "admin", default: false
    t.boolean "regalo"
    t.bigint "grupoAlumno_id", null: false
    t.integer "rol", default: 0
    t.bigint "instructor_id"
    t.string "bic"
    t.string "serie"
    t.boolean "remesa"
    t.date "fechaCaducidad"
    t.string "referencia"
    t.string "tipo"
    t.boolean "navidad"
    t.index ["email"], name: "index_usuarios_on_email", unique: true
    t.index ["grupoAlumno_id"], name: "index_usuarios_on_grupoAlumno_id"
    t.index ["instructor_id"], name: "index_usuarios_on_instructor_id"
    t.index ["reset_password_token"], name: "index_usuarios_on_reset_password_token", unique: true
  end

  add_foreign_key "remesa_recibos", "remesas"
end
