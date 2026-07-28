# Walk-right row generation brief

Use case: stylized-concept
Asset type: native pixel-art animation source strip for a macOS Dock mascot
Primary request: Create exactly six separated full-body animation frames of the supplied chibi character in one horizontal row, facing and walking to the right through a complete contact, down, passing, up, opposite-contact, passing cadence.
Input image: the supplied 80x80 sprite is the immutable identity and style reference.
Scene/backdrop: perfectly flat solid `#FF00FF` chroma-key background, uniform across the entire image.
Style/medium: crisp native pixel art with hard square pixel clusters, no antialiasing, no smoothing, no subpixel texture.
Composition: exactly six equally sized frame slots from left to right; one complete centered character per slot; identical scale, head/body proportions, ground baseline, and generous separation; no boxes, labels, borders, or guide marks.
Palette: preserve the reference's dark asymmetric hair, separate square black glasses, warm face, navy-and-white jacket, gray trousers, and navy shoes. Do not redesign or simplify the face.
Constraints: same character in all six frames; clearly face right; alternate the feet; contact feet share one baseline; preserve temporal order; first and last frames loop without a teleport; use body and limb poses only.
Avoid: facing front or left, running or exaggerated raised knees, pumping arms, size changes, baseline drift, foot sliding, repeated static poses, text, numbers, frame labels, scenery, floor, cast shadow, contact shadow, speed lines, dust, motion trails, blur, glow, gradients, checkerboard, stray pixels, detached effects, magenta anywhere in the character.

