class MigrateHistoricoAFacturas < ActiveRecord::Migration[6.1]
  def up
    # Insertar facturas desde recibos de serie A con factura asignada y pagados
    execute <<-SQL
      INSERT INTO facturas (
        numero, tipo, estado, recibo_id, fecha_emision,
        base_imponible, iva, total, trimestre,
        created_at, updated_at
      )
      SELECT 
        r.factura as numero,
        0 as tipo,
        1 as estado,
        r.id as recibo_id,
        DATE(r.vencimiento) as fecha_emision,
        ROUND(r.importe * 100 / 121, 2) as base_imponible,
        ROUND(r.importe * 21 / 121, 2) as iva,
        r.importe as total,
        CONCAT(YEAR(r.vencimiento), 'T', QUARTER(r.vencimiento)) as trimestre,
        NOW() as created_at,
        NOW() as updated_at
      FROM recibos r
      WHERE r.serie = 'A' 
        AND r.factura IS NOT NULL 
        AND r.factura != ''
        AND r.reciboEstado_id = 2
    SQL
    
    # Actualizar recibos con su factura_id correspondiente
    execute <<-SQL
      UPDATE recibos r
      JOIN facturas f ON f.recibo_id = r.id
      SET r.factura_id = f.id
    SQL
  end
  
  def down
    # Limpiar facturas migradas (estado 1 = emitida)
    execute "DELETE FROM facturas WHERE estado = 1"
    
    # Resetear factura_id en recibos
    execute "UPDATE recibos SET factura_id = NULL WHERE factura_id IS NOT NULL"
  end
end
