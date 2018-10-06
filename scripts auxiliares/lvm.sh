#!/bin/bash

function lvm(){
	#Guardamos el numero de lineas en A
		A=$( wc -l < lvm.conf ) 
		a=$(head -n+1 lvm.conf)
		b=$(head -n+2 lvm.conf | tail -n-1)
		if [ $A -le 2 ]
		then
			echo "LVM: Falta al menos un volumen logico para crear <<$a>>. "
			exit 2
		else
			echo "Creando grupo de volumenes logicos <<$a>>... "
			vgcreate $a $b > /dev/null 
		
		#Cogemos el tamaño del grupo
			tam=$(vgdisplay -s $a)
			tamGrupo=$(echo $tam | cut -f 2 -d " ")
			tamGroup=$(echo $tamGrupo | cut -f 1 -d ",")
		
		#Inicializamos contadores y sumador
			i=2
			j=3
			sumaVol=0
			while [ $i -lt $A ]
			do
			
				linea=$(head -n+$j lvm.conf | tail -n-1)
		
			#Obtenemos el tamano de cada volumen a crear y lo guardamos en sumaVol
				tamVol=$(echo $linea | cut -f 2 -d " ")
				x=$(echo $tamVol | cut -f 1 -d "G")

				sumaVol=$(($sumaVol + $x))
				
				j=$(($j+1))
				i=$(($i+1))
			done
		
		#Ahora comprobamos que la suma de los posibles volumenes no es mayor que el grupo
			if [[ $sumaVol -le $tamGroup ]]
			then
		
			#Reinicializamos los contadores
			i=2
			j=3
			#Cogemos los datos de los volumenes y los creamos 
				while [ $i -lt $A ] 
				do
					linea=$(head -n+$j lvm.conf | tail -n-1)
			
				#Obtenemos el nombre del volumnes
					nombre=$(echo $linea | cut -f 1 -d " ")
				
				#El tamaño
					tamVol=$(echo $linea | cut -f 2 -d " ")
			
				#Y creamos el volumen logico dentro se su grupo
					echo "Creando volumen logico <<$linea>> y agregando al grupo <<$a>>..."
					lvcreate -L $tamVol -n $nombre $a > /dev/null 

					j=$(($j+1))
					i=$(($i+1))
				done
			else
				echo "**Tamaño de volumenes fuera de rango...**"
				echo "Tamaño de grupo <<$a>>: $tamGrupo..."
				exit 2
			fi 
		fi 
}
	#Instalamos el servicio lvm2
		#Si no esta el servicio instalado, se instala
		instalado=$(dpkg -l | grep "Linux Logical Volume Manager") 
		valorInstalado=$(echo $?)
		
		if [ $valorInstalado != 0 ]
		then
			apt-get -y install lvm2 > /dev/null
			echo  "Servicio LVM instalado."
			lvm
		else
			lvm
		fi
		