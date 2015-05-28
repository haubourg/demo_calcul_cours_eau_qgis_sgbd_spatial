-- Objectif: raccrocher des points au cours d'eau le plus proche, en automatique lorsqu'il n'y a aucune incertitude, avec visualisation sinon/

-- Outils: QGIS pour la visualisation, sqlite pour le traitement spatial et les requêtes. Postgres est encore plus simple, les fonctions d'agrégation étant plus puissante (window functions et Select distinct ON )

--- chargement des données dans la base SQLITE (DBmanager / Qgspatialite / FME ... )
--définition des tables de travail
CREATE TABLE "cours_eau" ( PKUID INTEGER PRIMARY KEY AUTOINCREMENT , Geometry MULTILINESTRING, "code_cours_eau" TEXT(8) , "toponyme" TEXT(127) , "candidat" TEXT(127) , "classification" TEXT(1) , "code_milieu" TEXT(1) , "code_bassin" TEXT(2) , "oid" INTEGER  );




CREATE TABLE "points" ( PKUID INTEGER PRIMARY KEY AUTOINCREMENT , Geometry MULTIPOINT, "id_point" TEXT(254) , "nom" TEXT(254) , "cd_com" TEXT(254) , "nom_comm" TEXT(254) , "x_l93" REAL , "y_l93" REAL , "altitude" TEXT(254) , "pk" TEXT(254) , "cd_coureau" TEXT(8) , "cd_masso" TEXT(254) , "cd_zh" TEXT(254) , "cd_tr_cart" TEXT(254) , "cd_tr_topo" TEXT(254)  );



CREATE TABLE paires( id_paire INTEGER PRIMARY KEY AUTOINCREMENT, 
  id_point TEXT,
  code_cours_eau_proche TEXT,
  distance_cours_eau_m
) ;

SELECT AddGeometryColumn('paires', 'Geometry',   2154, 'LINESTRING', 'XY');

CREATE TABLE "paires_plus_proches" (id_pp integer primary key autoincrement, "p.id_point" , "id_paire_proche" INTEGER , "nb_paires" INTEGER );





-- les cours d'eau sont identifiés par le champ "code_cours_eau", les points par "id_point"
--nettoyage des codes existants
update points set  'cd_coureau' = null

-- création des paires dans un rayon de 500 mètres, pour les points sans code cours d'eau
DELETE FROM paires;
VACUUM; 
INSERT INTO paires ( id_point ,  code_cours_eau_proche , distance_cours_eau_m,  Geometry)
SELECT "points".'id_point', 
"cours_eau".'code_cours_eau' code_cours_eau_proche, Distance("points".'Geometry' ,  "cours_eau".'Geometry') as distance_cours_eau_m, 
 ST_ShortestLine("points".'Geometry', "cours_eau".'Geometry' ) Geometry 
FROM "points", "cours_eau"
WHERE Distance("points".'Geometry' ,  "cours_eau".'Geometry') < 500 AND points.cd_coureau IS NULL
ORDER BY "points".'id_point', distance_cours_eau_m
;

--- récupération des points les plus proches et nombre de cours d'eau possibles par point
--création de table attributaire des relations les plus proches pour chaque point

SELECT  p.id_point , min("p".'id_paire') id_paire_proche , count(*) nb_paires from 
(
SELECT  "paires".'id_paire' ,  "paires".'id_point' ,  "paires".'code_cours_eau_proche'  , "paires".'distance_cours_eau_m'
FROM  "paires" 
ORDER BY "paires".'id_point' ,"paires".'distance_cours_eau_m' asc
) p
GROUP BY  "p".'id_point'  ;

-- spatialisation par jointure sur la table des relations de départ +


-- affectation des code cours d'eau uniquement pour les paires les plus proches sans incertitude (sans doublon)- Attention, syntaxe SQLite complexe, plus simple pour les autres bases

UPDATE points  SET 'cd_coureau'  = (SELECT paires_plus_proches.code_cours_eau_proche 
                            FROM (   Select   p.id_point, p.code_cours_eau_proche  FROM paires p JOIN  ( SELECT  p.id_point , min("p".'id_paire') id_paire_proche , count(*) nb_paires from 
( SELECT  "paires".'id_paire' ,  "paires".'id_point' ,  "paires".'code_cours_eau_proche'  , "paires".'distance_cours_eau_m'
FROM  "paires"  ORDER BY "paires".'id_point' ,"paires".'distance_cours_eau_m' asc ) p  GROUP BY  "p".'id_point'   HAVING count(*) = 1  )   pp ON  (p.id_paire = pp.id_paire_proche)  ) paires_plus_proches
                            WHERE paires_plus_proches.id_point = points.id_point and points.cd_coureau is null)
WHERE
    EXISTS (
        SELECT *
        FROM (  Select   p.id_point, p.code_cours_eau_proche  FROM paires p JOIN  ( SELECT  p.id_point , min("p".'id_paire') id_paire_proche , count(*) nb_paires from 
( SELECT  "paires".'id_paire' ,  "paires".'id_point' ,  "paires".'code_cours_eau_proche'  , "paires".'distance_cours_eau_m'
FROM  "paires"  ORDER BY "paires".'id_point' ,"paires".'distance_cours_eau_m' asc ) p  GROUP BY  "p".'id_point'   HAVING count(*) = 1  )   pp ON  (p.id_paire = pp.id_paire_proche) ) paires_plus_proches
        WHERE paires_plus_proches.id_point = points.id_point and points.cd_coureau is null) ; 

-- visualisation QGIS pour les points non affectés et suppression des paires à ne pas garder 
-- reprendre le processus précédent en boucle.. 
-- version avec table en dur