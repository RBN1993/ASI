#!/bin/bash

	echo "Se procede a comprobar si el fichero PERFIL DE SERVICIO es correcto"

	a=$(head -n+1 raid.conf)
	b=$(head -n+2 raid.conf | tail -n-1)
	c=$(tail -n-1 raid.conf)
	d=$(echo $c | wc -w)
	
  	A=$(wc -l < raid.conf) 
  	if [ $A -eq 0 ]
  	then
   		echo "RAID: El archivo raid.conf esta vacio"
   		exit 2
  	elif [ $A -lt 3 ]
  	then
   		a=$(head -1 raid.conf)
   		echo "RAID: no se puede crear el RAID <<$a>>, falta información en el fichero PERFIL DE SERVICIO"
   		exit 2
  	else
  		echo "Comprobando si el primer dispositivo contiene un SF"
	   	#Obtenemos el nombre del volumnes
	   	nombre=$(echo $c | cut -f 1 -d " ")
	  	dumpe2fs $nombre > sfFile
	  	z=$(wc sfFile -l | awk '{ print $1 }')

	  	if [ "$z" -eq 1 ]; then
	  		echo "El dispositivo "$nombre" no contiene un SF"

	  		if [[ "$b" -eq 0 || "$b" -eq 1 || "$b" -eq 2 || "$b" -eq 3 || "$b" -eq 4 || "$b" -eq 5 ]]
			then
				echo "Arrancando el servicio RAID"

				echo "Ejecutando script RAID"
				echo "Nombre del nuevo dispositivo raid: "$a
				echo "Nivel de raid: "$b
				echo "Dispositivos: "$c

				a=$(head -n+1 raid.conf)
				b=$(head -n+2 raid.conf | tail -n-1)
				c=$(tail -n-1 raid.conf)
				d=$(echo $c | wc -w)

				echo "Se procede a instalar el paquete de la distribución con la herramienta mdadm"
				echo "Hacer que el Front-End de debian sea no interactivo"
				export DEBIAN_FRONTEND="noninteractive"

				apt-get -q -y install mdadm --no-install-recommends > /dev/null
				
				echo "Se procede a realizar la configuración del RAID:"
				echo "	- Nombre del dispositivo: "$a""
				echo "	- Nivel del RAID: "$b""
				echo "	- Dispositivos: "$c""
				echo "	- Numero de dispositivos: "$d""

				mdadm --create --verbose --run --level=$b --raid-devices=$d $a $c > /dev/null

			else
				echo "Nivel de raid inválido "$b
				echo "No se realiza el servicio mount hasta que se modifique el fichero PERFIL DE SERVICIO"
				exit 2
			fi
	  	else
	  		echo "El dispositivo "$nombre" contiene un SF"
	  		exit 2
	  	fi
  	fi
