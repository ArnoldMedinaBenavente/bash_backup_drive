#!/bin/bash

# Configuración
FECHA=$(date +\%F_\%H-\%M)
DESTINO="/var/backups/mysql"
ARCHIVO="respaldo_$FECHA.sql"
USUARIO="tuUsuario" 
CLAVE="tuClave" 
EMAIL="elCorreo@conDrive.mx"  # Cambia este correo a tu dirección
REMOTE="backup_drive:backups"  # Ajusta si usas otro nombre de remoto en rclone

# Crear carpeta si no existe
mkdir -p "$DESTINO"

# Crear respaldo MySQL
mysqldump -u "$USUARIO" -p"$CLAVE" --all-databases > "$DESTINO/$ARCHIVO"

# Subir respaldo al drive
rclone copy "$DESTINO/$ARCHIVO" "$REMOTE"

# 🧼 Limpiar: mantener solo los 5 archivos más recientes en LOCAL
# Obtener lista de archivos ordenados por fecha descendente
ARCHIVOS=$(rclone lsf "$REMOTE" --files-only | sort -r)

# Contador
CONTADOR=0

# Recorre los archivos y borra si hay más de 5
echo "$ARCHIVOS" | while read archivo; do
  CONTADOR=$((CONTADOR+1))
  if [ "$CONTADOR" -gt 8 ]; then
    echo "Eliminando $archivo"
    rclone delete "$REMOTE/$archivo" --drive-use-trash=false
  fi
done


# 🧼 Limpiar: mantener solo los 10 archivos más recientes en LOCAL
find "$DESTINO" -type f -name "respaldo_*.sql" | sort -r | sed -n '11,$p' | xargs -r rm --

