#!/bin/bash

function exportar(){
	
	#Guardamos el numero de lineas en A
		A=$( wc -l < nfs_server.conf ) 
		#Inicializamos contadores
		i=0
		j=1
		#Recorremos el fichero
		while [ $i -lt $A ]
		do
			linea=$(head -n+$j nfs_server.conf | tail -n-1)
			# echo $linea
		#Comprobamos que el directorio existe o no 
			busquedaDir=$(find $linea) > /dev/null
			valorFind=$(echo $?)
			if [ $valorFind != 0 ]
			then
			#Detenemos la ejecucion
				echo "Error directorio <<$linea>> no existe."
				exit 2
			else
			#Exportamos
				echo "Exportando directorio <<$linea>>"
				echo "$linea *(rw,sync,no_subtree_check)" >> /etc/exports # * permite a todo el mundo
			
				j=$(($j+1))
				i=$(($i+1))
			fi
		done
		#Reiniciamos el servidor NFS
		echo "Reiniciando servicio NFS"
		/etc/init.d/nfs-kernel-server restart > /dev/null
}
	#Instalamos los servicios nfs-common y nfs-kernel-server
		#Si no estan los servicios instalados entonces los instalamos
		instalado=$(dpkg -l | grep nfs-common) 
		valorInstalado=$(echo $?)
		
		if [ $valorInstalado != 0 ]
		then
			apt-get -y install nfs-common > /dev/null
			apt-get -y install nfs-kernel-server > /dev/null
			echo "Servicios instalados"
			exportar
		else
			exportar
		fi 	
		