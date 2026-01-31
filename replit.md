# Masquerade

A Global Game Jam 2026 Godot 4.6 multiplayer board game.

## Project Overview

Masquerade is an online multiplayer adaptation of the traditional board game Barricade. The game board is a procedural mask that defines paths, obstacles, power zones, and player interactions.

## Tech Stack

- **Engine**: Godot 4.6
- **Rendering**: OpenGL3/OpenGLES (compatibility mode for Replit)
- **Physics**: 2D Physics for menu, Jolt Physics 3D for game

## Project Structure

```
.
├── assets/
│   ├── png/              # Menu button/logo PNGs (runtime loaded)
│   │   ├── menu-bg.png
│   │   ├── menu-logo.png
│   │   ├── menu-btn-game.png
│   │   ├── menu-btn-mask.png
│   │   ├── menu-btn-powerup.png
│   │   └── menu-btn-settings.png
│   └── font/
│       └── NEWTONIN.OTF  # Custom font (Newton Inline)
├── scenes/
│   ├── main.tscn         # Entry scene with scene manager
│   ├── main-menu/
│   │   └── main-menu.tscn  # Node2D animated menu
│   ├── game/             # Game scenes
│   └── pause-menu/       # Pause menu
├── scripts/
│   ├── main.gd           # Scene manager
│   └── main-menu/
│       └── menu.gd       # Animated menu with physics
└── project.godot
```

## Menu System

### Visual Elements
- **Background**: Full-screen PNG background
- **Logo**: Centered at 40% height, occasional wiggle animation
- **Game Button**: Centered at 65% height, gentle bobbing, tournament code UI overlay
- **Settings Button**: Top-right (90%/10%), random spin animation
- **Mask & Powerup Buttons**: Physics-based floating, collide with screen edges and other elements

### Interactions
- **Hover**: Buttons lighten (modulate to 1.3 brightness)
- **Tournament Code**: 4-character alphanumeric (no confusing chars like O/0/I/1)
- **NEW GAME**: Generates code and starts
- **JOIN**: Enabled when valid code entered

### Technical Notes
- Uses `Image.load()` for runtime PNG loading (bypasses Godot import system)
- PNG format chosen for compatibility with headless Godot environment
- 2D physics (RigidBody2D) for floating buttons with collision

## Running the Game

The game runs via VNC display in Replit using OpenGL3 rendering driver.

## Game Mechanics

- 4-12 players, each controlling multiple pawns
- Powers: Kidnap, Alliance, Rewind, Berserk
- Procedural mask-shaped game board

## Recent Changes

- 2026-01-31: Converted menu to Node2D with PNG assets and runtime image loading
- 2026-01-31: Added physics-based floating buttons with collision
- 2026-01-31: Added hover effects (modulate brightness) and animations (wiggle, spin, bob)
