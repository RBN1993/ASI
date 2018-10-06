#!/bin/bash

function nfs_client(){
		#Guardamos el numero de lineas en A
		A=$( wc -l < nfs_client.conf ) 
	
		#Recorremos el fichero
		i=0
		j=1
		while [ $i -lt $A ]
		do
			linea=$(head -n+$j nfs_client.conf | tail -n-1)
	
			#Comprobamos que no falta un parametro 
			numParametros=$(echo $linea | wc -w)
			
			if [[ $numParametros -lt 3 || $numParametros -gt 3 ]]
			then
				echo "Numero de parametros invalido : $numParametros"
				echo "El archivo nfs_client.conf deberia tener 3 parametros"
				exit 2
			else 
				#Cogemos el nombre del servidor
				name=$(echo $linea | cut -f 1 -d " ")
				
				hostValido=$(ping -c 4 $name)
				valorHostDevuelto=$(echo $?)
				
				if [ $valorHostDevuelto != 0 ]
				then 
					echo "Host invalido : $name"
					exit 2
				else
					#Cogemos directorio remoto
					dirRemoto=$(echo $linea | cut -f 2 -d " ")
					
					#Cogemos directorio donde montar
					dir=$(echo $linea | cut -f 3 -d " ")
					
					#Comprobamos que el directorio existe
					if [ -d $dir ]
					then
						echo "Montando $dirRemoto en directorio <<$dir>> ..."	

						mount $name:$dirRemoto $dir > /dev/null
						
						#Agregamos al fichero /etc/fstab
						echo $name:$dirRemoto $dir nfs defaults,auto 0 0 >> /etc/fstab
						j=$(($j+1))
						i=$(($i+1))
						
					else
						#No existe, entonces lo creamos
						
						echo "Creando directorio <<$dir>> ..."
						mkdir $dir 
						
						echo "Montando $dirRemoto en directorio <<$dir>> ..."
						mount $name:$dirRemoto $dir > /dev/null
						
						#Agregamos al fichero /etc/fstab
						echo $name:$dirRemoto $dir nfs auto,rw,users 0 0 >> /etc/fstab

						j=$(($j+1))
						i=$(($i+1))
					fi
				fi
			fi
		done
		#Reiniciamos el el servidor NFS
		echo "Reiniciando servidor NFS"
		/etc/init.d/nfs-kernel-server restart > /dev/null
}

	#Instalamos los servicios nfs-common y nfs-kernel-server
		#Si no estan el servicio instalado entonces lo instalamos
		instalado=$(dpkg -l | grep nfs-kernel-server) 
		valorInstalado=$(echo $?)
		
		if [ $valorInstalado != 0 ]
		then
			
			apt-get -y install nfs-kernel-server > /dev/null
			echo  "Servicio nfs instalado."
			nfs_client
			
		else
			nfs_client
		fi
	