package main

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

Direction :: enum {
	None,
	Left,
	Right,
	Up,
	Down,
}

last_dir: Direction = .Left

current_score := 0

main :: proc() {
	rl.InitWindow(900, 700, "Snek")
	rl.SetTargetFPS(60)

	pos := rl.Vector2{f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)}

	block_speed: f32 = 10

	for !rl.WindowShouldClose() {
		rl.ClearBackground(rl.BLACK)

		time_str := fmt.tprintf("%.2f", rl.GetTime())
		score := fmt.tprintf("Score: %d", current_score)

		direction := get_input_direction()
		move_2d(&pos, direction, block_speed)
		wrap_check(&pos)

		rl.DrawRectangle(i32(pos.x), i32(pos.y), 10, 10, rl.GREEN)

		rl.DrawText(direction_to_string(last_dir), 1, 0, 20, rl.RAYWHITE)
		rl.DrawText(
			strings.clone_to_cstring(time_str),
			rl.GetScreenWidth() / 2 - 15,
			0,
			20,
			rl.RAYWHITE,
		)
		rl.DrawText(strings.clone_to_cstring(score), rl.GetScreenWidth() - 100, 0, 20, rl.WHITE)

		print_pos := fmt.tprintf("(%.2f, %.2f)", pos.x, pos.y)
		rl.DrawText(strings.clone_to_cstring(print_pos), 0, 120, 20, rl.WHITE)

		rl.EndDrawing()
	}

	rl.CloseWindow()
}

move_2d :: proc(character_pos: ^rl.Vector2, direction: rl.Vector2, speed: f32) {
	character_pos^ += direction * speed
}

get_input_direction :: proc() -> rl.Vector2 {
	direction := rl.Vector2{}

	if rl.IsKeyDown(.H) {
		direction.x -= 1
		last_dir = .Left
	}
	if rl.IsKeyDown(.L) {
		direction.x += 1
		last_dir = .Right
	}
	if rl.IsKeyDown(.K) {
		direction.y -= 1
		last_dir = .Up
	}
	if rl.IsKeyDown(.J) {
		direction.y += 1
		last_dir = .Down
	}

	return rl.Vector2Normalize(direction)
}

direction_to_string :: proc(dir: Direction) -> cstring {
	switch dir {
	case .None:
		return "None"
	case .Left:
		return "Left"
	case .Right:
		return "Right"
	case .Up:
		return "Up"
	case .Down:
		return "Down"
	}
	return "Unknown"
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

move_on_tick :: proc() {

}

reset_game :: proc() {

}
