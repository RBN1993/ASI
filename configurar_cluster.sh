#!/bin/bash

function mount(){
	echo "*** SERVICIO MOUNT ***"
	echo "**********************"
				
	Y=$( wc -l < $fichServicio )
	if [ $Y -eq 0 ]
	then
		echo "MOUNT: El archivo $fichServicio esta vacio"
		exit 2
	else
		echo "###Ejecutando script MOUNT###"
		echo "Copiando el fichero $fichServicio en la máquina: "$dirIP
		scp $Z/$fichServicio root@$dirIP:/root

		echo "Conectando por SSH a la máquina $dirIP y ejecutando el servicio"
		ssh -x root@$dirIP 'bash -s' < $Z/mount.sh
	fi	
}

function raid(){
	echo "*** SERVICIO RAID ***"
	echo "*********************"

  	Y=$(wc -l < $fichServicio) 
  	if [ $Y -eq 0 ]
  	then
   		echo "RAID: El archivo $fichServicio esta vacio"
   		exit 2
  	else
  		echo "###Ejecutando script RAID###"
		echo "Copiando el fichero $fichServicio en la máquina: "$dirIP
		scp $Z/$fichServicio root@$dirIP:/root

		echo "Conectando por SSH a la máquina $dirIP y ejecutando el servicio"
		ssh -x root@$dirIP 'bash -s' < $Z/raid.sh
	fi
}

function lvm(){
	echo "*** SERVICIO LVM ***"
	echo "********************"

	A=$( wc -l < $fichServicio ) 
	if [ $A -eq 0 ]
	then
		echo "LVM: El archivo $fichServicio esta vacio"
		exit 2
	else
		echo "###Ejecutando script LVM###"
		echo "Copiando el fichero $fichServicio en la máquina: "$dirIP
		scp $Z/$fichServicio root@$dirIP:/root

		echo "Conectando por SSH a la máquina $dirIP y ejecutando el servicio"
		ssh -x root@$dirIP 'bash -s' < $Z/lvm.sh
	fi
}

function nis_server(){
	echo "*** SERVICIO SERVIDOR NIS ***"
	echo "*****************************"
	
	Y=$( wc -l < $fichServicio )
  	if [ $Y -eq 0 ]
  	then
   		echo "NIS-Server: El archivo $fichServicio esta vacio"
		exit 2
  	else
	
  		echo "###Ejecutando script NIS-Server###"
		echo "Copiando el fichero $fichServicio en la máquina: "$dirIP
		scp $Z/$fichServicio root@$dirIP:/root

		echo "Conectando por SSH a la máquina $dirIP y ejecutando el servicio"
		ssh -x root@$dirIP 'bash -s' < $Z/nis_server.sh
	fi
}

function nis_client(){
	echo "*** SERVICIO CLIENTE NIS ***"
	echo "****************************"

	Y=$( wc -l < $fichServicio )
  	if [ $Y -eq 0 ]
  	then
   		echo "NIS-Client: El archivo $C esta vacio"
		exit 2
  	else
		echo "###Ejecutando script NIS-CLIENT###"
		echo "Copiando el fichero $fichServicio en la máquina: "$dirIP
		scp $Z/$fichServicio root@$dirIP:/root

		echo "Conectando por SSH a la máquina $dirIP y ejecutando el servicio"
		ssh -x root@$dirIP 'bash -s' < $Z/nis_client.sh
	fi
}

function nfs_server(){
	echo "*** SERVICIO SERVIDOR NFS-SERVER ***"
	echo "*****************************"

	A=$( wc -l < $fichServicio ) 
	if [ $A -eq 0 ]
	then
		echo "NFS-SERVER: El archivo $fichServicio esta vacio"
		exit 2
	else
		echo "###Ejecutando script NFS-SERVER###"
		echo "Copiando el fichero $fichServicio en la máquina: "$dirIP
		scp $Z/$fichServicio root@$dirIP:/root

		echo "Conectando por SSH a la máquina $dirIP y ejecutando el servicio"
		ssh -X root@$dirIP 'bash -s' < $Z/nfs_server.sh
	fi
}

function nfs_client(){
	echo "*** SERVICIO NFS-CLIENT### ***"
	echo "****************************"

	A=$( wc -l < $fichServicio ) 
	if [ $A -eq 0 ]
	then
		echo "NFS-CLIENT: El archivo $fichServicio esta vacio"
	else
		echo "###Ejecutando script NFS-CLIENT###"
		echo "Copiando el fichero $fichServicio en la máquina: "$dirIP
		scp $Z/$fichServicio root@$dirIP:/root

		echo "Conectando por SSH a la máquina $dirIP y ejecutando el servicio"
		ssh -X root@$dirIP 'bash -s' < $Z/nfs_client.sh
	fi
}

##########################################################################################

if [ "$1" == "fichero_configuracion" ]
then
	
	# Ubicación del script maestro y del fichero de configuración
	Z=$(pwd)
	#echo $Z
	FILE="${Z}/fichero_configuracion"
	#echo $FILE

	# Contador de líneas para el fichero de configuración
	contador=1
	#echo $contador
	while read line
	do 
	   		
	   	A=$(echo -e "$line")   	
		echo "Linea leida : "$A

		#Para saber el numero de parametros que tiene esa línea
		Nl=$(echo "$A" | wc -w)
		echo "El número de parámetros es: "$Nl

		dirIP=$(echo $A | cut -f 1 -d " ")
		service=$(echo $A | cut -f 2 -d " ")
		fichServicio=$(echo $A | cut -f 3 -d " ")
			
		if [ "$dirIP" == "#" ]
		then
			echo "Es un comentario (#)"
			echo "Fin de línea: "$contador
			let contador=contador+1
			echo "--------------------------------"
			continue
		elif [ "$dirIP" == '' ]
		then
			echo "Es un salto de linea (\n)"
			echo "Fin de línea: "$contador
			let contador=contador+1
			echo "--------------------------------"
			continue
		elif [ $Nl -eq 3 ]
		then
			dirIP=$(echo $A | cut -f 1 -d " ")
			service=$(echo $A | cut -f 2 -d " ")
			fichServicio=$(echo $A | cut -f 3 -d " ")
			
				echo "DirIP es: "$dirIP
				echo "service es: "$service
				echo "fichServicio es: "$fichServicio
		
				if [ $service == 'mount' ]
				then
					mount
					echo "El valor devuelto por MOUNT es: "$?
					valor=$(echo $?)
					if [ $valor != 0 ]
					then
						exit 2
					# else
						# continue
					fi 
				elif [ $service == 'raid' ]
				then	
					raid
					echo "El valor devuelto por RAID es: "$?
					valor=$(echo $?)
					if [ $valor != 0 ]
					then
						exit 2
					# else
						# continue
					fi 
				elif [ $service == 'lvm' ]
				then	
					lvm
					echo "El valor devuelto por LVM es: "$?
					valor=$(echo $?)
					if [ $valor != 0 ]
					then
						exit 2
					# else
						# continue
					fi 
				elif [ $service == 'nis_server' ]
				then	
					nis_server
					echo "El valor devuelto por NIS-Server es: "$?
					valor=$(echo $?)
					if [ $valor != 0 ]
					then
						exit 2
					# else
						# continue
					fi 
				elif [ $service == 'nis_client' ]
				then	
					nis_client
					echo "El valor devuelto por NIS-Client es: "$?
					valor=$(echo $?)
					if [ $valor != 0 ]
					then
						exit 2
					# else
						# continue
					fi 
				elif [ $service == 'nfs_server' ]
				then	
					nfs_server
					echo "El valor devuelto por NFS-Server es: "$?
					valor=$(echo $?)
					if [ $valor != 0 ]
					then
						exit 2
					# else
						# continue
					fi 
				elif [ $service == 'nfs_client' ]
				then	
					nfs_client
					echo "El valor devuelto por NFS-Client es: "$?
					valor=$(echo $?)
					if [ $valor != 0 ]
					then
						exit 2
					# else
						# continue
					fi 
				else
					echo "NO SE ENCONTRÓ EL SERVICIO"
					exit 2
				fi
		else
			echo "La línea $contador no comple con el formato:"
			echo "	EJEMPLO LINEA: maquina-destino nombre-del-servicio fichero-de-perfil-de-servicio"
			exit $contador
		fi
				
			echo "Fin de línea: "$contador
			let contador=contador+1
			echo "--------------------------------"
	done < $FILE

else  
	echo "No se pasó el fichero configuración como parámetro"
fi
