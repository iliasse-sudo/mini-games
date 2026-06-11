import arcade
import random

window = arcade.Window(height=720 , width=720, title="WASD_Square")
window.center_window()


class Cube(arcade.Sprite):
    pass

class Game(arcade.View):
    def __init__(self):
        super().__init__()
        self.background_color = (random.randint(0, 255),
                                 random.randint(0, 255),
                                 random.randint(0, 255))
        
        self.x = self.width / 2
        self.y = self.height / 2
        self.rect_size = 50
        self.speed = 5
        self.speed_mul = 1
        self.keys = set()
        self.color = arcade.color.WHITE


    def on_draw(self):
        self.clear()

        arcade.draw_lbwh_rectangle_filled(
            self.x - (self.rect_size / 2),
            self.y - (self.rect_size / 2),
            self.rect_size,
            self.rect_size,
            self.color
        )

    def on_key_press(self, symbol, modifiers):
        self.keys.add(symbol)
        if modifiers & arcade.key.MOD_SHIFT:
            self.speed_mul = 2
        if symbol == arcade.key.R:
            self.x = self.width / 2
            self.y = self.height / 2
            self.keys.discard(symbol)
        if symbol == arcade.key.SPACE:
            self.color = (random.randint(0, 255),
                          random.randint(0, 255),
                          random.randint(0, 255))


    def on_key_release(self, symbol, modifiers):
        self.keys.discard(symbol)
        if not modifiers & arcade.key.MOD_SHIFT:
            self.speed_mul = 1


    def on_update(self, delta_time):
        if arcade.key.A in self.keys or arcade.key.LEFT in self.keys:
            self.x -= self.speed * self.speed_mul
            if self.x < self.rect_size / 2:
                self.x = self.rect_size / 2
        if arcade.key.W in self.keys or arcade.key.UP in self.keys:
            self.y += self.speed * self.speed_mul
            if self.y > self.height - self.rect_size / 2:
                self.y = self.height - self.rect_size / 2
        if arcade.key.D in self.keys or arcade.key.RIGHT in self.keys:
            self.x += self.speed * self.speed_mul
            if self.x > self.width - self.rect_size / 2:
                self.x = self.width - self.rect_size / 2
        if arcade.key.S in self.keys or arcade.key.DOWN in self.keys:
            self.y -= self.speed * self.speed_mul
            if self.y < self.rect_size / 2:
                self.y = self.rect_size / 2




game = Game()
window.show_view(game)

arcade.run()
