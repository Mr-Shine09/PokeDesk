# Idle row generation brief

Use case: stylized-concept
Asset type: native pixel-art animation source strip for a macOS Dock mascot
Primary request: Create exactly four separated full-body animation frames of the supplied chibi character in one horizontal row, showing a calm standing idle loop: neutral stand, tiny downward breath, one blink, return to neutral.
Input image: the supplied 80x80 sprite is the immutable identity and style reference.
Scene/backdrop: perfectly flat solid `#FF00FF` chroma-key background, uniform across the entire image.
Style/medium: crisp native pixel art with hard square pixel clusters, no antialiasing, no smoothing, no subpixel texture.
Composition: exactly four equally sized frame slots from left to right; one complete centered character per slot; identical character scale, head/body proportions, ground baseline, and generous separation; no boxes, labels, borders, or guide marks.
Palette: preserve the reference's dark asymmetric hair, separate square black glasses, warm face, navy-and-white jacket, gray trousers, and navy shoes. Do not redesign or simplify the face.
Constraints: same character in all four frames; all feet on one shared baseline; subtle motion only; every body fully visible; frame 1 and frame 4 must loop cleanly; no new props.
Avoid: walking, waving, turning, jumping, sitting, dramatic gestures, size changes, baseline drift, foot sliding, duplicate identical frames, text, numbers, frame labels, scenery, floor, cast shadow, contact shadow, glow, blur, gradients, checkerboard, stray pixels, detached effects, magenta anywhere in the character.

