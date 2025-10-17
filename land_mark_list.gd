@tool
class_name LandMarkList

const Eigen = preload("./eigen.gd")

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

func add_landmark() -> Eigen.Matrix3Xf:
	var landmark = Eigen.Matrix3Xf()
	assert(false, "TODO: add landmark!")
	return landmark
