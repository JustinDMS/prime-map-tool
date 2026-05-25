# Metroid Prime Map Tool

Visualizer for [Randovania's](https://github.com/randovania/randovania) logic database.

## How it works

A randomizer's logic database is a model of the game world. It consists of points that represent in-game locations (nodes) and requirements for traversing between them (edges), otherwise known as a graph. When data is modeled this way, it allows for inherently winnable seeds to be *constructed* rather than relying on a purely random layout, which produces mostly unwinnable seeds. As the database grows in size and complexity, it's easy for mistakes and inaccuracies to slip through the cracks. This application makes them easier to spot.

### Phase 1 - Building the Map

Each in-game region in Prime has its own global coordinate space. Each room and game object is contained within an axis-aligned bounding box, AABB, within the region space. Leveraging [randomprime](https://github.com/randovania/randomprime), the patcher used by Randovania, I was able to dump exact in-game coordinate ranges for each room, along with the transform (position, rotation, and scale) of doors and pickups. Some of Randovania's node types, like generic nodes, don't represent an exact in-game position but rather an arbitrary area within the room. I had to use another tool, [Prime World Editor](https://github.com/AxioDL/PrimeWorldEditor), to manually determine in-game coordinates that are representative of the given node.

The asset pipeline was particularly involved. First, by using the existing reverse-engineered, native reimplementation of Metroid Prime, [Metaforce](https://github.com/AxioDL/metaforce), I was able to dump the room models used in the in-game map in a format compatible with Blender. With Blender's built-in Python scripting, I was able to automate the process of rendering an overhead image of each room in each region. Images were rendered at an upscaled, proportional resolution for quality purposes. They were also rendered with a transparent background so the image itself could be used as a bitmask for hover detection.

Having dumped exact coordinates and rendered images that match 1:1 (in-game units to pixels), everything was in place to build an accurate map.

### Phase 2 - Logic Visualization

Before placing any assets, first we need to parse the logic database. This was relatively straightforward with Godot's built-in JSON handling. The bits of data we need first model the game world: the game regions, the rooms that make up each region, and the nodes contained within each room. Then, with our AABB coordinate ranges `(x min, y min, z min) -> (x max, y max, z max)`, we can offset the room relative to its region so that it reflects its position in-game.

Next, it's time to overlay nodes. This followed the same process as rooms: use our extracted coordinate data and offset the node so it sits in the correct position. Each node type was assigned a different icon, and nodes with multiple underlying types (e.g. doors) were color-coded. With all of the rooms and nodes placed, the base map was complete.

For the logical visualization portion, I implemented a custom breadth-first search (BFS) algorithm to "solve" the world state from the user's chosen start point. It handled Randovania's event nodes, which are one-off in-game events (i.e. defeating a boss, lowering a barrier) that change the accessibility of the game world in some way. Once the world state is resolved, rooms that were reached retain their region's color while unreachable rooms are turned grayscale. This provided immediate visual feedback and is what makes this tool so good for spotting inaccuracies compared to poring over the raw JSON data. 

## Usage

Try it in your browser: [https://justindm.itch.io/prime-map](https://justindm.itch.io/prime-map)

1. Install [Godot Engine 4.6.x](https://github.com/godotengine/godot/releases/tag/4.6.3-stable)
2. Clone repo: `git clone https://github.com/JustinDMS/prime-map-tool.git`
3. Launch Godot (the Project Manager will open) -> Import -> Select the `project.godot` file

## Credits

- [Randovania](https://github.com/randovania/randovania) for their logic database
- Toasterparty, as the main contributor of [randomprime](https://github.com/randovania/randomprime)
- The [Metaforce](https://github.com/AxioDL/metaforce) team
- Miepee, for working with me on adding AM2R support