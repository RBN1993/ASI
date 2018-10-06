#!/bin/bash

	echo "Se procede a comprobar si el fichero PERFIL DE SERVICIO es correcto"
		
		A=$( wc -l < mount_raid.conf ) 
		if [ $A -eq 0 ]
		then
			echo "MOUNT: El archivo mount_raid.conf esta vacio"
			exit 2
		elif [ $A -lt 2 ]
		then
			a=$(head -1 mount_raid.conf)
			echo "MOUNT: Falta el directorio donde se montará el dispositivo <<$a>>. "
			exit 2
		else
			echo "Ejecutando script MOUNT"

			a=$(head -1 mount_raid.conf)
			b=$(tail -1 mount_raid.conf)
			
			echo " - Comprobando si falta el nombre del dispositivo o el punto de mount"
			if [ "$a" == null ]
			then
				echo "El NOMBRE DEL DISPOTIVO no se encuentra en el fichero PERFIL DE SERVICIO"
				exit 2
			elif [ "$b" == null ]
			then
				echo "El PUNTO DE MONTAJE no se encuentra en el fichero PERFIL DE SERVICIO"
				exit 2
			else
				echo " - Comprobando si existe el dispositivo a montar"
				#lsblk $a > fileExist
				#disp=$(echo $a | cut -f 1 -d "/")
				disp=$(echo $a | cut -c6- )
				echo "El disp es: "$disp
				instalado=$( lsblk -l | grep $disp)
  				z=$(echo $?)
				#z=$(wc fileExist -l | awk '{ print $1 }')
				
				if [ "$z" -eq 0 ]
				then
					echo "El DISPOTIVO EXISTE"
					echo "Arrancando el servicio MOUNT"
					echo "Nombre del dispositivo: "$a
					echo "Punto de mount: "$b

					#Comprobacion existe directorio y esta vacio
					if [ -d $b ] #Si existe 
					then
						N=$(cd $b; ls|wc -l)
						if [ $N -eq 0 ] #Si esta vacio
						then	 
							echo "Montando directorio..."
							mount -t auto $a $b
							echo "$a $b auto default 0 0" >> /etc/fstab
						else #Si no esta vacio
							echo "Directorio no vacio no se aconseja montar..."
						fi
					else #Si no existe se crea y se monta
						echo "No existe direcorio. /n Creando..."	
						mkdir $b
						mount -t auto $a $b
						echo "$a $b auto default 0 0" >> /etc/fstab
					fi
				else
					echo "El DISPOTIVO NO EXISTE"
					echo "No se realiza el servicio mount hasta que se modifique el fichero PERFIL DE SERVICIO"
					exit 2
			fi
			fi
		fi
