#!/bin/bash

	echo "Se procede a comprobar si el fichero PERFIL DE SERVICIO CLIENTE NIS es correcto"
	
	A=$( wc -l < nis_server.conf )
	
  	if [ $A -eq 0 ]
  	then
   		echo "NIS-Server: El archivo nis_server.conf esta vacio"
		exit 2
  	else
		echo " *** EN LA MÁQUINA SERVIDORA *** "

		a=$(head -1 nis_server.conf)
		
		echo "Nombre del dominio NIS: "$a""

		#Cambiamos el nombre de la máquina servidora 
		echo "Cambiamos el nombre de la máquina servidora y le asignamos el nombre NIS-Server"
		echo "NIS-Server" >  /etc/hostname
		b=$(cat /etc/hostname)
		
		echo "----- INTALACIÓN DEL PAQUETE EN SERVIDOR -----"

			apt-get install portmap -y > /dev/null

			echo "nis nis/domain string "$a > /tmp/nisinfo
			echo "Ejecutamos debconf-set-selections"
			debconf-set-selections /tmp/nisinfo
			apt-get install nis -y > /dev/null
			echo "Servicios PORTMAP Y NIS instalados"

			echo "--- Editar el fichero /etc/default/nis de la máquina servidora ---"
			sed -i 's/NISSERVER=false/NISSERVER=master/g' /etc/default/nis
			sed -i 's/NISCLIENT=true/NISCLIENT=false/g' /etc/default/nis

		# CREO QUE NO SE DEBE HACER, PORQUE NO SABEMOS LA DIRECCION IP QUE TENDRÁN LAS MÁQUINAS #
		#echo "--- Indicar a que máquinas damos acceso, editando fichero /etc/ypserv.securenets ---"

			echo "--- Modificando el archivo /var/yp/Makefile -> Este archivo indica que envia directamente a los servidores exclavos cualquier modificación efectuada en el servidor Maestro ---"
			sed -i 's/ALL = 	passwd group hosts rpc services netid protocols netgrp/ALL = 	passwd shadow group hosts rpc services netid protocols netgrp/g' /var/yp/Makefile

			echo "--- Reiniciando el servicio portmap y el servicio nis ---"
			/etc/init.d/rpcbind restart > /dev/null	#Nota, seleccionando "rpcbind" en lugar de portmap
			/etc/init.d/nis restart > /dev/null


			echo "--- Compilando en una BDD los usuarios y contraseñas ---"
			# Accedemos al directorio /var/yp
			cd /var/yp
			echo "Ejecutando el Makefile..."
			make > /dev/null
			
		echo "--- Reiniciando el servidor NIS ---"
			/etc/init.d/nis restart > /dev/null

		echo "--- SERVIDOR NIS ARRANCADO ---"

		#echo "----- BORRADO DEL PAQUETE -----"
		#echo "Se desinstala el paquete NIS"
		#apt-get remove nis -y
  	fi
