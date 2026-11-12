use ecopilot_rse;

DROP USER IF EXISTS 'UtilisateurC'@'localhost';
DROP USER IF EXISTS 'UtilisateurG'@'localhost';


CREATE USER 'UtilisateurC'@'localhost' IDENTIFIED BY '1234';
GRANT SELECT ON ecopilot_rse.* TO 'UtilisateurC'@'localhost';

CREATE USER 'UtilisateurG'@'localhost' identified by '1234';
GRANT SELECT ON ecopilot_rse.* TO 'UtilisateurG'@'localhost';
GRANT INSERT ON ecopilot_rse.Releve TO 'UtilisateurG'@'localhost';
GRANT UPDATE ON ecopilot_rse.`Action` TO 'UtilisateurG'@'localhost';

/* choix pour l'utilisateur Gestion :

on utilise pas le grant all car l'utilisateur aurait trop de permission (supprimer des données ou des tables)
donc on lui aloue seulement le strict nécéssaire pour la gestion c'est a dire SELECT INSERT UPDATE
*/

SHOW GRANTS FOR 'UtilisateurC'@'localhost';
SHOW GRANTS FOR 'UtilisateurG'@'localhost';