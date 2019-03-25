# tp-ia
Implementation de l'algorithme A* et Negamax sous une forme générique et efficace en
# A* :
L’algorithmedoit réutilisable tout type de problème modélisable comme la recherche d’un chemin optimal dans un graphe d’états,à condition de définir dans un fichier dédié :
* l'état initial
* l'état final
* les actions possibles pour changer d'état
* le coût de chaque action
* l'heuristique estimant la distance d'un état donnéà l'état final.

Les deux heuristiques implémentés :
* Le nb de pièces mal placéesdans la position courante par rapport à la situation désirée
* La somme des distances de Manhattande chaque pièce depuis sa position courante vers la position désirée.
