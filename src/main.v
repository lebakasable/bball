module main

import math
import math.vec { Vec2, vec2 }
import strings
import term
import time

enum Pixel {
	back
	fore
}

const width = 64
const height = 32

fn fill(mut display []Pixel, p Pixel) {
	for mut pixel in display {
		pixel = p
	}
}

fn (v Vec2[f64]) map(f fn (x f64) f64) Vec2[f64] {
	return vec2(f(v.x), f(v.y))
}

fn circle(mut display []Pixel, c Vec2[f64], r f64) {
	b := c.sub_scalar(r).map(math.floor)
	e := c.add_scalar(r).map(math.ceil)

	for y := b.y; y <= e.y; y++ {
		for x := b.x; x <= e.x; x++ {
			d := c - vec2(x, y).add_scalar(0.5)
			if d.x*d.x + d.y*d.y <= r*r {
				if 0 <= x && x < width && 0 <= y && y < height {
					display[int(y)*width + int(x)] = .fore
				}
			}
		}
	}
}

fn show(display []Pixel) {
	mut row := strings.new_builder(width)
	table := {
		Pixel.back: {
			Pixel.back: ` `
			Pixel.fore: `_`
		}
		Pixel.fore: {
			Pixel.back: `^`
			Pixel.fore: `C`
		}
	}

	for y in 0..height/2 {
		for x in 0..width {
			t := display[y*2*width + x]
			b := display[(y*2 + 1)*width + x]
			row.write_rune(table[t][b])
		}
		println(row)
		row.clear()
	}
}

fn back() {
	term.cursor_back(width)
	term.cursor_up(height/2)
}

const fps = 15
const radius = height/4.0
const weight = 200.0
const dt = 1.0/fps
const damper = -0.80

fn main() {
	mut display := []Pixel{len: width*height}

	mut pos := vec2(radius, radius)
	mut vel := vec2(50.0, 0.0)
	gravity := vec2(0.0, weight)

	for pos.x < width + radius + radius/2 {
		vel += gravity.mul_scalar(dt)
		pos += vel.mul_scalar(dt)

		if pos.y > height - radius {
			pos.y = height - radius
			vel.y *= damper
		}

		fill(mut display, .back)
		circle(mut display, pos, radius)
		show(display)
		back()

		time.sleep(1000*time.millisecond/fps)
	}
}
