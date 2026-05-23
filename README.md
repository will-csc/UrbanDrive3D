# UrbanDrive3D

UrbanDrive3D is a small Godot 4 prototype focused on urban exploration and simple vehicle gameplay. The project includes a walkable player controller, multiple drivable cars, and a procedural city generator built from modular city assets.

## Overview

This project currently includes:

- First-person / third-person style character movement based on a reusable `CharacterBody3D` controller
- Multiple drivable vehicles in the main scene
- Automatic vehicle entry when the player reaches a car
- Vehicle exit using the interaction key
- Procedural city layout generation with roads, intersections, buildings, lights, and props
- Camera switching between player and car views

## Engine

- Godot `4.6`
- Rendering mode: `GL Compatibility`
- Physics engine: `Jolt Physics`

## Controls

Default inputs defined in `project.godot`:

- `W` -> move forward
- `S` -> move backward
- `A` -> move left
- `D` -> move right
- `Shift` -> sprint
- `Space` -> jump
- `F` -> interact / exit vehicle
- `Esc` -> release mouse cursor

Vehicle behavior:

- Move near a car to enter it automatically
- Use `W`, `A`, `S`, `D` to drive
- Press `F` to leave the current car

## Project Structure

```text
UrbanDrive3D/
|- addons/
|  |- Basic CharacterBody3D/
|  |- kaykit_city_builder_bits/
|- scences/
|  |- main.tscn
|- scripts/
|  |- car_base.gd
|  |- car_camera_3d.gd
|  |- city_generator.gd
|- project.godot
|- README.md
```

## Main Files

- `scences/main.tscn`
  - Main playable scene
  - Contains the player, drivable cars, and the city generator

- `scripts/city_generator.gd`
  - Builds the road grid and places buildings and decorative props
  - Uses the KayKit modular city assets from `addons/kaykit_city_builder_bits`

- `scripts/car_base.gd`
  - Handles entering, driving, camera switching, and exiting vehicles

- `scripts/car_camera_3d.gd`
  - Controls camera pivot behavior while driving

- `addons/Basic CharacterBody3D/player.gd`
  - Base player controller with walking, sprinting, jumping, and mouse look

## Included Vehicles

The main scene currently includes multiple drivable cars, including:

- Sedan
- Hatchback
- Police car
- Taxi

## Procedural City

The city generator creates a simple urban block layout using:

- Straight roads
- Intersections and crossings
- Building variations
- Streetlights
- Traffic lights
- Decorative props such as benches, bushes, trash, and hydrants
- A landmark water tower

You can tweak the generated city through exported variables in `scripts/city_generator.gd`, such as:

- `tamanho_cidade`
- `profundidade_cidade`
- `passo_rua`
- `espacamento_predios`
- `chance_decoracao`
- `ruas_horizontais`
- `ruas_verticais`

## How To Run

1. Open the project in Godot 4.6 or newer.
2. Let Godot import the assets.
3. Open `scences/main.tscn`, or just run the project directly.
4. Play the scene and explore the city on foot or by car.

## Notes

- The folder `scences/` is currently named with that spelling in the project and is referenced by the scene files.
- Car models come from the included KayKit city asset pack.
- The player controller is based on the included `Basic CharacterBody3D` addon.

## Possible Next Steps

- Add UI prompts for entering and exiting cars
- Add parked traffic or AI vehicles
- Add better spawn points and checkpoints
- Expand the city with more districts and intersections
- Add sound effects and vehicle-specific tuning
