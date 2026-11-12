using System;
using MySql.Data.MySqlClient;

namespace ApplicationProjet
{
    internal class Program
    {
        // ------------------------------------------------------------
        // Menu de depart : le choix determine le compte MySQL utilise
        // ------------------------------------------------------------
        static void Main(string[] args)
        {
            Console.OutputEncoding = System.Text.Encoding.UTF8; // pour bien afficher les accents
            string choix = "";
            while (choix != "0")
            {
                Console.WriteLine();
                Console.WriteLine("=================================");
                Console.WriteLine("        ECOPILOT RSE");
                Console.WriteLine("=================================");
                Console.WriteLine("1 - Utilisateur de consultation");
                Console.WriteLine("2 - Gestionnaire");
                Console.WriteLine("0 - Quitter");
                Console.Write("Votre choix : ");
                choix = Console.ReadLine();

                if (choix == "1")
                {
                    MySqlConnection maConnection = SeConnecter("UtilisateurC");
                    if (maConnection != null)
                    {
                        Menu(maConnection, false);
                        maConnection.Close(); // fermeture de la connexion
                    }
                }
                else if (choix == "2")
                {
                    MySqlConnection maConnection = SeConnecter("UtilisateurG");
                    if (maConnection != null)
                    {
                        Menu(maConnection, true);
                        maConnection.Close(); // fermeture de la connexion
                    }
                }
                else if (choix != "0")
                {
                    Console.WriteLine("Choix inconnu.");
                }
            }
            Console.WriteLine("Au revoir.");
        }

        // ------------------------------------------------------------
        // Connexion a MySQL. Renvoie null si la connexion echoue :
        // on retourne alors au menu de depart (nouvelle tentative possible)
        // ------------------------------------------------------------
        static MySqlConnection SeConnecter(string utilisateur)
        {
            Console.Write("Mot de passe de " + utilisateur + " : ");
            string mdp = Console.ReadLine();
            string connectionString = "SERVER=localhost;PORT=3306;DATABASE=ecopilot_rse;" +
                                      "UID=" + utilisateur + ";PASSWORD=" + mdp + ";";

            MySqlConnection maConnection = new MySqlConnection(connectionString);
            try
            {
                maConnection.Open();
                Console.WriteLine("Connecté en tant que " + utilisateur + ".");
                return maConnection;
            }
            catch (MySqlException e)
            {
                Console.WriteLine("Connexion impossible : vérifiez le mot de passe et que MySQL est démarré.");
                Console.WriteLine("(" + e.Message + ")");
                return null;
            }
        }

        // ------------------------------------------------------------
        // Menu : le gestionnaire a deux choix de plus (11 et 12)
        // ------------------------------------------------------------
        static void Menu(MySqlConnection c, bool gestionnaire)
        {
            string choix = "";
            while (choix != "0")
            {
                Console.WriteLine();
                if (gestionnaire)
                {
                    Console.WriteLine("===== MENU GESTIONNAIRE =====");
                }
                else
                {
                    Console.WriteLine("===== MENU CONSULTATION =====");
                }
                Console.WriteLine("1 - Afficher la liste des sites");
                Console.WriteLine("2 - Afficher les collaborateurs d'un site");
                Console.WriteLine("3 - Afficher les indicateurs d'une famille");
                Console.WriteLine("4 - Afficher l'historique des relevés");
                Console.WriteLine("5 - Afficher les statistiques d'un indicateur");
                Console.WriteLine("6 - Afficher les actions RSE d'un site");
                Console.WriteLine("7 - Afficher les actions en retard");
                Console.WriteLine("8 - Afficher le responsable et les participants d'une action");
                Console.WriteLine("9 - Afficher le nombre d'actions et le budget par site et par statut");
                Console.WriteLine("10 - Consulter les éléments inactifs et leur historique");
                if (gestionnaire)
                {
                    Console.WriteLine("11 - Enregistrer un relevé de test");
                    Console.WriteLine("12 - Terminer une action de test");
                }
                Console.WriteLine("0 - Se déconnecter");
                Console.Write("Votre choix : ");
                choix = Console.ReadLine();

                if (choix == "1") R1(c);
                else if (choix == "2") R2(c);
                else if (choix == "3") R3(c);
                else if (choix == "4") R4(c);
                else if (choix == "5") R5(c);
                else if (choix == "6") R6(c);
                else if (choix == "7") R7(c);
                else if (choix == "8") R8(c);
                else if (choix == "9") R9(c);
                else if (choix == "10") R10(c);
                else if (choix == "11" && gestionnaire) EnregistrerReleveTest(c);
                else if (choix == "12" && gestionnaire) TerminerActionTest(c);
                else if (choix != "0") Console.WriteLine("Choix inconnu.");
            }
        }

        // ------------------------------------------------------------
        // Affichage d'une requete SELECT
        // ------------------------------------------------------------
        static void Afficher(MySqlConnection c, string titre, string entete, string requete)
        {
            Console.WriteLine();
            Console.WriteLine("--- " + titre + " ---");
            Console.WriteLine(entete);

            MySqlDataReader reader = null;
            try
            {
                MySqlCommand command = c.CreateCommand();
                command.CommandText = requete;

                reader = command.ExecuteReader();

                string[] valuesString = new string[reader.FieldCount];
                int nb = 0;
                while (reader.Read())
                {
                    for (int i = 0; i < reader.FieldCount; i++)
                    {
                        valuesString[i] = reader.GetValue(i).ToString();
                        Console.Write(valuesString[i] + "\t");
                    }
                    Console.WriteLine();
                    nb++;
                }
                reader.Close();

                if (nb == 0)
                {
                    Console.WriteLine("(aucun résultat)");
                }

            }
            catch (MySqlException e)
            {
                Console.WriteLine("Erreur d'exécution : " + e.Message);
                if (reader != null)
                {
                    reader.Close();
                }
            }
        }


        static void R1(MySqlConnection c)
        {
            Afficher(c, "R1 : liste de tous les sites",
           "Code\tSite\tVille\tEtat",
           "SELECT code_site AS Code, nom AS Site, ville AS Ville, IF(actif = 1, 'Actif', 'Inactif') AS Etat " +
           "FROM Site " +
           "ORDER BY actif DESC, nom;");
        }

        static void R2(MySqlConnection c)
        {
            Afficher(c, "R2 : collaborateurs du site NVT-LYO",
            "Nom\tPrenom\tMatricule\tEmail\tEtat",
            "SELECT C.nom AS Nom, C.prenom AS Prenom, C.matricule AS Matricule, C.email_pro AS Email, " +
            "IF(C.actif = 1, 'Actif', 'Inactif') AS Etat " +
            "FROM Collaborateur C " +
            "JOIN Site S ON C.id_site = S.id_site " +
            "WHERE S.code_site = 'NVT-LYO' " +
            "ORDER BY C.nom, C.prenom;");
        }
        static void R3(MySqlConnection c)
        {
            Afficher(c, "R3 : indicateurs de la famille Énergie",
                "Famille\tCode\tIndicateur\tUnite",
                "SELECT F.libelle_famille AS Famille, I.code_indicateur AS Code, I.libelle AS Indicateur, I.unite AS Unite " +
                "FROM Indicateur I " +
                "JOIN Famille F ON I.id_famille = F.id_famille " +
                "WHERE F.libelle_famille = 'Énergie' " +
                "ORDER BY I.code_indicateur;");
        }

        static void R4(MySqlConnection c)
        {
            Afficher(c, "R4 : relevés ELEC du site NVT-LYO, de mars à août 2025",
                "Mois\tSite\tIndicateur\tValeur\tUnite\tStatut",
                "SELECT R.periode AS Mois, S.code_site AS Site, I.code_indicateur AS Indicateur, " +
                "R.valeur_mesuree AS Valeur, I.unite AS Unite, R.statut AS Statut " +
                "FROM Releve R " +
                "JOIN Site S ON R.id_site = S.id_site " +
                "JOIN Indicateur I ON R.id_indicateur = I.id_indicateur " +
                "WHERE S.code_site = 'NVT-LYO' " +
                "AND I.code_indicateur = 'ELEC' " +
                "AND R.periode BETWEEN '2025-03-01' AND '2025-08-31' " +
                "ORDER BY R.periode;");
        }

        static void R5(MySqlConnection c)
        {
            Afficher(c, "R5 : statistiques de l'indicateur ELEC par site, année 2025 (relevés non rejetés)",
                "Site\tSomme\tMoyenne\tMinimum\tMaximum",
                "SELECT S.code_site AS Site, SUM(R.valeur_mesuree) AS Somme, ROUND(AVG(R.valeur_mesuree), 2) AS Moyenne, " +
                "MIN(R.valeur_mesuree) AS Minimum, MAX(R.valeur_mesuree) AS Maximum " +
                "FROM Releve R " +
                "JOIN Site S ON R.id_site = S.id_site " +
                "JOIN Indicateur I ON R.id_indicateur = I.id_indicateur " +
                "WHERE I.code_indicateur = 'ELEC' " +
                "AND R.periode BETWEEN '2025-01-01' AND '2025-12-31' " +
                "AND R.statut <> 'Rejeté' " +
                "GROUP BY S.code_site " +
                "ORDER BY S.code_site;");
        }

        static void R6(MySqlConnection c)
        {
            Afficher(c, "R6 : actions RSE du site NVT-LYO",
                "Action\tStatut\tDebut_prevu\tFin_prevue\tFin_reelle\tResponsable",
                "SELECT A.titre AS Action, A.statut AS Statut, A.date_debut_prevue AS Debut_prevu, " +
                "A.date_fin_prevue AS Fin_prevue, A.date_fin_reelle AS Fin_reelle, " +
                "CONCAT(C.prenom, ' ', C.nom) AS Responsable " +
                "FROM `Action` A " +
                "JOIN Site S ON A.id_site = S.id_site " +
                "JOIN Collaborateur C ON A.id_collaborateur = C.id_collaborateur " +
                "WHERE S.code_site = 'NVT-LYO' " +
                "ORDER BY A.date_debut_prevue;");
        }

        static void R7(MySqlConnection c)
        {
            Afficher(c, "R7 : actions en cours en retard (fin prévue dépassée)",
                "Action\tSite\tFin_prevue\tJours_de_retard",
                "SELECT A.titre AS Action, S.nom AS Site, A.date_fin_prevue AS Fin_prevue, " +
                "DATEDIFF(CURDATE(), A.date_fin_prevue) AS Jours_de_retard " +
                "FROM `Action` A " +
                "JOIN Site S ON A.id_site = S.id_site " +
                "WHERE A.statut = 'En cours' " +
                "AND A.date_fin_prevue < CURDATE() " +
                "ORDER BY Jours_de_retard DESC;");
        }

        static void R8(MySqlConnection c)
        {
            Afficher(c, "R8 : responsable de l'action numéro 4",
                "Action\tResponsable",
                "SELECT A.titre AS Action, CONCAT(C.prenom, ' ', C.nom) AS Responsable " +
                "FROM `Action` A " +
                "JOIN Collaborateur C ON A.id_collaborateur = C.id_collaborateur " +
                "WHERE A.id_action = 4;");
            Afficher(c, "R8 : participants de l'action numéro 4",
                "Participant",
                "SELECT CONCAT(C.prenom, ' ', C.nom) AS Participant " +
                "FROM Mobilise M " +
                "JOIN Collaborateur C ON M.id_collaborateur = C.id_collaborateur " +
                "WHERE M.id_action = 4 " +
                "ORDER BY C.nom, C.prenom;");
        }

        static void R9(MySqlConnection c)
        {
            Afficher(c, "R9 : nombre d'actions et budget par site et par statut",
                "Site\tStatut\tNb_actions\tBudget_total",
                "SELECT S.nom AS Site, A.statut AS Statut, COUNT(*) AS Nb_actions, " +
                "SUM(A.budget_previsionnel) AS Budget_total " +
                "FROM `Action` A " +
                "JOIN Site S ON A.id_site = S.id_site " +
                "GROUP BY S.nom, A.statut " +
                "ORDER BY S.nom, A.statut;");
        }

        static void R10(MySqlConnection c)
        {
            Afficher(c, "R10 : sites inactifs et leur historique",
                "Site_inactif\tNb_collaborateurs\tNb_releves\tNb_actions",
                "SELECT S.nom AS Site_inactif, " +
                "(SELECT COUNT(*) FROM Collaborateur C WHERE C.id_site = S.id_site) AS Nb_collaborateurs, " +
                "(SELECT COUNT(*) FROM Releve R WHERE R.id_site = S.id_site) AS Nb_releves, " +
                "(SELECT COUNT(*) FROM `Action` A WHERE A.id_site = S.id_site) AS Nb_actions " +
                "FROM Site S " +
                "WHERE S.actif = 0;");
            Afficher(c, "R10 : collaborateurs inactifs et leur historique",
                "Collaborateur_inactif\tNb_actions_responsable\tNb_participations",
                "SELECT CONCAT(C.prenom, ' ', C.nom) AS Collaborateur_inactif, " +
                "(SELECT COUNT(*) FROM `Action` A WHERE A.id_collaborateur = C.id_collaborateur) AS Nb_actions_responsable, " +
                "(SELECT COUNT(*) FROM Mobilise M WHERE M.id_collaborateur = C.id_collaborateur) AS Nb_participations " +
                "FROM Collaborateur C " +
                "WHERE C.actif = 0;");
            Afficher(c, "R10 : indicateurs inactifs et leur historique",
                "Indicateur_inactif\tNb_releves\tNb_objectifs",
                "SELECT I.libelle AS Indicateur_inactif, " +
                "(SELECT COUNT(*) FROM Releve R WHERE R.id_indicateur = I.id_indicateur) AS Nb_releves, " +
                "(SELECT COUNT(*) FROM Objectif O WHERE O.id_indicateur = I.id_indicateur) AS Nb_objectifs " +
                "FROM Indicateur I " +
                "WHERE I.actif = 0;");
        }

        // ------------------------------------------------------------
        // Choix 11 (R11) : insertion d'un releve de test (valeurs fixees dans le code)
        // ------------------------------------------------------------
        static void EnregistrerReleveTest(MySqlConnection c)
        {
            Console.WriteLine();
            Console.WriteLine("--- Choix 11 (R11) : enregistrement d'un relevé de test ---");
            Console.WriteLine("Site NVT-LYO (numéro 1), indicateur ELEC (numéro 1), mois 2026-01-01, valeur 20450");
            try
            {
                MySqlCommand command = c.CreateCommand();
                command.CommandText =
                    "INSERT INTO Releve (date_saisie, source, statut, periode, valeur_mesuree, id_site, id_indicateur) " +
                    "VALUES ('2026-02-03', 'Facture fournisseur', 'À valider', '2026-01-01', 20450.00, 1, 1);";
                MySqlDataReader reader = command.ExecuteReader();
                reader.Close();
                Console.WriteLine("Insertion réussie.");
            }
            catch (MySqlException e)
            {
                Console.WriteLine("Insertion échouée (ce relevé existe peut-être déjà) : " + e.Message);
            }
        }

        // ------------------------------------------------------------
        // Choix 12 (R11) : terminer une action de test (valeurs fixees dans le code)
        // ------------------------------------------------------------
        static void TerminerActionTest(MySqlConnection c)
        {
            Console.WriteLine();
            Console.WriteLine("--- Choix 12 (R11) : terminer l'action numéro 4 au 2026-11-12 ---");
            try
            {
                // 1) l'action existe-t-elle ?
                MySqlCommand command = c.CreateCommand();
                command.CommandText = "SELECT titre FROM `Action` WHERE id_action = 4;";
                MySqlDataReader reader = command.ExecuteReader();
                bool trouvee = reader.Read();
                reader.Close();

                if (trouvee == false)
                {
                    Console.WriteLine("Aucune action trouvée avec ce numéro.");
                }
                else
                {
                    // 2) modification du statut et de la date de fin réelle
                    MySqlCommand modif = c.CreateCommand();
                    modif.CommandText =
                        "UPDATE `Action` SET statut = 'Terminée', date_fin_reelle = '2026-11-12' " +
                        "WHERE id_action = 4;";
                    MySqlDataReader reader2 = modif.ExecuteReader();
                    reader2.Close();
                    Console.WriteLine("Modification réussie : l'action 4 est terminée.");
                }
            }
            catch (MySqlException e)
            {
                Console.WriteLine("Modification échouée : " + e.Message);
            }
        }
    }
}
