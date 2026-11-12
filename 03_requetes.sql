USE ecopilot_rse;

-- R1 : Affiche tous les sites avec leur etat (actif ou inactif)
SELECT code_site AS Code,
       nom AS Site,
       ville AS Ville,
       IF(actif = 1, 'Actif', 'Inactif') AS Etat
FROM Site
ORDER BY actif DESC, nom;

-- R2 : Affiche les collaborateurs du site de Lyon, tries par nom et prenom
SELECT C.nom AS Nom,
       C.prenom AS Prenom,
       C.matricule AS Matricule,
       C.email_pro AS Email,
       IF(C.actif = 1, 'Actif', 'Inactif') AS Etat
FROM Collaborateur C
JOIN Site S ON C.id_site = S.id_site
WHERE S.code_site = 'NVT-LYO'
ORDER BY C.nom, C.prenom;

-- R3 : Affiche les indicateurs de la famille Energie avec leur unite
SELECT F.libelle_famille AS Famille,
       I.code_indicateur AS Code,
       I.libelle AS Indicateur,
       I.unite AS Unite
FROM Indicateur I
JOIN Famille F ON I.id_famille = F.id_famille
WHERE F.libelle_famille = 'Énergie'
ORDER BY I.code_indicateur;

-- R4 : Affiche les releves d'electricite de Lyon entre mars et aout 2025, du plus ancien au plus recent
SELECT R.periode AS Mois,
       S.code_site AS Site,
       I.code_indicateur AS Indicateur,
       R.valeur_mesuree AS Valeur,
       I.unite AS Unite,
       R.statut AS Statut
FROM Releve R
JOIN Site S ON R.id_site = S.id_site
JOIN Indicateur I ON R.id_indicateur = I.id_indicateur
WHERE S.code_site = 'NVT-LYO'
  AND I.code_indicateur = 'ELEC'
  AND R.periode BETWEEN '2025-03-01' AND '2025-08-31'
ORDER BY R.periode;

-- R5 : Calcule la somme, la moyenne, le minimum et le maximum de l'electricite pour chaque site en 2025
SELECT S.code_site AS Site,
       SUM(R.valeur_mesuree) AS Somme,
       ROUND(AVG(R.valeur_mesuree), 2) AS Moyenne,
       MIN(R.valeur_mesuree) AS Minimum,
       MAX(R.valeur_mesuree) AS Maximum
FROM Releve R
JOIN Site S ON R.id_site = S.id_site
JOIN Indicateur I ON R.id_indicateur = I.id_indicateur
WHERE I.code_indicateur = 'ELEC'
  AND R.periode BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY S.code_site
ORDER BY S.code_site;

-- R6 : Affiche les actions du site de Lyon avec leur statut, leurs dates et leur responsable
SELECT A.titre AS Action,
       A.statut AS Statut,
       A.date_debut_prevue AS Debut_prevu,
       A.date_fin_prevue AS Fin_prevue,
       A.date_fin_reelle AS Fin_reelle,
       CONCAT(C.prenom, ' ', C.nom) AS Responsable
FROM `Action` A
JOIN Site S ON A.id_site = S.id_site
JOIN Collaborateur C ON A.id_collaborateur = C.id_collaborateur
WHERE S.code_site = 'NVT-LYO'
ORDER BY A.date_debut_prevue;

-- R7 : Affiche les actions en cours dont la date de fin prevue est deja passee
SELECT A.titre AS Action,
       S.nom AS Site,
       A.date_fin_prevue AS Fin_prevue,
       DATEDIFF(CURDATE(), A.date_fin_prevue) AS Jours_de_retard
FROM `Action` A
JOIN Site S ON A.id_site = S.id_site
WHERE A.statut = 'En cours'
  AND A.date_fin_prevue < CURDATE()
ORDER BY Jours_de_retard DESC;

-- R8 : Affiche le responsable de l'action numero 4
SELECT A.titre AS Action,
       CONCAT(C.prenom, ' ', C.nom) AS Responsable
FROM `Action` A
JOIN Collaborateur C ON A.id_collaborateur = C.id_collaborateur
WHERE A.id_action = 4;

-- R8 : Affiche les participants de l'action numero 4
SELECT CONCAT(C.prenom, ' ', C.nom) AS Participant
FROM Mobilise M
JOIN Collaborateur C ON M.id_collaborateur = C.id_collaborateur
WHERE M.id_action = 4
ORDER BY C.nom, C.prenom;

-- R9 : Compte les actions et additionne les budgets pour chaque site et chaque statut
SELECT S.nom AS Site,
       A.statut AS Statut,
       COUNT(*) AS Nb_actions,
       SUM(A.budget_previsionnel) AS Budget_total
FROM `Action` A
JOIN Site S ON A.id_site = S.id_site
GROUP BY S.nom, A.statut
ORDER BY S.nom, A.statut;

-- R10 : Affiche les sites inactifs et combien de collaborateurs, releves et actions ils ont
SELECT S.nom AS Site_inactif,
       (SELECT COUNT(*) FROM Collaborateur C WHERE C.id_site = S.id_site) AS Nb_collaborateurs,
       (SELECT COUNT(*) FROM Releve R WHERE R.id_site = S.id_site) AS Nb_releves,
       (SELECT COUNT(*) FROM `Action` A WHERE A.id_site = S.id_site) AS Nb_actions
FROM Site S
WHERE S.actif = 0;

-- R10 : Affiche les collaborateurs inactifs et combien d'actions ils ont gerees ou suivies
SELECT CONCAT(C.prenom, ' ', C.nom) AS Collaborateur_inactif,
       (SELECT COUNT(*) FROM `Action` A WHERE A.id_collaborateur = C.id_collaborateur) AS Nb_actions_responsable,
       (SELECT COUNT(*) FROM Mobilise M WHERE M.id_collaborateur = C.id_collaborateur) AS Nb_participations
FROM Collaborateur C
WHERE C.actif = 0;

-- R10 : Affiche les indicateurs inactifs et combien de releves et d'objectifs ils ont
SELECT I.libelle AS Indicateur_inactif,
       (SELECT COUNT(*) FROM Releve R WHERE R.id_indicateur = I.id_indicateur) AS Nb_releves,
       (SELECT COUNT(*) FROM Objectif O WHERE O.id_indicateur = I.id_indicateur) AS Nb_objectifs
FROM Indicateur I
WHERE I.actif = 0;

-- R11 : Ajoute un nouveau releve mensuel (electricite Lyon, janvier 2026)
INSERT INTO Releve (date_saisie, source, statut, periode, valeur_mesuree, id_site, id_indicateur)
VALUES (CURDATE(),
        'Facture fournisseur',
        'À valider',
        '2026-01-01',
        20450.00,
        1,
        1);

-- R11 : Passe l'action 4 en "Terminée" et enregistre sa date de fin reelle
UPDATE `Action`
SET statut = 'Terminée',
    date_fin_reelle = CURDATE()
WHERE id_action = 4;

-- R12 : Requete supplementaire
-- Compare le total des releves 2025 a la cible de chaque objectif (atteint ou non)
SELECT S.code_site AS Site,
       I.code_indicateur AS Indicateur,
       I.unite AS Unite,
       O.sens_cible AS Sens,
       O.valeur_cible AS Cible,
       SUM(R.valeur_mesuree) AS Realise,
       CASE
           WHEN O.sens_cible = 'Maximum' AND SUM(R.valeur_mesuree) <= O.valeur_cible THEN 'Atteint'
           WHEN O.sens_cible = 'Minimum' AND SUM(R.valeur_mesuree) >= O.valeur_cible THEN 'Atteint'
           ELSE 'Non atteint'
       END AS Resultat
FROM Objectif O
JOIN Site S ON O.id_site = S.id_site
JOIN Indicateur I ON O.id_indicateur = I.id_indicateur
JOIN Releve R ON R.id_site = O.id_site
             AND R.id_indicateur = O.id_indicateur
             AND YEAR(R.periode) = O.annee
WHERE O.annee = 2025
  AND R.statut <> 'Rejeté'
GROUP BY O.id_objectif, S.code_site, I.code_indicateur, I.unite, O.sens_cible, O.valeur_cible
ORDER BY S.code_site, I.code_indicateur;
