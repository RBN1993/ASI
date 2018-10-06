#!/bin/bash

	echo "Se procede a comprobar si el fichero PERFIL DE SERVICIO CLIENTE NIS es correcto"

	#Guardamos el numero de lineas en B
	B=$( wc -l < nis_client.conf ) 
  	if [ $B -eq 0 ]
  		then
   		echo "NIS-Client: El archivo nis_client.conf esta vacio"
		exit 2
  	elif [ $B -lt 2 ]
  	then
   		a=$(head -1 nis_client.conf)
   		echo "NIS-Client: no se puede crear el cliente NIS, pues el fichero PERFIL DE SERVICIO esta incompleto"
   		exit 2
  	else
		echo "Comprobamos que la dirección IP del fichero PERFIL DE SERVIDOR es correcta"
	  	b=$(tail -1 nis_client.conf)
		
		ping -c 3 $b > dirIP
		y=$(wc dirIP -l | awk '{ print $1 }')
		if [ "$y" -eq 0 ]
		then
			echo "No es una dirección IP correcta"
			exit 2
		else

	  		echo "+++ EN LA MÁQUINA CLIENTE NIS +++"

			a=$(head -1 nis_client.conf)
			b=$(tail -1 nis_client.conf)
			
			echo "Nombre del dominio NIS: "$a""
			echo "Servidor NIS al que se conecta : "$b""

			#Cambiamos el nombre de la máquina cliente
			echo "Cambiando el nombre de la máquina y le asignamos el nombre NIS-Client..."
			echo "NIS-Client" >  /etc/hostname
			c=$(cat /etc/hostname)
			echo "La máquina cliente NIS es esta en la que esta ejecutando el script principal, cuyo nombre es: "$c

			echo "----- INTALACIÓN DEL PAQUETE -----"
				echo "Se instala el paquete NIS"
				echo "nis nis/domain string "$a > /tmp/nisinfo
				echo "Ejecutando debconf-set-selections..."
				debconf-set-selections /tmp/nisinfo
				apt-get install nis -y > /dev/null

			############################################################################

			echo "--- Editando el fichero /etc/default/nis de la máquina servidora ---"
				sed -i 's/NISCLIENT=false/NISCLIENT=true/g' /etc/default/nis

			echo "----- Especificar la localización del servidor NIS -----"
				echo "ypserver "$b >> /etc/yp.conf

			echo "----- Configurando el archivo /etc/passwd -----"
				echo "+::::::" >> /etc/passwd

			echo "----- Configurando del archivo /etc/group -----"
				echo "+:::" >> /etc/group

			echo "----- Arrancar NIS -----"
				/etc/init.d/nis stop > /dev/null
				/etc/init.d/nis start > /dev/null

			############################################################################

			#echo "----- BORRADO DEL PAQUETE -----"
			#echo "Se desinstala el paquete NIS"
			#apt-get remove nis -y	

			echo "+++ CLIENTE NIS ARRANCADO +++"
	  	fi
	fi
