# Démonstration de traitement SIG: raccrocher des code de cours d'eau à des ouvrages ponctuels, en exploitant QGIS et une base de données spatiale

Exemple de traitement de données spatiale fréquent, de raccrochement attributaire de points à des cours d'eau.


##Coté technique,
ce projet permet de comprendre comment exploiter efficacement des bases spatiales (sqlite ou postgis) en association avec QGIS. 
Les requêtes SQL, la base SQLITE et le projet QGIS sont fournis pour reproduire l'exercice. 

##Coté métier, raccrocher attributairement des ouvrages à des cours d'eau est nécessaire pour toute intégration dans un système d'information. 

Cet exercice est piégeux du fait des risque d'erreurs de raccrochement en cas de bras, confluence ou autre. 
L'exemple de traitement permet de :
	  1- calculer les cours d'eau les plus proches dans un rayon de 200 mètres, et d'en faire une couche de visualisation cartographique
	  2- affecter automatiquement les codes cours d'eau pour les ouvrages n'ayant qu'un seul cours d'eau à proximité
	  3- Editer manuellement les relations restantes pour arbitrer quel code affecter. 
	  4- lancer une mise à jour de la table de point à partir de cette table de relations.
	  
**[Voir la vidéo](https://github.com/haubourg/demo_calcul_cours_eau_qgis_sgbd_spatial/blob/master/Demo_calcul_cours_eau.mp4)**
	  
*Note 1 : Les données de cours d'eau et de points doivent être dans la même base spatiale. Depuis QGIS, un glisser déplacer depuis l'onglet "parcouri" vers la base permet de réaliser ce chargement simplement.* 

*Note 2 : Il est très simple de raffiner la technique en ajoutant des règles de priorité autres que la distance (longueur, débit, filtre selon la nature du cours d'eau) pour un raccrochement automatique plus pertinent*
	
	  
Auteur : Régis Haubourg - Agence de l'eau Adour Garonne	  
	  
