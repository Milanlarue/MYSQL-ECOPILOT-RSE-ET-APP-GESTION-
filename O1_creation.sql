DROP DATABASE IF EXISTS ecopilot_rse;
CREATE DATABASE ecopilot_rse ;
 USE ecopilot_rse;
CREATE TABLE Famille (
id_famille int not null auto_increment,
 libelle_famille varchar(100) not null,
 PRIMARY KEY (id_famille),
 UNIQUE (libelle_famille)
 );
CREATE TABLE Site (
id_site int not null auto_increment,
 code_site varchar(100) not null ,
 nom varchar(100) not null,
 adresse varchar(100) not null,
 ville varchar(100) not null,
 code_postal varchar(100) not null,
 date_ouverture date not null,
 surface_m2 decimal(10,2) not null,
 actif bool not null,
 PRIMARY KEY (id_site),
 UNIQUE (code_site),
 CHECK(surface_m2>0)
 );
CREATE TABLE Collaborateur(
id_collaborateur int not null auto_increment,
 matricule varchar(100) not null,
 nom varchar(100) not null,
 prenom varchar(100) not null,
 email_pro varchar(100) not null,
 date_embauche date not null,
 actif bool not null,
 id_site int not null,
 PRIMARY KEY (id_collaborateur),
 foreign key (id_site) REFERENCES Site (id_site) ON DELETE RESTRICT ON UPDATE CASCADE,
 UNIQUE(matricule),
 UNIQUE(email_pro)
 );
CREATE TABLE Indicateur (
id_indicateur int not null AUTO_increment,
 code_indicateur varchar(100) not null,
 libelle varchar(100) not null,
 unite varchar(100) not null,
 actif bool not null,
 id_famille int not null,
 PRIMARY KEY (id_indicateur),
 foreign key (id_famille) references Famille(id_famille) ON DELETE RESTRICT ON UPDATE CASCADE,
 UNIQUE(code_indicateur)
 
 );
CREATE TABLE Releve (
id_releve int not null auto_increment,
 date_saisie date not null,
 source varchar(100) not null,
 statut varchar(100) not null,
 periode date not null,
 valeur_mesuree decimal(10,2) not null,
 id_site int not null,
 id_indicateur int not null,
 PRIMARY KEY (id_releve),
 foreign key (id_site) references Site (id_site) ON DELETE RESTRICT ON UPDATE CASCADE,
 foreign key (id_indicateur) references Indicateur(id_indicateur) ON DELETE RESTRICT ON UPDATE CASCADE,
 UNIQUE(id_site,id_indicateur,periode),
 CHECK(valeur_mesuree>=0),
 CHECK(statut IN ('À valider','Validé','Rejeté')),
 CHECK(DAY(periode)=1)
 );
CREATE TABLE Objectif (
id_objectif int not null auto_increment,
 annee int not null,
 sens_cible varchar(100) not null,
 valeur_cible decimal(10,2) not null,
 commentaire varchar(1000),
 id_site int not null,
 id_indicateur int not null,
 PRIMARY KEY(id_objectif),
 foreign key (id_site) references Site (id_site) ON DELETE RESTRICT ON UPDATE CASCADE,
 foreign key (id_indicateur) references Indicateur(id_indicateur) ON DELETE RESTRICT ON UPDATE CASCADE,
 UNIQUE(id_site,id_indicateur,annee),
 CHECK(valeur_cible>=0),
 CHECK(sens_cible IN('Maximum','Minimum'))
 );
CREATE TABLE Action (
id_action int not null auto_increment,
titre varchar(100) not null,
 description varchar(100) not null,
 theme varchar(100) not null,
 date_debut_prevue date not null,
 date_fin_prevue date not null,
 statut varchar(100) not null,
 budget_previsionnel decimal(10,2) not null,
 date_fin_reelle date,
 id_site int not null,
 id_collaborateur int not null,
 PRIMARY KEY (id_action) ,
 FOREIGN KEY (id_site) REFERENCES Site (id_site) ON DELETE RESTRICT ON UPDATE CASCADE,
 foreign key (id_collaborateur) REFERENCES Collaborateur (id_collaborateur) ON DELETE RESTRICT ON UPDATE CASCADE,
 CHECK (statut IN ('Proposée', 'Planifiée', 'En cours', 'Suspendue', 'Terminée', 'Annulée')),
 CHECK(date_fin_prevue >= date_debut_prevue),
 CHECK(statut<> 'Terminée' OR date_fin_reelle IS NOT NULL),
 CHECK(budget_previsionnel >= 0)
 
 );
CREATE TABLE Mobilise (
id_action int not null auto_increment,
id_collaborateur int not null,
 PRIMARY KEY (id_action,id_collaborateur) ,
 FOREIGN KEY (id_action) REFERENCES Action (id_action) ON DELETE RESTRICT ON UPDATE CASCADE,
 foreign key (id_collaborateur) REFERENCES Collaborateur (id_collaborateur) ON DELETE RESTRICT ON UPDATE CASCADE
 );
 
 
 
 /*Replissage IA*/
INSERT INTO Famille (id_famille, libelle_famille) VALUES
(1, 'Énergie'),
(2, 'Eau'),
(3, 'Déchets'),
(4, 'Mobilité');
 
INSERT INTO Site (id_site, code_site, nom, adresse, ville, code_postal, date_ouverture, surface_m2, actif) VALUES
(1, 'NVT-LYO', 'Agence Lyon Est',          '18 rue des Glycines',   'Lyon',            '69003', '2014-03-03', 1850.00, 1),
(2, 'NVT-NAN', 'Site Nantes Atlantique',   '5 allée des Cormorans', 'Nantes',          '44200', '2016-09-12', 2400.00, 1),
(3, 'NVT-BOU', 'Entrepôt Bourg-en-Bresse', '42 avenue des Saules',  'Bourg-en-Bresse', '01000', '2019-05-20', 5200.00, 1),
(4, 'NVT-LIL', 'Bureau Lille Centre',      '7 rue des Mésanges',    'Lille',           '59000', '2012-01-09',  780.00, 0);
 

INSERT INTO Collaborateur (id_collaborateur, matricule, nom, prenom, email_pro, date_embauche, actif, id_site) VALUES
( 1, 'NVT0001', 'Delorme',   'Anaïs',    'anais.delorme@exemple.fr',    '2015-04-13', 1, 1),
( 2, 'NVT0002', 'Fabre',     'Julien',   'julien.fabre@exemple.fr',     '2017-09-04', 1, 1),
( 3, 'NVT0003', 'Marchetti', 'Inès',     'ines.marchetti@exemple.fr',   '2019-02-18', 1, 1),
( 4, 'NVT0004', 'Gauthier',  'Romain',   'romain.gauthier@exemple.fr',  '2014-06-02', 0, 1),
( 5, 'NVT0005', 'Lemaire',   'Sofiane',  'sofiane.lemaire@exemple.fr',  '2021-01-11', 1, 1),
( 6, 'NVT0006', 'Perrin',    'Clémence', 'clemence.perrin@exemple.fr',  '2016-10-03', 1, 2),
( 7, 'NVT0007', 'Bastide',   'Hugo',     'hugo.bastide@exemple.fr',     '2018-03-19', 1, 2),
( 8, 'NVT0008', 'Ndiaye',    'Awa',      'awa.ndiaye@exemple.fr',       '2020-07-06', 1, 2),
( 9, 'NVT0009', 'Caron',     'Mathis',   'mathis.caron@exemple.fr',     '2022-09-01', 1, 2),
(10, 'NVT0010', 'Lefort',    'Océane',   'oceane.lefort@exemple.fr',    '2017-01-23', 0, 2),
(11, 'NVT0011', 'Vidal',     'Théo',     'theo.vidal@exemple.fr',       '2019-06-10', 1, 3),
(12, 'NVT0012', 'Morel',     'Lucie',    'lucie.morel@exemple.fr',      '2020-02-03', 1, 3),
(13, 'NVT0013', 'Benali',    'Yanis',    'yanis.benali@exemple.fr',     '2021-11-15', 1, 3),
(14, 'NVT0014', 'Roussel',   'Manon',    'manon.roussel@exemple.fr',    '2023-04-03', 1, 3),
(15, 'NVT0015', 'Guérin',    'Paul',     'paul.guerin@exemple.fr',      '2012-03-05', 0, 4),
(16, 'NVT0016', 'Lambert',   'Élise',    'elise.lambert@exemple.fr',    '2013-09-16', 0, 4);
 

INSERT INTO Indicateur (id_indicateur, code_indicateur, libelle, unite, actif, id_famille) VALUES
(1, 'ELEC', 'Électricité consommée',            'kWh', 1, 1),
(2, 'GAZ',  'Gaz naturel consommé',             'kWh', 1, 1),
(3, 'PV',   'Électricité photovoltaïque produite','kWh', 1, 1),
(4, 'EAU',  'Eau consommée',                    'm³',  1, 2),
(5, 'DND',  'Déchets non recyclés',             'kg',  1, 3),
(6, 'DREC', 'Déchets recyclés',                 'kg',  1, 3),
(7, 'VOIT', 'Déplacements professionnels en voiture', 'km', 1, 4),
(8, 'DOUX', 'Trajets domicile-travail en mobilité douce', 'km', 1, 4);
 
INSERT INTO Releve (id_releve, date_saisie, source, statut, periode, valeur_mesuree, id_site, id_indicateur)
WITH RECURSIVE
mois AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM mois WHERE n < 12
),
base AS (   -- consommation mensuelle moyenne par site et indicateur
              SELECT 'NVT-LYO' AS code_site, 'ELEC' AS code_ind, 21000 AS base_mois
    UNION ALL SELECT 'NVT-LYO', 'GAZ',  14000
    UNION ALL SELECT 'NVT-LYO', 'PV',    2500
    UNION ALL SELECT 'NVT-LYO', 'EAU',     95
    UNION ALL SELECT 'NVT-LYO', 'DND',    900
    UNION ALL SELECT 'NVT-LYO', 'DREC',  1300
    UNION ALL SELECT 'NVT-LYO', 'VOIT',  6500
    UNION ALL SELECT 'NVT-LYO', 'DOUX',  3200
    UNION ALL SELECT 'NVT-NAN', 'ELEC', 27000
    UNION ALL SELECT 'NVT-NAN', 'GAZ',  18000
    UNION ALL SELECT 'NVT-NAN', 'PV',    4200
    UNION ALL SELECT 'NVT-NAN', 'EAU',    130
    UNION ALL SELECT 'NVT-NAN', 'DND',   1400
    UNION ALL SELECT 'NVT-NAN', 'DREC',  1600
    UNION ALL SELECT 'NVT-NAN', 'VOIT',  9200
    UNION ALL SELECT 'NVT-NAN', 'DOUX',  4100
    UNION ALL SELECT 'NVT-BOU', 'ELEC', 48000
    UNION ALL SELECT 'NVT-BOU', 'GAZ',  26000
    UNION ALL SELECT 'NVT-BOU', 'PV',    9500
    UNION ALL SELECT 'NVT-BOU', 'EAU',    210
    UNION ALL SELECT 'NVT-BOU', 'DND',   3800
    UNION ALL SELECT 'NVT-BOU', 'DREC',  5200
    UNION ALL SELECT 'NVT-BOU', 'VOIT', 15500
    UNION ALL SELECT 'NVT-BOU', 'DOUX',  1500
),
profil AS (  -- amplitude > 0 : pic en hiver ; < 0 : pic en été
              SELECT 'ELEC' AS code_ind,  0.12 AS amplitude, 1.0 AS coef_aout, 'Facture fournisseur'   AS source
    UNION ALL SELECT 'GAZ',   0.55, 1.0, 'Facture fournisseur'
    UNION ALL SELECT 'PV',   -0.45, 1.0, 'Télémétrie onduleur'
    UNION ALL SELECT 'EAU',  -0.15, 1.0, 'Relevé compteur'
    UNION ALL SELECT 'DND',   0.00, 1.0, 'Bordereau prestataire'
    UNION ALL SELECT 'DREC',  0.00, 1.0, 'Bordereau prestataire'
    UNION ALL SELECT 'VOIT',  0.00, 0.6, 'Notes de frais'
    UNION ALL SELECT 'DOUX', -0.20, 0.6, 'Enquête mobilité'
)
SELECT
    ROW_NUMBER() OVER (ORDER BY s.id_site, i.id_indicateur, m.n)              AS id_releve,
    DATE_ADD(LAST_DAY(DATE_ADD('2025-01-01', INTERVAL m.n - 1 MONTH)),
             INTERVAL 2 + (s.id_site + i.id_indicateur + m.n) % 8 DAY)         AS date_saisie,
    p.source,
    CASE
        WHEN m.n = 12                                           THEN 'À valider'
        WHEN (s.id_site * 7 + i.id_indicateur * 3 + m.n) % 29 = 0 THEN 'Rejeté'
        ELSE 'Validé'
    END                                                                       AS statut,
    DATE_ADD('2025-01-01', INTERVAL m.n - 1 MONTH)                            AS periode,
    ROUND(
        b.base_mois
        * (1 + p.amplitude * COS(2 * PI() * (m.n - 1) / 12))
        * (CASE WHEN m.n = 8 THEN p.coef_aout ELSE 1 END)
        * (1 + 0.04 * SIN(m.n * 1.7 + s.id_site * 2.3 + i.id_indicateur * 0.9)),
        CASE WHEN i.code_indicateur = 'EAU' THEN 1 ELSE 0 END
    )                                                                         AS valeur_mesuree,
    s.id_site,
    i.id_indicateur
FROM mois m
CROSS JOIN Site s
CROSS JOIN Indicateur i
JOIN base   b ON b.code_site = s.code_site AND b.code_ind = i.code_indicateur
JOIN profil p ON p.code_ind  = i.code_indicateur
WHERE s.actif = 1
  AND i.actif = 1;
 
INSERT INTO Objectif (id_objectif, annee, sens_cible, valeur_cible, commentaire, id_site, id_indicateur) VALUES
( 1, 2025, 'Maximum', 240000.00, 'Baisse de 5 % visée par rapport à 2024',            1, 1),  -- Lyon ELEC : dépassé
( 2, 2025, 'Maximum',   1200.00, 'Plafond fixé après la pose des mousseurs',          1, 4),  -- Lyon EAU : respecté
( 3, 2025, 'Minimum',  13500.00, 'Volume recyclé attendu avec le tri renforcé',       1, 6),  -- Lyon DREC : atteint
( 4, 2025, 'Minimum',  40000.00, 'Objectif du plan vélo de l''agence',                1, 8),  -- Lyon DOUX : non atteint
( 5, 2025, 'Maximum', 220000.00, 'Plafond de consommation pour le chauffage',         2, 2),  -- Nantes GAZ : respecté
( 6, 2025, 'Maximum', 335000.00, NULL,                                                2, 1),  -- Nantes ELEC : respecté
( 7, 2025, 'Maximum', 100000.00, 'Réduction des déplacements au profit de la visio',  2, 7),  -- Nantes VOIT : dépassé
( 8, 2025, 'Minimum',  42000.00, 'Production minimale annoncée par l''installateur',  2, 3),  -- Nantes PV : atteint
( 9, 2025, 'Maximum', 510000.00, 'Baisse de 8 % visée malgré la hausse d''activité',  3, 1),  -- Bourg ELEC : dépassé
(10, 2025, 'Maximum',  42000.00, NULL,                                                3, 5),  -- Bourg DND : dépassé
(11, 2025, 'Minimum',  66000.00, 'Volume visé par le contrat de valorisation',        3, 6),  -- Bourg DREC : non atteint
(12, 2025, 'Maximum',   2650.00, 'Plafond inscrit au plan de sobriété hydrique',      3, 4);  -- Bourg EAU : respecté
 

INSERT INTO `Action` (id_action, titre, description, theme, date_debut_prevue, date_fin_prevue, statut, budget_previsionnel, date_fin_reelle, id_site, id_collaborateur) VALUES
( 1, 'Relamping LED des bureaux',
     'Remplacement des tubes fluorescents par des luminaires LED avec détection de présence.',
     'Énergie',        '2025-02-03', '2025-06-30', 'Terminée',   38000.00, '2025-07-11', 1,  2),
( 2, 'Mousseurs sur les robinets',
     'Pose de mousseurs et de chasses double débit dans les sanitaires.',
     'Eau',            '2025-04-01', '2025-05-15', 'Terminée',    2500.00, '2025-05-12', 1,  3),
( 3, 'Tri à la source des biodéchets',
     'Mise en place de bacs de tri et d''une collecte des biodéchets par un prestataire local.',
     'Déchets',        '2025-03-03', '2025-09-30', 'Terminée',    9500.00, '2025-09-26', 3, 12),
( 4, 'Plan de mobilité employeur',
     'Diagnostic des trajets domicile-travail et plan d''actions pour réduire l''usage de la voiture.',
     'Mobilité',       '2025-09-01', '2026-06-30', 'En cours',   15000.00, NULL,         2,  7),
( 5, 'Pompe à chaleur en remplacement de la chaudière',
     'Remplacement de la chaudière gaz du bâtiment principal par une pompe à chaleur air-eau.',
     'Énergie',        '2026-01-12', '2026-09-30', 'En cours',  145000.00, NULL,         2,  6),
( 6, 'Récupération des eaux de pluie',
     'Installation d''une cuve de récupération pour l''arrosage et le lavage des quais.',
     'Eau',            '2026-03-02', '2027-04-30', 'En cours',   42000.00, NULL,         3, 11),
( 7, 'Extension de la centrale photovoltaïque',
     'Ajout de panneaux en toiture de l''entrepôt pour augmenter l''autoconsommation.',
     'Énergie',        '2026-04-01', '2026-08-31', 'Planifiée', 210000.00, NULL,         3, 13),
( 8, 'Ateliers éco-gestes',
     'Cycle d''ateliers de sensibilisation aux économies d''énergie et d''eau pour les équipes.',
     'Sensibilisation','2027-01-11', '2027-03-26', 'Planifiée',   3000.00, NULL,         1,  1),
( 9, 'Flotte de vélos à assistance électrique',
     'Mise à disposition de vélos électriques en libre-service pour les trajets courts.',
     'Mobilité',       '2027-02-01', '2027-06-30', 'Proposée',   24000.00, NULL,         1,  5),
(10, 'Compactage des cartons d''emballage',
     'Achat d''un compacteur pour réduire le volume des cartons et le nombre d''enlèvements.',
     'Déchets',        '2025-10-06', '2026-02-27', 'Suspendue',  18000.00, NULL,         3, 14),
(11, 'Audit énergétique des bâtiments',
     'Audit réglementaire par un bureau d''études pour prioriser les travaux de rénovation.',
     'Énergie',        '2026-09-07', '2027-01-29', 'Suspendue',  12000.00, NULL,         2,  8),
(12, 'Covoiturage inter-sites',
     'Plateforme de covoiturage entre les sites pour les réunions et formations.',
     'Mobilité',       '2025-05-05', '2025-12-19', 'Annulée',     6000.00, NULL,         2,  9);
 
INSERT INTO Mobilise (id_action, id_collaborateur) VALUES
( 1,  1), ( 1,  3), ( 1,  4), ( 1,  5),
( 2,  2), ( 2,  5),
( 3, 11), ( 3, 13), ( 3, 14),
( 4,  6), ( 4,  8), ( 4,  9), ( 4, 10),
( 5,  7), ( 5,  9),
( 6, 12), ( 6, 14),
( 7, 11), ( 7, 12),
( 8,  2), ( 8,  3), ( 8,  5),
( 9,  2), ( 9,  3),
(10, 11), (10, 13),
(11,  6), (11,  7),
(12,  7), (12,  8), (12, 10);
 
COMMIT;
 

SELECT 'Site' AS table_, COUNT(*) AS nb FROM Site
UNION ALL SELECT 'Collaborateur', COUNT(*) FROM Collaborateur
UNION ALL SELECT 'Indicateur',    COUNT(*) FROM Indicateur
UNION ALL SELECT 'Releve',        COUNT(*) FROM Releve
UNION ALL SELECT 'Objectif',      COUNT(*) FROM Objectif
UNION ALL SELECT 'Action',        COUNT(*) FROM `Action`
UNION ALL SELECT 'Mobilise',      COUNT(*) FROM Mobilise;
 

SELECT s.code_site, i.code_indicateur, i.unite, o.sens_cible, o.valeur_cible,
       SUM(r.valeur_mesuree) AS realise,
       CASE
           WHEN o.sens_cible = 'Maximum' AND SUM(r.valeur_mesuree) <= o.valeur_cible THEN 'Respecté'
           WHEN o.sens_cible = 'Minimum' AND SUM(r.valeur_mesuree) >= o.valeur_cible THEN 'Respecté'
           ELSE 'Non respecté'
       END AS resultat
FROM Objectif o
JOIN Site s       ON s.id_site = o.id_site
JOIN Indicateur i ON i.id_indicateur = o.id_indicateur
JOIN Releve r     ON r.id_site = o.id_site
                 AND r.id_indicateur = o.id_indicateur
                 AND YEAR(r.periode) = o.annee
                 AND r.statut <> 'Rejeté'
GROUP BY o.id_objectif, s.code_site, i.code_indicateur, i.unite, o.sens_cible, o.valeur_cible
ORDER BY o.id_objectif;
 

SELECT id_action, titre, statut, date_fin_prevue
FROM `Action`
WHERE date_fin_prevue < CURDATE()
  AND statut NOT IN ('Terminée', 'Annulée');
 