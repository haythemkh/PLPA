from monosat import *
from colorama import Fore, Back, Style
import sys
      
#### entrées du programme  
GRID_SIZE = int(sys.argv[1]) # taille de la grille
ENTRY_COL = int(sys.argv[2]) # colonne d'entrée
EXIT_COL = int(sys.argv[3])  # colonne de sortie
MIN_PATH_LENGTH = int(sys.argv[4]) # taille du chemin minimal

#### contraintes sur les entrées du programme
assert( 0 <= ENTRY_COL and ENTRY_COL <= GRID_SIZE-1 ) # contrainte sur la colonne de départ
assert( 0 <= EXIT_COL and EXIT_COL <= GRID_SIZE-1 ) # contrainte sur la colonne de sortie
assert( 0 <= MIN_PATH_LENGTH and MIN_PATH_LENGTH <= GRID_SIZE**2 ) # contrainte sur la taille du chemin minimal
if MIN_PATH_LENGTH < GRID_SIZE: # taille du chemin minimal < taille de la grille
	raise RuntimeError("Taille du chemin doit être supérieure ou égale à la taille de la grille !")

#### mapping des couleurs des cases du labyrinthe
RED = 0
GREEN = 1
BLUE = 2
YELLOW = 3    

#### initialisation des structures de données
graph = Graph()
nodes = dict()
edges = dict()
color = dict()

#### fonction d'affichage du labyrinthe retenu
def print_color_map():       
    for i in range(GRID_SIZE):
        print("\ni:%2d | " % i, end="")
        for j in range(GRID_SIZE):
            node = nodes[i,j]
            # background color
            color_idx = color[node].value()
            bcolor = Back.RESET
            if color_idx == 0:
                bcolor = Back.RED
            elif color_idx == 1:
                bcolor = Back.GREEN
            elif color_idx == 2:
                bcolor = Back.BLUE
            else: # color_idx == 3
                bcolor = Back.YELLOW
            print(Fore.BLACK + bcolor + " ", end="")
        print(Style.RESET_ALL, end="")
    print("")
        
#### fonction définissant la contrainte mise sur l'ordre des couleurs		
def color_constraints(x,y):
    Assert(Not(Equal( # la couleur des noeud adjacents est différente
        color[x],
        color[y])))
    Assert(Implies(
        edges[x,y],
        And([ # ordre imposé: rouge -> vert -> bleu -> jaune -> rouge
		    Implies(Equal(color[x], RED), Equal(color[y], GREEN)),
		    Implies(Equal(color[x], GREEN), Equal(color[y], BLUE)),
		    Implies(Equal(color[x], BLUE), Equal(color[y], YELLOW)),
		    Implies(Equal(color[x], YELLOW), Equal(color[y], RED))])))

#### constructeur des vecteurs "nodes" et "color"
for i in range(GRID_SIZE):
    for j in range(GRID_SIZE):
        n = graph.addNode()
        nodes[i,j] = n
        color[n] = BitVector(2)
    
#### constructeur de la matrice "edges" + application des contraintes de couleurs
for i in range(GRID_SIZE):
    for j in range(GRID_SIZE):
        currentNode = nodes[i, j] # noeud courant
        # noeuds adjacents au noeud courant
        if j+1 <= GRID_SIZE-1: # Est node
            eastNode = nodes[i, j+1]
            edges[currentNode, eastNode] = graph.addEdge(currentNode, eastNode, 1)
            color_constraints(currentNode, eastNode)
        if j-1 >= 0: # West node
            westNode = nodes[i, j-1]
            edges[currentNode, westNode] = graph.addEdge(currentNode, westNode, 1)
            color_constraints(currentNode, westNode)
        if i-1 >= 0: # North node
            northNode = nodes[i-1, j]
            edges[currentNode, northNode] = graph.addEdge(currentNode, northNode, 1)
            color_constraints(currentNode, northNode)
        if i+1 <= GRID_SIZE-1: # South node
            southNode = nodes[i+1, j]
            edges[currentNode, southNode] = graph.addEdge(currentNode, southNode, 1)
            color_constraints(currentNode, southNode)

#### contraintes générales
startNode = nodes[0,ENTRY_COL] # noeud de départ
endNode = nodes[GRID_SIZE-1,EXIT_COL] # noeud d'arrivée
Assert(graph.acyclic(True)) # graphe acyclique
Assert(Equal(color[startNode],RED)) # noeud de départ rouge
Assert(graph.reaches(startNode,endNode)) # critère d'atteignabilité
Assert(Not(graph.distance_leq(startNode,endNode,MIN_PATH_LENGTH))) # distance minimale entre le noeud de départ et le noeud d'arrivée
# aucun chemin ne lie les noeuds de la première et de la dernière ligne autres que le noeud de départ et le noeud d'arrivée
Assert(And([Not(graph.reaches(nodes[0,i],nodes[GRID_SIZE-1,j])) for i in range(GRID_SIZE) for j in range(GRID_SIZE) if (nodes[0,i]!=startNode or nodes[GRID_SIZE-1,j]!=endNode)]))

result = monosat.Solve()
if result:
    print("SAT", end="")
    print_color_map()
else:
	print("UNSAT")
