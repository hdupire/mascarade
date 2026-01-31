# Masquerade

A Global Game Jam 2026 Godot 4.6 multiplayer board game.

## Project Overview

Masquerade is an online multiplayer adaptation of the traditional board game Barricade. The game board is a procedural mask that defines paths, obstacles, power zones, and player interactions.

## Tech Stack

- **Engine**: Godot 4.6
- **Rendering**: OpenGL3/OpenGLES (compatibility mode for Replit)
- **Physics**: Jolt Physics 3D

## Project Structure

```
.
├── assets/               # Game assets (SVGs, textures)
├── scenes/
│   ├── main.tscn         # Entry scene with scene manager
│   ├── main-menu/        # Main menu (Node3D based)
│   │   ├── components/   # Menu components (cyclorama, title, buttons)
│   │   └── main-menu.tscn
│   ├── game/             # Game scenes
│   └── pause-menu/       # Pause menu
├── scripts/
│   ├── main.gd           # Scene manager
│   └── main-menu/        # Menu scripts with tournament code
└── project.godot         # Godot project configuration
```

## Menu Features

- **3D Node-based menu** with cyclorama background
- **Tournament Code System**: Generate 4-character codes or enter existing codes to join games
- **Title Generator**: Displays MASQUERADE title (SVG or Label3D fallback)

## Running the Game

The game runs via VNC display in Replit using OpenGL3 rendering driver.

## Game Mechanics

- 4-12 players, each controlling multiple pawns
- Powers: Kidnap, Alliance, Rewind, Berserk
- Procedural mask-shaped game board

## Recent Changes

- 2026-01-31: Rebuilt main menu as Node3D with tournament code functionality
- 2026-01-31: Added Label3D fallback for title when SVG can't load
