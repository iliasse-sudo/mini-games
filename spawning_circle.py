import arcade
import random
import math
from enum import Enum


window = arcade.Window(height=720, width=720, title="spawning_circle")
window.center_window()


class states(int, Enum):
    stopped = 0
    running = 1
    ended = 2


class Game(arcade.View):
    def __init__(self):
        super().__init__()

        self.state = states.stopped
        self.score = 0
        self.clicks = 0
        self.time = 30
        self.remaining_time = self.time
        self.background_color = arcade.color.GREEN

        self.target_radious = 25
        self.target_x = random.randint(self.target_radious, self.width - self.target_radious)
        self.target_y = random.randint(self.target_radious, self.height - self.target_radious)
        self.target = [
            (25, arcade.color.RED),
            (20, arcade.color.WHITE),
            (15, arcade.color.RED),
            (10, arcade.color.WHITE),
            (5, arcade.color.RED)
        ]

        self.start_heigth = 50
        self.start_width = 150
        self.start_x = self.width / 2 - self.start_width / 2
        self.start_y = 200
        self.start_color = arcade.color.RED

        self.res_heigth = 50
        self.res_width = 200
        self.res_x = self.width / 2 - self.res_width / 2
        self.res_y = 200
        self.res_color = arcade.color.RED

    def on_draw(self):
        self.clear()


        if self.state == states.stopped:
            arcade.draw_lbwh_rectangle_filled(
                self.start_x,
                self.start_y,
                self.start_width,
                self.start_heigth,
                self.start_color
            )
            text = arcade.Text("START",
                        self.start_x + 10,
                        self.start_y + 10,
                        font_size=30,
                        width=100)
            text.draw()

        if self.state == states.running:
            for radious, color in self.target:
                arcade.draw_circle_filled(
                    self.target_x,
                    self.target_y,
                    radious,
                    color,
                )

            arcade.Text(f"Score: {self.score}",
                        self.width - 200,
                        self.height - 40,
                        font_size=20,
                        width=100).draw()

            arcade.Text(f"Time left: {int(self.remaining_time)}",
                        self.width - 200,
                        self.height - 70,
                        font_size=20,
                        width=100).draw()

        if self.state == states.ended:

            arcade.draw_lbwh_rectangle_filled(
                self.res_x,
                self.res_y,
                self.res_width,
                self.res_heigth,
                self.res_color
            )

            text = arcade.Text("RESTART",
                               self.res_x + 10,
                               self.res_y + 10,
                               font_size=30,
                               width=100)
            text.draw()

            arcade.Text(f"Game Over!!!",
                        self.width / 2 - 150,
                        self.height / 2 + 50,
                        font_size=35,
                        width=100).draw()

            arcade.Text(f"Score: {self.score}",
                        self.width / 2 - 90,
                        self.height / 2 - 40,
                        font_size=20,
                        width=100).draw()

            arcade.Text(f"Total Time: {int(self.time)}",
                        self.width / 2 - 90,
                        self.height / 2 - 70,
                        font_size=20,
                        width=100).draw()


    def on_key_press(self, symbol, modifiers):
        _ = modifiers
        if symbol in (arcade.key.Q, arcade.key.ESCAPE):
            print("Goodbye!")
            exit()

    def on_mouse_press(self, x, y, button, modifiers):
        _ = modifiers
        if button == arcade.MOUSE_BUTTON_LEFT:

            if self.state == states.running:
                dis = math.sqrt(((x - self.target_x) * (x - self.target_x)) + ((y - self.target_y) * (y - self.target_y)))
                self.clicks += 1
                if dis <= self.target_radious:
                    self.score += 1
                    self.target_x = random.randint(self.target_radious, self.width - self.target_radious)
                    self.target_y = random.randint(self.target_radious, self.height - self.target_radious)

            if self.state == states.stopped:
                if self.start_x <= x <= self.start_x + self.start_width and self.start_y <= y <= self.start_y + self.start_heigth:
                    self.state = states.running
                    self.remaining_time = self.time

            if self.state == states.ended:
                if self.res_x <= x <= self.res_x + self.res_width and self.res_y <= y <= self.res_y + self.res_heigth:
                    self.state = states.running
                    self.remaining_time = self.time
                    self.score = 0

    def on_update(self, delta_time):
        if self.state == states.running:
            if self.remaining_time <= 0:
                self.state = states.ended
            self.remaining_time -= delta_time


game = Game()
window.show_view(game)

arcade.run()
