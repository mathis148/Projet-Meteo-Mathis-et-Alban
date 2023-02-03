#!/bin/bash
echo "le nom du script est : $0"
echo "le nombre d'argument est : $#"
echo "le(s) argument(s) est(sont) : $*"
echo ""

	#L'OPTION --HELP#
if [ $1 = "--help" ]; then         # vérifie si l'argument est "--help" si c'est le cas nous affichons la liste des arguments et leurs instructions
	echo " "
	echo "Voici les options de type de données :"
	echo "-t<mode> : pour avoir la température"
	echo "	-> t1 : températures minimales, maximales et moyennes par station et dans l'ordre croissant du numéro de station"
	echo "	-> t2 : températures moyennes sur toutes les stations, par date/heure et triées dans l'ordre chronologique"
	echo	"-p<mode> : pour avoir la pression atmosphérique"
	echo "	-> p1 : pressions minimales, maximales et moyennes par station et dans l'ordre croissant du numéro de station"
	echo "	-> p2 : presion moyennes sur toutes les stations, par date/heure et triées dans l'ordre chronologique"
	echo " "
	echo "-w : pour avoir le vent"
	echo "-m : pour avoir l'humidité"
	echo "-h : pour avoir l'altitude de chaque station"
	echo " "
	echo "Voici les options de lieux :"
	echo "-F : pour avoir la France métropolitaine et la Corse"
	echo "-G : pour avoir la Guyane française"
	echo "-S : pour avoir Saint-Pierre et Miquelon"
	echo "-A : pour avoir les Antilles"
	echo "-O : pour avoir l'Océan indien"
	echo "-Q : pour avoir l'Antartique"
	echo " "
	echo "Voici les options de tris :"
	echo "--tab : pour trier à l'aide d'une liste chainnée"
	echo "--abr : pour trier à l'aide d'un arbre binaire de recherche ABR"
	echo "--avl : pour trier à l'aide d'un arbre binaire de recherde équilibré AVL"
	exit 0
	

	


else
for arg in "$@"
do
# cette partie nous permet de vérifier que tous les arguments saisi par l'utilisateur sont bien des vrais arguments 
if [ $arg != "-t1" ] && [ $arg != "-t2" ] && [ $arg != "-t3" ] && [ $arg != "-p1" ] && [ $arg != "-p2" ] && [ $arg != "-p3" ] && [ $arg != "-w" ] && [ $arg != "-h" ] && [ $arg != "-m" ] && [ $arg != "-F" ] && [ $arg != "-G" ] && [ $arg != "-S" ] && [ $arg != "-A" ] && [ $arg != "-O" ] && [ $arg != "-Q" ] && [ $arg != "-d" ] && [[ $arg =~ ....-..-.. ]] && [ $arg = "--abr" ] && [ $arg = "--avl" ] && [ $arg = "--tab" ]
then
# envoie un message d'erreur si l'argument n'existe pas 
echo "Vous avez commis une erreur, faite --help pour avoir plus d'informations sur les arguments"
exit 1
elif [ $arg = "--abr" ] || [ $arg = "--avl" ] || [ $arg = "--tab" ]; then
tri=$arg
fi
done

# cette partie du code permet de filtrer les donées par lieux si l'utilisateur souhaite filtrer par lieux
for arg in "$@"
do 
if [ $arg = "-F" ]; then # filtrage pour la France 
cat meteo_filtered_data_v1.csv | grep   -E ";([0-8].|9[0-5])...$" > lieu.csv  
elif [ $arg = "-G" ]; then
cat meteo_filtered_data_v1.csv | grep  "973..$"  > lieu.csv
elif [ $arg = "-S" ]; then
cat meteo_filtered_data_v1.csv | grep  "975..$"  > lieu.csv
elif [ $arg = "-A" ]; then
cat meteo_filtered_data_v1.csv | grep  -e "972..$" -e "977..$" -e "978..$" > lieu.csv
elif [ $arg = "-O" ]; then
cat meteo_filtered_data_v1.csv | grep  -e "974..$" -e"976..$" -e"98..." > lieu.csv
elif [ $arg = "-Q" ]; then
cat meteo_filtered_data_v1.csv | grep  ";$" | grep -E ";-[6-9].\.......,...\....;" > lieu.csv
else cp meteo_filtered_data_v1.csv lieu.csv
fi
done

# cette partie nous permet de filtrer par date avec une date min et une max le programe recupère uniquement les donée se trouvant dans l'interval
argsuivant=0
for arg in "$@"
do 
if [ $arg = "-d" ]; then
argsuivant=2
elif [ $argsuivant -eq 2 ]; then
min=$arg
argsuivant=1
elif [ $argsuivant -eq 1 ]; then
max=$arg
argsuivant=3
fi
done
if [ $argsuivant=3 ]; then
cat lieu.csv | grep   -E ";$min|$max" > date.csv  
echo "0-le filtrage des données c'est déroulé correctement"
else cp lieu.csv date.csv
echo "0-le filtrage des données c'est déroulé correctement"
fi


for arg in "$@"
do
		#LES OPTIONS POUR LA TEMPERATURE#
		if [ $arg = "-t1" ]; then
			cat date.csv | awk -F ";" 
			cut -f1,11 -d ";" date.csv | grep -v ";$" > arg.csv 
			sort arg.csv > final.csv
			echo "0-le trie par le programe c c'est déroulé correctement"
			#Calcule moyenne, min et max
			awk -F ';' 'BEGIN { num="" ; n=0 ; m=0 } { if(num!=$1){ if(n!=0){print m";"sum/n";"min";"max";"num} num=$1 ; min=$2 ; max=$2 ; n=0 ; sum=0 ; m+=1 } sum+=$2 ; n+=1 ; if($2<min){min=$2} if($2>max){max=$2} } END {print m";"sum/n";"min";"max";"num}' final.csv > gnuplot.csv
			echo "Création du graphique"
			echo ""
			gnuplot  <<-EOFMarker
			set terminal png size 1920,1080
			set output "temperature-1.png"
			set title "Temperature en fonction de la station"
			set xlabel "ID Station"
			set ylabel "Temperature (C°)"
			set datafile separator ";"
			Shadecolor = "#80E0A080"
			set xtics rotate by 45 offset -2,-1.5
			plot "gnuplot.csv" using 1:4:3 with filledcurve fc rgb Shadecolor title "Plage des Temperatures", ''using 1:2:xtic(5) lw 2 with linespoints title "Temperature moyenne"
			EOFMarker
			echo "Le graphique à été créer avec succés !"
			echo ""
			
		elif [ $arg = "-t2" ]; then
			cat date.csv | awk -F ";" 
			donnee="$(cut -d';' -f2 date.csv | date -u -f - '+%Y%m%d%H' | pr -mts' ' - <(cut -d";" --output-delimiter=" " -f11 date.csv))"
			echo "$donnee" > arg.csv
				nomValeur="Température"
				unite="°C"
				couleur="#ff3333"
			sort arg.csv > final.csv
			echo "0-le trie par le programe c c'est déroulé correctement"
			#Calcule moyenne
			time awk -F ' ' 'BEGIN { date="" ; n=0 } { if(date!=$1){ if(n!=0){print date" "sum/n} date=$1 ; n=0 ; sum=0 } sum+=$2 ; n+=1 } END {print date" "sum/n}' final.csv > gnuplot.csv
			
			#Generation graphique via gnuplot
			echo "Création du graphique"
			echo ""
			gnuplot <<-EOFMarker
			set terminal png size 1920,1080
			set output "temperature-2.png"
			set title "$nomValeur en fonction du jour"
			set xlabel "Jour"
			set ylabel "$nomValeur ($unite)"
			set datafile separator " "
			set xdata time
			set timefmt '%Y%m%d%H'

			set xrang [*:*] noextend
			set yrang [*:*] noextend

			Couleur = "$couleur"
			plot "gnuplot.csv" using 1:2 with lines lw 2 lc rgbcolor "$couleur" title "$nomValeur moyenne"
			EOFMarker
			echo "Le graphique à été créer avec succés !"
			echo ""

				
		elif [ $arg = "-t3" ]; then
			echo "Oups, il peut survenir des éreures avec l'argument -p3, rééssayer avec un autre argument"
					
		#LES OPTIONS POUR LA PRESSION#
		elif [ $arg = "-p1" ]; then
			cat date.csv | awk -F ";"
			cut -f1,7 -d ";" date.csv | grep -v ";$" > arg.csv 
			sort arg.csv > final.csv
			echo "0-le trie par le programe c c'est déroulé correctement"
			#Calcule moyenne, min et max
			awk -F ';' 'BEGIN { num="" ; n=0 ; m=0 } { if(num!=$1){ if(n!=0){print m";"sum/n";"min";"max";"num} num=$1 ; min=$2 ; max=$2 ; n=0 ; sum=0 ; m+=1 } sum+=$2 ; n+=1 ; if($2<min){min=$2} if($2>max){max=$2} } END {print m";"sum/n";"min";"max";"num}' final.csv > gnuplot.csv
			echo "Création du graphique"
			echo ""
			gnuplot <<-EOFMarker
			set terminal png size 1920,1080
			set output "pression-1.png"
			set title "Pression en fonction de la station"
			set xlabel "ID Station"
			set ylabel "Pression (Pa)"
			set datafile separator ";"
			Shadecolor = "#80E0A080"
			set xtics rotate by 45 offset -2,-1.5
			plot "gnuplot.csv" using 1:4:3 with filledcurve fc rgb Shadecolor title "Plage des pressions", ''using 1:2:xtic(5) lw 2 with linespoints title "Pression moyenne"
			EOFMarker
			echo "Le graphique à été créer avec succés !"
			echo ""
			
		elif [ $arg = "-p2" ]; then
			cat date.csv | awk -F ";"	
			donnee="$(cut -d';' -f2 date.csv | date -u -f - '+%Y%m%d%H' | pr -mts' ' - <(cut -d";" --output-delimiter=" " -f7 date.csv))"
			echo "$donnee" > arg.csv
				nomValeur="Température"
				unite="°C"
				couleur="#ff3333"
			sort arg.csv > final.csv
			echo "0-le trie par le programe c c'est déroulé correctement"
			#Calcule moyenne
			time awk -F ' ' 'BEGIN { date="" ; n=0 } { if(date!=$1){ if(n!=0){print date" "sum/n} date=$1 ; n=0 ; sum=0 } sum+=$2 ; n+=1 } END {print date" "sum/n}' final.csv > gnuplot.csv
			
			#Generation graphique via gnuplot
			echo "Création du graphique"
			echo ""
			gnuplot <<-EOFMarker
			set terminal png size 1920,1080
			set output "pression-2.png"
			set title "$nomValeur en fonction du jour"
			set xlabel "Jour"
			set ylabel "$nomValeur ($unite)"
			set datafile separator " "
			set xdata time
			set timefmt '%Y%m%d%H'

			set xrang [*:*] noextend
			set yrang [*:*] noextend

			Couleur = "$couleur"
			plot "gnuplot.csv" using 1:2 with lines lw 2 lc rgbcolor "$couleur" title "$nomValeur moyenne"
			EOFMarker
			echo "Le graphique à été créer avec succés !"
			echo ""
			
		elif [ $arg = "-p3" ]; then
			echo "Oups, il peut survenir des éreures avec l'argument -p3, rééssayer avec un autre argument"
			
		#L'OPTION POUR LE VENT#
		elif [ $arg = "-w" ]; then
			cat date.csv | awk -F ";"
			awk -F';' '{ if( $4 != "" && $5 != "" ){split($10, coord, ",") ; print $1";"coord[1]";"coord[2]";"$4";"$5} }' date.csv > arg.csv
			sort arg.csv > final.csv
			echo "0-le trie par le programe c c'est déroulé correctement"
			awk -F ';' 'BEGIN { num="" ; force=0 ; direction=0 ; n=0 ; ns=0 ; eo=0 } { if(num!=$1){ if(n!=0){print num";"ns";"eo";"direction/n";"force/n} num=$1 ; n=0 ; direction=0 ; force = 0 ; ns=$2 ; eo=$3 } direction+=$4 ; force+=$5 ; n+=1 } END {print num";"ns";"eo";"direction/n";"force/n}' final.csv > gnuplot.csv
			
		for arg in "$@"
		do	
			#Récupèration x et y min/max en fonction de la zone géographique
				#France
				if [ $arg = "-F" ]; then 
					xmin=-14
					xmax=18
					ymin=38
					ymax=54
					nom=Carte/CarteFrance.png

				#Guyane
				elif [ $arg = "-G" ]; then
					xmin=-70
					xmax=-36
					ymin=-5
					ymax=12
					nom=Carte/CarteGuyane.png
			

				#St Pierre et Miquelon
				elif [ $arg = "-S" ]; then 
					xmin=-71
					xmax=-41
					ymin=38
					ymax=53
					nom=Carte/CarteStPierre.png
			
				
				#Antilles
				elif [ $arg = "-A" ]; then 
					xmin=-72
					xmax=-48
					ymin=8
					ymax=20
					nom=Carte/CarteAntilles.png
				

				#Océan indien
				elif [ $arg = "-O" ]; then 
					xmin=30
					xmax=124
					ymin=-56
					ymax=-9
					nom=Carte/CarteOceanIndien.png
				

				#Antartique
				elif [ $arg = "-Q" ]; then 
					xmin=56
					xmax=180
					ymin=-90
					ymax=-28
					nom=Carte/CarteAntartique.png
				

				#Rien
				else 
					xmin=-180
					xmax=180
					ymin=-90
					ymax=90
					nom=Carte/Carte.png
			fi
			done

			scalaire=$(echo "($xmax - $xmin)/1720" | bc -l)

			#Generation graphique via gnuplot
			echo "Création du graphique"
			echo ""
			gnuplot <<-EOFMarker
			set terminal png size 1920,1080
			set output "Vent.png"
			set title "Moyenne force et direction moyen du vent"
			set xlabel "Coord. Nord"
			set ylabel "Coord. Est"
			set datafile separator ";"
			set angles degrees
			set xrange [$xmin:$xmax]
			set yrange [$ymin:$ymax]
			plot "$nom" binary filetype=png origin=($xmin,$ymin) dx=$scalaire dy=$scalaire w rgbimage, "gnuplot.csv" using 3:2:(sin(\$4)/\$5)*$scalaire*300:(cos(\$4)/\$5)*$scalaire*300 w vec title "Direction et force moyenne du vent" lc rgbcolor "red"
			EOFMarker
			echo "Le graphique à été créer avec succés !"
			echo ""
					
	
		#L'OPTION L'ALTITUDE#
		elif [ $arg = "-h" ]; then
			cat date.csv | awk -F ";"
			awk -F';' '{ if( $14 != "" ){split($10, coord, ",") ; print $14";"coord[1]";"coord[2]} }' date.csv > arg.csv
			sort -t";" -k1 -r arg.csv > final.csv
			uniq final.csv > gnuplot.csv
			echo "0-le trie par le programe c c'est déroulé correctement"
			#Generation graphique via gnuplot
			echo "Création du graphique"
			gnuplot <<-EOFMarker
			set terminal png size 1920,1080
			set output "Altitude.png"
			set title "Altitude Station"
			set xlabel "Coord. Nord"
			set ylabel "Coord. Est"
			set datafile separator ";"
			
			set xrang [*:*] noextend
			set yrang [*:*] noextend

			set view map
			set pm3d interpolate 7,7
			set dgrid3d 60.60
			splot "gnuplot.csv" using 3:2:1 with pm3d title "Hauteur (mètre)"
			EOFMarker
			echo "Le graphique à été créer avec succés !"
			
		#L'OPTION POUR L'HUMIDITE#
		elif [ $arg = "-m" ]; then
			cat date.csv | awk -F ";"
			awk -F';' '{ if( $6 != "" ){split($10, coord, ",") ; print $1";"$6";"coord[1]";"coord[2]} }' date.csv > arg.csv
			sort -t";" -k1 -r arg.csv > final.csv	
			echo "0-le trie par le programe c c'est déroulé correctement"
			awk -F ';' 'BEGIN { num="" } { if(num!=$1){ if(num!=""){print num";"max";"x";"y} x=$3 ; y=$4 ; max=$2 ; num=$1 } if($2>max){max=$2} } END {print num";"max";"x";"y}'  final.csv > gnuplot.csv
			
			#Generation graphique via gnuplot
			echo "Création du graphique"
			echo ""
			gnuplot <<-EOFMarker
			set terminal png size 1920,1080
			set output "Humidite.png"
			set title "Humidité max Station"
			set xlabel "Coord. Nord"
			set ylabel "Coord. Est"
			set datafile separator ";"
			
			set xrang [*:*] noextend
			set yrang [*:*] noextend

			set view map
			set pm3d interpolate 7,7
			set dgrid3d 
			splot "gnuplot.csv" using 4:3:2 with pm3d title "Hauteur (mètre)"
			EOFMarker
			echo "Le graphique à été créer avec succés !"
			echo ""
		
		fi
	done
fi
