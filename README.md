# Projet-Meteo-Mathis-et-Alban

Voici notre station météo, nous vous conseillons de lire attentivement le fichier
Présentation_météo.pdf qui détaille toutes les fonctionnalités, notre organisation durant le
projet ainsi que les problèmes rencontrés et voir quelque exemple.
Voici quelques informations importante avant la première exécution.
1-ouvrir le terminal du répertoire courant (où vous avez télécharger les fichiers) et faire la
commande make afin de compiler et de créer les exécutable C.
2-Pour exécuter le code il faut écrire ./filterdata.sh suivit des arguments que voulez utiliser
(vous pouvez en mettre plusieurs) comme -t1 -t2 -p1 -p2 -h -m -w qui sont des arguments
obligatoires. Sinon vous aurez le message « vous avez commis une erreur faite –help si vous
voulez plus d’information ». Il existe aussi des arguments optionnel comme le lieu (-F, -G, -Q
etc...) ou des arguments de date <-d aaaa-mm-jj aaaa-mm-jj>. Il faut aussi indiquer le nom du
fichier d’entrer (-f meteo_filtered_data_v1.csv). Il est important de mettre l’argument lieu en
derniers.
Exemple de ligne d’exécution : ./filterdata.sh -t1 – f meteo_filtered_data_v1.csv –d 2014-01-02
2015-01-02 -F
