import pixel_display.pixel-display show *

interface Sized:
  width -> int
  height -> int

interface Display extends Sized:
  display -> PixelDisplay