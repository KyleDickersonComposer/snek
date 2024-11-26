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

Snake :: struct {
	body:      [dynamic]rl.Vector2,
	direction: rl.Vector2,
	last_dir:  Direction,
}

game_over: bool = false

food: Food
food_exists: bool = false
snake: Snake
BLOCK_SIZE :: 15
BLOCK_SPEED :: 5
current_score := 0

main :: proc() {
	rl.InitWindow(1280, 800, "Snek")
	//rl.ToggleFullscreen()
	rl.HideCursor()
	rl.SetTargetFPS(60)

	init_snake()

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		if game_over && rl.IsKeyPressed(.R) {
			reset_game()
		}

		update_game()
		draw_game()

		rl.EndDrawing()
	}

	rl.CloseWindow()
}

init_snake :: proc() {
	snake.body = make([dynamic]rl.Vector2)
	append(&snake.body, rl.Vector2{f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)})
	snake.direction = {1, 0}
	snake.last_dir = .Right
}

insert_at_front :: proc(arr: ^[dynamic]rl.Vector2, value: rl.Vector2) {
	append(arr, rl.Vector2{})
	copy(arr[1:], arr[0:])
	arr[0] = value
}

update_game :: proc() {
	if game_over {
		return
	}

	if !food_exists {
		food.pos = {
			rand.float32() * f32(rl.GetScreenWidth()),
			rand.float32() * f32(rl.GetScreenHeight()),
		}
		food_exists = true
	}

	new_direction := get_input_direction(&snake.last_dir)
	if new_direction.x != 0 || new_direction.y != 0 {
		snake.direction = new_direction
	}

	new_head := snake.body[0] + snake.direction * BLOCK_SPEED
	wrap_check(&new_head)

	insert_at_front(&snake.body, new_head)
	if check_self_collision(&snake) {
		game_over = true
		return
	}

	if len(snake.body) > current_score + 1 {
		pop(&snake.body)
	}

	check_food_collision(&snake.body[0], &food.pos)
}

draw_game :: proc() {
	rl.DrawRectangle(i32(food.pos.x), i32(food.pos.y), i32(BLOCK_SIZE), i32(BLOCK_SIZE), rl.WHITE)

	for segment in snake.body {
		rl.DrawRectangle(
			i32(segment.x),
			i32(segment.y),
			i32(BLOCK_SIZE),
			i32(BLOCK_SIZE),
			rl.GREEN,
		)
	}

	if game_over {
		game_over_text := "Game Over! Press R to restart"
		text_width := rl.MeasureText(strings.clone_to_cstring(game_over_text), 40)
		rl.DrawText(
			strings.clone_to_cstring(game_over_text),
			i32(rl.GetScreenWidth() / 2 - text_width / 2),
			i32(rl.GetScreenHeight() / 2 - 20),
			40,
			rl.RED,
		)
	}

	score_text := fmt.tprintf("Score: %d", current_score)
	rl.DrawText(strings.clone_to_cstring(score_text), 10, 10, 20, rl.GRAY)
}

check_self_collision :: proc(snake: ^Snake) -> bool {
	head := snake.body[0]
	for i in 1 ..< len(snake.body) {
		if rl.Vector2Equals(head, snake.body[i]) {
			return true
		}
	}
	return false
}

get_input_direction :: proc(last_direction: ^Direction) -> rl.Vector2 {
	direction := rl.Vector2{}

	if (rl.IsKeyPressed(.LEFT) || rl.IsKeyPressed(.H)) && last_direction^ != .Right {
		direction = {-1, 0}
		snake.last_dir = .Left
	} else if (rl.IsKeyPressed(.RIGHT) || rl.IsKeyPressed(.L)) && last_direction^ != .Left {
		direction = {1, 0}
		snake.last_dir = .Right
	} else if (rl.IsKeyPressed(.UP) || rl.IsKeyPressed(.K)) && last_direction^ != .Down {
		direction = {0, -1}
		snake.last_dir = .Up
	} else if (rl.IsKeyPressed(.DOWN) || rl.IsKeyPressed(.J)) && last_direction^ != .Up {
		direction = {0, 1}
		snake.last_dir = .Down
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

check_food_collision :: proc(snake_head: ^rl.Vector2, food_pos: ^rl.Vector2) {
	snake_rect := rl.Rectangle {
		x      = snake_head.x,
		y      = snake_head.y,
		width  = BLOCK_SIZE,
		height = BLOCK_SIZE,
	}
	food_rect := rl.Rectangle {
		x      = food_pos.x,
		y      = food_pos.y,
		width  = BLOCK_SIZE,
		height = BLOCK_SIZE,
	}

	if rl.CheckCollisionRecs(snake_rect, food_rect) {
		current_score += 1
		consume_food()
	}
}

consume_food :: proc() {
	food_exists = false
}

reset_game :: proc() {
	clear(&snake.body)
	init_snake()
	current_score = 0
	food_exists = false
	game_over = false
}
