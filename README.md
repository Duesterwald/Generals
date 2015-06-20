# Generals
Battle for Wesnoth: Generals -- Multiplayer PvP Pseudo Campaign

I have been working on an add-on, which simulates a PvP "campaign" mode. The idea is, that there are is 
a global mode, on which players move their companies, and if two companies clash, the game enters the 
local mode, in which the participating players move their units like in a normal BfW game.

The map for the local battle is generated procedurally, taking into account the position of the skirmish, 
the global map size, the local map size and the terrain of the global map at the position of the battle. 
For instance, if the tile of the defending company was a village, the map will feature a town 
(many villages) where that company's captain starts. All subsequent battles at the same location 
will have the same maps. The map size for the local mode is adjustable via option before the game starts.

The turn structure is also divided. The global schedule represents the passing of seasons, while the 
local schedule is based on a clock. The night lasts longer in winter that in spring and in summer, 
the day lasts longest.

When recruiting a company, the player will first recruit a normal unit, which becomes the captain of 
the company. Since companies are very powerful units (about 200 HP, lvl > 10), they are rather expensive. 
Therefore the amount of gold each player starts with and gets through villages is multiplied by a factor, 
which can be chosen before the game. Additional units can be recruited to the company, when it engages 
an opponent.

All units recruited in one company will stay in exactly that company and will be available in the recall 
list of subsequent battles of that company. At the moment, if a company is disbanded (the global company 
unit dies), all its surviving units will die with it. However, I am planning to have at least level >=2 
units survive and look for another company to join.

In global mode, the flow of gold is similar to the normal game. Villages produce gold, and that gold 
can be spent on recruiting new companies. In local mode, however, players will start with a fixed amount 
plus the company's hitpoints. Local villages produce no gold, so once you spent all of it, you have to 
make due with the soldiers you have. When a unit dies, its company looses an asset and thus takes damage. 
Also, the unit drops its equipment and payroll in the form of loot, which can be collected by both sides.

Each battle can end in several ways.

1) The turn limit (choosable before the game) is reached, in which case the battle just stops and the 
game returns in global mode. Both companies will have their hitpoints adjusted and may have gained 
some experience in that battle.

2) One of the companies sustains lethal damage. In that case, the game returns to global mode and the 
defeated company is removed from the map.

3) One of the company captains dies. In that case, the remaining soldiers are routed and retreat from 
battle. The most senior soldier is promoted to captain automatically. If there is no other soldier left, 
the company is dissolved immediately. Retreating, however, comes at a cost. The victor may have some 
bloodlust remaining and will damage the retreating company accordingly. This damage might kill the loser 
and dissolve the company as well.

4) One player chooses to retreat. If the captain is still alive to coordinate the retreat, the player 
can choose some of their units to cover the retreat (they will be sacrificed). Expensive units with 
much experience will be best suited for this task. The defending company can only retreat by moving 
the captain to a tile with a signpost on it, in which case the company retreats in that direction on 
the global map. Some directions may be hindered by inpassability or other companies occupying those 
tiles.

Whenever a unit gains experience in battle, its company gets just as much experience. Once it has enough, 
it can advance via AMLA. I would like to implement an extensive AMLA system, where different kinds of 
companies can acquire different abilities and traits through these advancements. However, advancements 
are only triggered at the beginning of each player's turn. This has two effects: there are no random 
advancements and thus no "need for plan your advancements", and it is not possible to retreat from a 
skirmish with heavy losses, just to have the lack of hitpoints remedied by an advancement.
