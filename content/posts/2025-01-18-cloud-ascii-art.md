---
title: "Ascii Art"
description: "Implement a non-naive ascii art"
tags: ["cloud", "image-processing"]
date: "2025-01-18"
---

I've been inactive on writing for a long time, many thins happened. I'm also now AWS SysOps certified, it went better than I thought. Anyway, let's start with the topic of this entry.

I've been working for several months on ascii art, just as a quick introduction to it, ascii art is the process to represent images with ascii characters. You may be wondering how is that possible?, if you think about images, you will remember that it's compound of pixels, a lot of them, if instead of pixels we replace them with ascii characters, would it work?... Yes, but no.

It's the basic idea, but we are gonna deep dive more into this, otherwise I had not been doing that for several months.

<img src="https://raw.githubusercontent.com/HeNeos/heneos.github.io/master/assets/img/cloud/ascii_art/ascii_art_ascii.png" alt="ASCII Art" width="100%" />

## Basic ascii art

Let's start with the basic idea, and then go further from it. If we replace every pixel with a character, the first question is to which character?, how is possible to map every possible pixel (24 bits) to a character (8 bits)?

Let's think for a moment only for a grayscale image, then instead there are only 256 possible pixels, which is much less than $2^{24}$. Now, how can we assign a character to a pixel value? Well, not all ascii characters covers the screen in the same *intensity*, for example, compare this character `-` with `@`, so it makes sense so to assign the characters that less cover the screen with the lowest values in the grayscale (the darker colors) and the brighter pixels with something like `@`.

We have another problem here, despite there are 256 ascii characters, not all of them are printable. However, this is easy to solve, just define ranges where each printable ascii character should map to a grayscale value, you can decide if make this scale linear or not.

And that's it, now you have a way to put ascii characters instead of pixels, so we are done, right? Not really, it's true that now we replaced every character with a pixel and that should work but, a printed ascii character doesn't have the dimensions of a pixel, it depends about the fontsize but in almost all cases, the aspect ratio for a character is not 1:1, it means if you replace every pixel with a character you will see a deformed image, to solve this, easy way is to first modify aspect ratio of the original image, according to your font size, in most cases doubling the width should be enough as a good approximation.

We have another problem, our output image resolution is too big, why? Well, since we discussed before, a character doesn't have the same size as a pixel and depending of your font size it could be bigger, imagine for example if your font takes 12 pixels as height and 8 and width, if you did the rescale to preserve the original aspect ratio of the image then now your output image will be 144 times bigger than before. To solve this issue, you can just downscale the image, reduce the original size so that the output image despite of being multiplied by 144 is still manageable.

We've now solved how to do the ascii art for grayscale images, but not all images are grayscale, most of them are in color, so what can we do? Easy, convert them to grayscale, or use this formula `0.299 Red + 0.587 Green + 0.114 Blue`.

And that's it, it covers a basic ascii art that you can find around the internet.

<img src="https://raw.githubusercontent.com/HeNeos/heneos.github.io/master/assets/img/cloud/ascii_art/heneos_ascii.png" width="80%">

## Colored ascii art

At this point, you're able to have ascii art from any image preserving the aspect ratio and the size, but you notice an issue, most of the details are lost because even when ascii characters can show the `luminance` of the original image, they're not able to show the `color`, so how to solve this?

Instead of printing the ascii character on a text based display, you can print it on a canvas or a created image, then you will have an image with tons of ascii characters that represents your original image. This concept will help us later when we wanna do videos.

In a canvas, you can select to which color you want to print your ascii character, since you already know the height and width of your font, you also know how to moves over the canvas.

<img src="https://raw.githubusercontent.com/HeNeos/heneos.github.io/master/assets/img/cloud/ascii_art/jaden_ascii.png" width="80%">


```py
def process_image(
    image: npt.NDArray[np.uint8],
    char_arrays: list[npt.NDArray[np.str_]],
) -> tuple[list[AsciiImage], AsciiColors, npt.NDArray[np.float64]]:

    # custom grayscale
    gray_array: npt.NDArray[np.float64] = np.clip(
        np.dot(image[..., :3], [0.3090, 0.5670, 0.1240]), 0.0, 255.0
    )

    ascii_chars: list[npt.NDArray[np.str_]] = [
        map_to_char_vectorized(gray_array, char_array)
        for char_array in char_arrays
    ]

    grids: list[AsciiImage] = [ascii_char.tolist() for ascii_char in ascii_chars]
    image_colors: AsciiColors = [row.tolist() for row in image]

    return grids, image_colors, gray_array
```

## Video processing

Now, instead of processing an image, we're going to process a video, this step is fairly simple since this could be summarized as just applying the same idea to all frames and then merge them again.

It's good but take into account two things, a video is commonly compressed to save storage with a lower bitrate. Merging all created images with our ascii art will create a heavy video if you don't apply the appropiate compression.

For all of this stuff related with videos, I recommend to use ffmpeg and create your own small set of functions that call to ffmpeg, you're gonna need it to resize the video, to split/merge frames and to extract/add the audio.

## Dithering

You've probably notices on your videos those ugly color bands. It's just disgusting... it's happening because our character space is not as big as the original pixel one. Hopefully, there are already solutions for that and one of them is applying a noise, which is dithering.

There are many dithering algorithms and you can use whatever you want, I implemented like 5 of them if you wanna try but there are not so noticeable differences, so just use whatever you want.

<img src="https://raw.githubusercontent.com/HeNeos/heneos.github.io/master/assets/img/cloud/ascii_art/david_ascii.png" width="100%">

the abstract method for different strategies will be something like:

```py
from abc import ABC, abstractmethod
from dataclasses import dataclass

import numpy as np
import numpy.typing as npt


@dataclass
class DitheringStrategy(ABC):
    @staticmethod
    @abstractmethod
    def dithering(
        image_array: npt.NDArray[np.float64], quantization_levels: int
    ) -> npt.NDArray[np.float64]:
        pass
```

and can be loaded with the helper function:

```py
from functools import lru_cache
from typing import cast
from importlib import import_module
from ..dithering import DitheringStrategy


class DitheringLoader:
    @staticmethod
    def _get_module_and_class(strategy_name: str) -> tuple[str, str]:
        module_name = f".{strategy_name}"

        class_parts = strategy_name.split("_")
        class_name = f"Dithering{''.join(part.capitalize() for part in class_parts)}"

        return module_name, class_name

    @staticmethod
    @lru_cache(maxsize=None)
    def get_strategy(name: str) -> DitheringStrategy | None:
        try:
            module_name, class_name = DitheringLoader._get_module_and_class(name)
            module = import_module(module_name, package=__package__)
            return cast(DitheringStrategy, getattr(module, class_name))
        except (ImportError, AttributeError):
            return None


def get_dithering_strategy(name: str) -> DitheringStrategy | None:
    return DitheringLoader.get_strategy(name)
```

the implementation for `floyd-steinberg` will be:

```py
from dataclasses import dataclass

import numpy as np
import numpy.typing as npt
from numba import jit

from . import DitheringStrategy


@dataclass
class DitheringFloydSteinberg(DitheringStrategy):
    name = "floyd_steinberg"

    @staticmethod
    @jit(
        "float64[:, :](float64[:, :], int64)",
        nopython=True,
        nogil=True,
        fastmath=True,
        cache=True,
    )
    def dithering(
        image_array: npt.NDArray[np.float64], quantization_levels: int
    ) -> npt.NDArray[np.float64]:
        height: int = image_array.shape[0]
        width: int = image_array.shape[1]

        scale: float = 255 / (quantization_levels - 1)

        for row in range(height):
            for column in range(width):
                old_pixel = image_array[row, column]
                new_pixel = np.round(old_pixel / scale) * scale
                image_array[row, column] = new_pixel
                error = old_pixel - new_pixel
                if column + 1 < width:
                    image_array[row, column + 1] += error * 7 / 16
                if row + 1 < height and column > 0:
                    image_array[row + 1, column - 1] += error * 3 / 16
                if row + 1 < height:
                    image_array[row + 1, column] += error * 5 / 16
                if row + 1 < height and column + 1 < width:
                    image_array[row + 1, column + 1] += error * 1 / 16
        image_array = np.clip(image_array, 0.0, 255.0)

        return image_array
```

and in the `process_image` just add:

```py
    if dithering_strategy is not None:
        gray_array = dithering_strategy.dithering(gray_array, len(char_arrays[0]))
```

## Edge detection

At this point, you already have a nice ascii art generator, but there is a still a thing missing. Edges.

It's nice that our ascii art can capture color and luminance, but it's not telling use about edges, of course originally pixels also didn't show us them but it's because the original image has a higher resolution than the distorted for the ascii processing, so we need to use some of our ascii characters as edges, sadly we don't have many, only: `_/|\`.

Now the question is, how can we detect edges? Well that's an old and popular topic, there are many filters to extract those edges, use difference of gaussians and sobel filter to capture it, with that now you can get the angle of each pixel and then map the angles to our for ascii characters. Replace those characters with the initial ascii art and that's it.

```py
from dataclasses import dataclass
import numpy.typing as npt
import numpy as np


@dataclass
class EdgeDetection:
    canny_array: npt.NDArray[np.float64] | None = None
    angles: npt.NDArray[np.float64] | None = None
    magnitudes: npt.NDArray[np.float64] | None = None

    def apply_canny(self, img_array: npt.NDArray[np.uint8]) -> None:
        from cv2 import Canny

        self.canny_array = Canny(img_array, 100, 200).astype(np.float64)

    def apply_sobel(self, dog_array: npt.NDArray[np.float64]) -> None:
        from modules.edge_detection.sobel import sobel_filter

        self.angles, self.magnitudes = sobel_filter(dog_array)
```

and the sobel filter:

```py
import numpy as np
import numpy.typing as npt

from numba import njit
from cv2 import Sobel, CV_64F


@njit(fastmath=True, cache=True)
def calculate_magnitudes_and_angles(
    grad_x: npt.NDArray[np.float64],
    grad_y: npt.NDArray[np.float64],
) -> tuple[npt.NDArray[np.float64], npt.NDArray[np.float64]]:
    magnitudes = np.sqrt(grad_x**2 + grad_y**2)
    max_value = np.max(magnitudes)
    if max_value > 0:
        magnitudes /= max_value
    angles = np.arctan2(grad_y, grad_x) * 180 / np.pi
    return angles, magnitudes


def sobel_filter(
    dog_array: npt.NDArray[np.float64],
) -> tuple[npt.NDArray[np.float64], npt.NDArray[np.float64]]:
    grad_x = Sobel(dog_array, CV_64F, 1, 0, ksize=3)
    grad_y = Sobel(dog_array, CV_64F, 0, 1, ksize=3)

    angles, magnitudes = calculate_magnitudes_and_angles(grad_x, grad_y)

    return angles, magnitudes
```

so in the `process_image`, add:

```py
    edge_detection_parameters: EdgeDetection = EdgeDetection()
    if edge_detection:
        edge_detection_parameters.apply_canny(image)
        edge_detection_parameters.apply_sobel(gray_array)
```

## Color correction

Even if we apply the best possible ascii replacement for the pixels, the image will still contain some pixels from the background color, in this case, it's black; it makes that the ascii art image to looks darker. To improve this, we can apply some enhancements to the colors of the ascii image, for that I've implemented some post processing strategies: `brightness`, `contrast`, `exposure` and `saturation`.

```py
from abc import ABC, abstractmethod
from dataclasses import dataclass
from enum import Enum

from numpy import uint8
from numpy.typing import NDArray


class PostProcessingStrategyName(Enum):
    BRIGHTNESS = "brightness"
    CONTRAST = "contrast"
    EXPOSURE = "exposure"
    SATURATION = "saturation"


@dataclass
class PostProcessingStrategy(ABC):
    name: PostProcessingStrategyName

    @abstractmethod
    def apply(self, image: NDArray[uint8], value: float) -> NDArray[uint8]:
        """Apply a post-processing effect to an image.

        Args:
            image: The input image as a NumPy array (BGR format).
            value: The intensity of the effect.

        Returns:
            The processed image as a NumPy array.

        """
```

then you can load them using a helper function:

```py
from functools import cache
from importlib import import_module
from typing import cast

from numpy import uint8
from numpy.typing import NDArray

from . import PostProcessingStrategy


class PostProcessingLoader:
    @staticmethod
    def _get_module_and_class(strategy_name: str) -> tuple[str, str]:
        module_name: str = f".{strategy_name}"
        class_name: str = strategy_name.capitalize()
        return module_name, class_name

    @staticmethod
    @cache
    def get_strategy(name: str) -> PostProcessingStrategy | None:
        try:
            module_name, class_name = PostProcessingLoader._get_module_and_class(name)
            module = import_module(module_name, package=__package__)
            strategy_class = getattr(module, class_name)
            return cast("PostProcessingStrategy", strategy_class())
        except (ImportError, AttributeError):
            return None


def get_post_processing_strategy(name: str) -> PostProcessingStrategy | None:
    return PostProcessingLoader.get_strategy(name)


def apply_post_processing(image: NDArray[uint8]) -> NDArray[uint8]:
    post_processing_parameters: dict[str, float] = {
        "brightness": 6.0,
        "contrast": 1.28,
        "saturation": 1.22,
        "exposure": 1.18,
    }

    for filter_name, value in post_processing_parameters.items():
        filter_strategy: PostProcessingStrategy | None = get_post_processing_strategy(
            filter_name,
        )
        if filter_strategy:
            image = filter_strategy.apply(image, value)
    return image
```

## Further

I've just explained what to do, and not exactly how to do, and that's because in the implementation is the joyness of this. Try to do the optimizations for yourself, be aware that despite python could be a good idea because of the libraries for image processing, it's really slow, it could work fast for images but you will suffer in videos.

