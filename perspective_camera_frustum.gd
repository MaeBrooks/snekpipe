@tool
class_name PerspectiveCameraFrustum

const PerspectiveCamera = preload("./perspective_camera.gd")

var left:   float = 0.0
var right:  float = 0.0
var bottom: float = 0.0
var top:    float = 0.0
var near:   float = 0.0
var far:    float = 0.0

# NOTE: All arguments must be validated prior to calling this constructor.
func _init(camera: PerspectiveCamera, int frame_width, int frame_height):
	const height_at_near: float = \
		float(2.0) * camera.near() * \
		tan(float(0.5) * kDegreesToRadians * camera.vertical_fov_degrees())

	const width_at_near: float = \
		frame_width * height_at_near / frame_height

	left = float(-0.5) * width_at_near;
	right = float(0.5) * width_at_near;
	bottom = float(-0.5) * height_at_near;
	top = float(0.5) * height_at_near;
	near = perspective_camera.near();
	far = perspective_camera.far();
