USE ecopilot_rse;   -- On travaille dans la base ecopilot_rse

-- R1 : Affiche tous les sites avec leur etat (actif ou inactif)
SELECT code_site AS Code,                        -- Code du site
       nom AS Site,                              -- Nom du site
       ville AS Ville,                           -- Ville du site
       IF(actif = 1, 'Actif', 'Inactif') AS Etat -- Si actif vaut 1 on ecrit Actif, sinon Inactif
FROM Site                                        -- Table qui contient les sites
ORDER BY actif DESC, nom;                        -- Actifs d'abord, puis ordre alphabetique


-- R2 : Affiche les collaborateurs du site de Lyon, tries par nom et prenom
SELECT C.nom AS Nom,                             -- Nom du collaborateur
       C.prenom AS Prenom,                       -- Prenom du collaborateur
       C.matricule AS Matricule,                 -- Matricule du collaborateur
       C.email_pro AS Email,                     -- Email professionnel
       IF(C.actif = 1, 'Actif', 'Inactif') AS Etat -- Actif ou Inactif
FROM Collaborateur C                             -- On part des collaborateurs (alias C)
JOIN Site S ON C.id_site = S.id_site             -- On relie chaque collaborateur a son site
WHERE S.code_site = 'NVT-LYO'                    -- On garde seulement le site de Lyon
ORDER BY C.nom, C.prenom;                        -- Tri par nom puis par prenom


-- R3 : Affiche les indicateurs de la famille Energie avec leur unite
SELECT F.libelle_famille AS Famille,             -- Nom de la famille
       I.code_indicateur AS Code,                -- Code de l'indicateur
       I.libelle AS Indicateur,                  -- Nom de l'indicateur
       I.unite AS Unite                          -- Unite de mesure (kWh, m3, kg...)
FROM Indicateur I                                -- On part des indicateurs (alias I)
JOIN Famille F ON I.id_famille = F.id_famille    -- On relie chaque indicateur a sa famille
WHERE F.libelle_famille = 'Énergie'              -- On garde seulement la famille Energie
ORDER BY I.code_indicateur;                      -- Tri par code


-- R4 : Affiche les releves d'electricite de Lyon entre mars et aout 2025, du plus ancien au plus recent
SELECT R.periode AS Mois,                        -- Mois du releve
       S.code_site AS Site,                      -- Site concerne
       I.code_indicateur AS Indicateur,          -- Indicateur concerne
       R.valeur_mesuree AS Valeur,               -- Valeur mesuree ce mois-la
       I.unite AS Unite,                         -- Unite de la valeur
       R.statut AS Statut                        -- Statut du releve (Valide, A valider...)
FROM Releve R                                    -- On part des releves (alias R)
JOIN Site S ON R.id_site = S.id_site             -- On relie chaque releve a son site
JOIN Indicateur I ON R.id_indicateur = I.id_indicateur -- On relie chaque releve a son indicateur
WHERE S.code_site = 'NVT-LYO'                    -- Site de Lyon
  AND I.code_indicateur = 'ELEC'                 -- Indicateur electricite
  AND R.periode BETWEEN '2025-03-01' AND '2025-08-31' -- Entre les deux dates
ORDER BY R.periode;                              -- Ordre chronologique


-- R5 : Calcule la somme, la moyenne, le minimum et le maximum de l'electricite pour chaque site en 2025
SELECT S.code_site AS Site,                      -- Site concerne
       SUM(R.valeur_mesuree) AS Somme,           -- Total des valeurs
       ROUND(AVG(R.valeur_mesuree), 2) AS Moyenne, -- Moyenne arrondie a 2 decimales
       MIN(R.valeur_mesuree) AS Minimum,         -- Plus petite valeur
       MAX(R.valeur_mesuree) AS Maximum          -- Plus grande valeur
FROM Releve R                                    -- On part des releves
JOIN Site S ON R.id_site = S.id_site             -- On relie au site
JOIN Indicateur I ON R.id_indicateur = I.id_indicateur -- On relie a l'indicateur
WHERE I.code_indicateur = 'ELEC'                 -- Electricite uniquement
  AND R.periode BETWEEN '2025-01-01' AND '2025-12-31' -- Annee 2025
GROUP BY S.code_site                             -- Un calcul par site
ORDER BY S.code_site;                            -- Tri par site


-- R6 : Affiche les actions du site de Lyon avec leur statut, leurs dates et leur responsable
SELECT A.titre AS Action,                        -- Titre de l'action
       A.statut AS Statut,                       -- Statut (Planifiee, En cours, Terminee...)
       A.date_debut_prevue AS Debut_prevu,       -- Date de debut prevue
       A.date_fin_prevue AS Fin_prevue,          -- Date de fin prevue
       A.date_fin_reelle AS Fin_reelle,          -- Date de fin reelle (vide si pas finie)
       CONCAT(C.prenom, ' ', C.nom) AS Responsable -- Prenom et nom colles ensemble
FROM `Action` A                                  -- On part des actions (alias A)
JOIN Site S ON A.id_site = S.id_site             -- On relie l'action a son site
JOIN Collaborateur C ON A.id_collaborateur = C.id_collaborateur -- On relie l'action a son responsable
WHERE S.code_site = 'NVT-LYO'                    -- Site de Lyon
ORDER BY A.date_debut_prevue;                    -- Tri par date de debut


-- R7 : Affiche les actions en cours dont la date de fin prevue est deja passee
SELECT A.titre AS Action,                        -- Titre de l'action
       S.nom AS Site,                            -- Site de l'action
       A.date_fin_prevue AS Fin_prevue,          -- Date de fin qui etait prevue
       DATEDIFF(CURDATE(), A.date_fin_prevue) AS Jours_de_retard -- Nombre de jours entre aujourd'hui et la fin prevue
FROM `Action` A                                  -- On part des actions
JOIN Site S ON A.id_site = S.id_site             -- On relie l'action a son site
WHERE A.statut = 'En cours'                      -- Action pas terminee
  AND A.date_fin_prevue < CURDATE()              -- Fin prevue avant aujourd'hui = en retard
ORDER BY Jours_de_retard DESC;                   -- Les plus en retard en premier


-- R8 : Affiche le responsable de l'action numero 4
SELECT A.titre AS Action,                        -- Titre de l'action
       CONCAT(C.prenom, ' ', C.nom) AS Responsable -- Nom complet du responsable
FROM `Action` A                                  -- On part des actions
JOIN Collaborateur C ON A.id_collaborateur = C.id_collaborateur -- On relie au responsable
WHERE A.id_action = 4;                           -- Action numero 4 uniquement

-- R8 : Affiche les participants de l'action numero 4
SELECT CONCAT(C.prenom, ' ', C.nom) AS Participant -- Nom complet du participant
FROM Mobilise M                                  -- Table qui lie actions et participants
JOIN Collaborateur C ON M.id_collaborateur = C.id_collaborateur -- On retrouve le nom du participant
WHERE M.id_action = 4                            -- Action numero 4 uniquement
ORDER BY C.nom, C.prenom;                        -- Tri par nom puis prenom


-- R9 : Compte les actions et additionne les budgets pour chaque site et chaque statut
SELECT S.nom AS Site,                            -- Nom du site
       A.statut AS Statut,                       -- Statut des actions
       COUNT(*) AS Nb_actions,                   -- Nombre d'actions du groupe
       SUM(A.budget_previsionnel) AS Budget_total -- Somme des budgets du groupe
FROM `Action` A                                  -- On part des actions
JOIN Site S ON A.id_site = S.id_site             -- On relie l'action a son site
GROUP BY S.nom, A.statut                         -- Un resultat par couple site + statut
ORDER BY S.nom, A.statut;                        -- Tri par site puis statut


-- R10 : Affiche les sites inactifs et combien de collaborateurs, releves et actions ils ont
SELECT S.nom AS Site_inactif,                    -- Nom du site inactif
       (SELECT COUNT(*) FROM Collaborateur C WHERE C.id_site = S.id_site) AS Nb_collaborateurs, -- Compte ses collaborateurs
       (SELECT COUNT(*) FROM Releve R WHERE R.id_site = S.id_site) AS Nb_releves,               -- Compte ses releves
       (SELECT COUNT(*) FROM `Action` A WHERE A.id_site = S.id_site) AS Nb_actions              -- Compte ses actions
FROM Site S                                      -- On part des sites
WHERE S.actif = 0;                               -- Seulement les sites inactifs

-- R10 : Affiche les collaborateurs inactifs et combien d'actions ils ont gerees ou suivies
SELECT CONCAT(C.prenom, ' ', C.nom) AS Collaborateur_inactif, -- Nom complet
       (SELECT COUNT(*) FROM `Action` A WHERE A.id_collaborateur = C.id_collaborateur) AS Nb_actions_responsable, -- Actions dont il est responsable
       (SELECT COUNT(*) FROM Mobilise M WHERE M.id_collaborateur = C.id_collaborateur) AS Nb_participations      -- Actions auxquelles il participe
FROM Collaborateur C                             -- On part des collaborateurs
WHERE C.actif = 0;                               -- Seulement les inactifs

-- R10 : Affiche les indicateurs inactifs et combien de releves et d'objectifs ils ont
SELECT I.libelle AS Indicateur_inactif,          -- Nom de l'indicateur inactif
       (SELECT COUNT(*) FROM Releve R WHERE R.id_indicateur = I.id_indicateur) AS Nb_releves,   -- Compte ses releves
       (SELECT COUNT(*) FROM Objectif O WHERE O.id_indicateur = I.id_indicateur) AS Nb_objectifs -- Compte ses objectifs
FROM Indicateur I                                -- On part des indicateurs
WHERE I.actif = 0;                               -- Seulement les inactifs


-- R11 : Ajoute un nouveau releve mensuel (electricite Lyon, janvier 2026)
INSERT INTO Releve (date_saisie, source, statut, periode, valeur_mesuree, id_site, id_indicateur) -- Colonnes a remplir
VALUES (CURDATE(),            -- Date de saisie = aujourd'hui
        'Facture fournisseur', -- D'ou vient la donnee
        'À valider',          -- Statut du releve
        '2026-01-01',         -- Mois concerne (toujours le 1er du mois)
        20450.00,             -- Valeur mesuree
        1,                    -- id du site (Lyon)
        1);                   -- id de l'indicateur (electricite)

-- R11 : Passe l'action 4 en "Terminée" et enregistre sa date de fin reelle
UPDATE `Action`                                  -- On modifie la table Action
SET statut = 'Terminée',                         -- Nouveau statut
    date_fin_reelle = CURDATE()                  -- Date de fin reelle = aujourd'hui
WHERE id_action = 4;                             -- Seulement l'action numero 4


-- R12 : Requete supplementaire
-- Compare le total des releves 2025 a la cible de chaque objectif (atteint ou non)
SELECT S.code_site AS Site,                      -- Site de l'objectif
       I.code_indicateur AS Indicateur,          -- Indicateur de l'objectif
       I.unite AS Unite,                         -- Unite de mesure
       O.sens_cible AS Sens,                     -- Maximum (ne pas depasser) ou Minimum (a atteindre)
       O.valeur_cible AS Cible,                  -- Valeur a respecter
       SUM(R.valeur_mesuree) AS Realise,         -- Total des releves de l'annee
       CASE                                      -- Debut du test atteint / non atteint
           WHEN O.sens_cible = 'Maximum' AND SUM(R.valeur_mesuree) <= O.valeur_cible THEN 'Atteint' -- Maximum : total <= cible
           WHEN O.sens_cible = 'Minimum' AND SUM(R.valeur_mesuree) >= O.valeur_cible THEN 'Atteint' -- Minimum : total >= cible
           ELSE 'Non atteint'                    -- Tous les autres cas
       END AS Resultat                           -- Fin du test
FROM Objectif O                                  -- On part des objectifs
JOIN Site S ON O.id_site = S.id_site             -- On relie au site
JOIN Indicateur I ON O.id_indicateur = I.id_indicateur -- On relie a l'indicateur
JOIN Releve R ON R.id_site = O.id_site           -- On relie aux releves du meme site
             AND R.id_indicateur = O.id_indicateur -- ... du meme indicateur
             AND YEAR(R.periode) = O.annee       -- ... de la meme annee que l'objectif
WHERE O.annee = 2025                             -- Objectifs de 2025
  AND R.statut <> 'Rejeté'                       -- On ignore les releves rejetes
GROUP BY O.id_objectif, S.code_site, I.code_indicateur, I.unite, O.sens_cible, O.valeur_cible -- Un resultat par objectif
ORDER BY S.code_site, I.code_indicateur;         -- Tri par site puis indicateur
