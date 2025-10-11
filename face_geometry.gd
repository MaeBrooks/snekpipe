@tool
class_name FaceGeometry

const kDegreesToRadians: float = PI / float(180.0)

const Absl = preload("./absl.gd")
const Eigen = preload("./eigen.gd")
const ScreenToMetricSpaceConverter = preload("./screen_to_metric_space_converter.gd")

# TODO: Move these functions to their own files

# Macro! Oh boy! What an exciting missing feature of gdscript :c
func RET_CHECK_EQ():
	pass

class PerspectiveCamera:
	near() -> float:
		pass

	far() -> float:
		pass

	vertical_fov_degrees() -> float:
		pass

class OriginPointLocation:
	pass

class ProcrustesSolver:
	pass

class LandMarkList:
	pass

class NormalizedLandmarkList:
	func landmark_size() -> int:
		pass

class PerspectiveCameraFrustum:
	var left: float = 0.0
	var right: float = 0.0
	var bottom: float = 0.0
	var top: float = 0.0
	var near: float = 0.0
	var far: float = 0.0

	# NOTE: all arguments must be validated prior to calling this constructor.
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
