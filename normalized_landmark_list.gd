@tool
class_name NormalizedLandmarkList

var _x: float = 0.0
var _y: float = 0.0
var _z: float = 0.0

func x() -> float: return _x

func y() -> float: return _y

func z() -> float: return _z

func set_x(x: float) -> void:
	_x = x

func set_y(y: float) -> void:
	_y = y

func set_z(z: float) -> void:
	_z = z

func landmark_size() -> int:
	# should return the number of landmarks?
	assert(false, "landmark's seem to be Eigen.Matrix3Xf - also, this should extend the land_mark_list")
	assert(false, "TODO adding landmarks and all that!")
	return 0

func landmark(idx: int) -> Eigen.Matrix3Xf:
	assert(false, "")
	return Eigen.Matrix3Xf()
