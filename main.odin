package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strings"
import rl "vendor:raylib"

Direction :: enum {
	Left,
	Right,
	Up,
	Down,
}

Food :: struct {
	pos: rl.Vector2,
}

food: Food

food_exists: bool = false

pos := rl.Vector2{f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)}
direction := rl.Vector2{1, 0}
block_speed: f32 = 3.2
last_dir: Direction = .Right
current_score := 0

main :: proc() {
	rl.InitWindow(900, 700, "Snek")
	rl.SetTargetFPS(60)

	pos := rl.Vector2{f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)}

	for !rl.WindowShouldClose() {
		rl.ClearBackground(rl.BLACK)

		if !food_exists {
			food.pos = {
				rand.float32() * f32(rl.GetScreenWidth()),
				rand.float32() * f32(rl.GetScreenHeight()),
			}
			food_exists = true
		}

		rl.DrawRectangle(i32(food.pos.x), i32(food.pos.y), 10, 10, rl.WHITE)

		new_direction := get_input_direction(&last_dir)
		if new_direction.x != 0 || new_direction.y != 0 {
			direction = new_direction
		}

		pos += direction * block_speed
		wrap_check(&pos)
		check_food_collision(&pos, &food.pos)  // Add this line


		rl.DrawRectangle(i32(pos.x), i32(pos.y), 10, 10, rl.GREEN)

		rl.EndDrawing()
	}

	rl.CloseWindow()
}

get_input_direction :: proc(last_direction: ^Direction) -> rl.Vector2 {
	direction := rl.Vector2{}

	if rl.IsKeyPressed(.H) && last_direction^ != .Right {
		direction = {-1, 0}
		last_dir = .Left
	} else if rl.IsKeyPressed(.L) && last_direction^ != .Left {
		direction = {1, 0}
		last_dir = .Right
	} else if rl.IsKeyPressed(.K) && last_direction^ != .Down {
		direction = {0, -1}
		last_dir = .Up
	} else if rl.IsKeyPressed(.J) && last_direction^ != .Up {
		direction = {0, 1}
		last_dir = .Down
	}

	return rl.Vector2Normalize(direction)
}

wrap_check :: proc(position: ^rl.Vector2) {
	if position.x < 0 {
		position.x = f32(rl.GetScreenWidth())
	} else if position.x > f32(rl.GetScreenWidth()) {
		position.x = 0
	} else if position.y < 0 {
		position.y = f32(rl.GetScreenHeight())
	} else if position.y > f32(rl.GetScreenHeight()) {
		position.y = 0
	}
}

check_food_collision :: proc(snake_pos: ^rl.Vector2, food_pos: ^rl.Vector2) {
    snake_rect := rl.Rectangle{
        x = snake_pos.x,
        y = snake_pos.y,
        width = 10,  // Assuming the snake block is 10x10
        height = 10,
    }
    food_rect := rl.Rectangle{
        x = food_pos.x,
        y = food_pos.y,
        width = 10,  // Assuming the food block is 10x10
        height = 10,
    }

    if rl.CheckCollisionRecs(snake_rect, food_rect) {
        current_score += 1
        consume_food()
    }
}

consume_food :: proc() {
	food_exists = false  // This will cause a new food to spawn in the next frame
}

grow_snake :: proc() {

}
