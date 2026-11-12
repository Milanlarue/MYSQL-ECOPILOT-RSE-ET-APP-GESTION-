EcoPilot RSE

Base de données MySQL et application console C# pour suivre la performance environnementale d'une entreprise fictive multi-sites : énergie, eau, déchets et mobilité.

Fonctionnalités
Relevés mensuels par site et par indicateur, classés en quatre familles
Objectifs annuels (maximum ou minimum) comparés à la somme des relevés
Actions RSE avec responsable, participants, statut et suivi des retards
Sites, collaborateurs et indicateurs désactivés plutôt que supprimés, pour garder l'historique
Application console avec deux profils : consultation et gestionnaire

Contenu du dépôt
01_creation.sql : création de la base ecopilot_rse (8 tables et leurs contraintes) et jeu de données fictif
01_utilisateurs.sql : deux comptes MySQL aux droits différents
03_requetes.sql : requêtes SQL de pilotage (R1 à R12)
APP-C#-Projet/ et APP-C#-Projet.sln : solution Visual Studio de l'application console
PDF avec toutes les demonstrations des tests

Installation
Prérequis : MySQL 8.0.16 ou plus récent (pour les contraintes CHECK), MySQL Workbench et Visual Studio.
Dans Workbench, avec le compte root, exécuter dans cet ordre 01_creation.sql puis 01_utilisateurs.sql.
Ouvrir APP-C#-Projet.sln dans Visual Studio. Le package NuGet MySql.Data est restauré automatiquement. Lancer avec Ctrl+F5.

Comptes de test
Consultation : UtilisateurC / 1234, lecture seule.
Gestionnaire : UtilisateurG / 1234, lecture, ajout de relevés et modification des actions.

Ce sont des mots de passe de démonstration, pour une base locale.

Utilisation

Le menu de départ propose : 1 consultation, 2 gestionnaire, 0 quitter. Le choix détermine le compte MySQL utilisé, et le mot de passe est demandé.

Consultation : dix requêtes de lecture (sites, collaborateurs, indicateurs, relevés, statistiques, actions, retards, participants, budgets, éléments inactifs).
Gestionnaire : les mêmes requêtes, plus l'enregistrement d'un relevé de test (choix 11) et la clôture d'une action de test (choix 12).
