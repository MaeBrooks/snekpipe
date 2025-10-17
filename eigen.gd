class_name Eigen

# TODO: Collect all areas where eigen is used
# TODO: Create dummies for all the functions / op overloads
# TODO: Create tests
# TODO: Implement functions

# See: https://libeigen.gitlab.io/eigen/docs-nightly/group__matrixtypedefs.html

#  __  __       _        _      _
# |  \/  | __ _| |_ _ __(_)_  _( )___
# | |\/| |/ _` | __| '__| \ \/ /// __|
# | |  | | (_| | |_| |  | |>  <  \__ \
# |_|  |_|\__,_|\__|_|  |_/_/\_\ |___/

# 3×Dynamic matrix of type float
static class Matrix3Xf:
	var data = PackedVector3Array([Vector3(), Vector3(), Vector3()])

	func x() -> float:
		assert(false, "TODO how to do x")
		return data.get(0)

	func y() -> float:
		assert(false, "TODO how to do y")
		return data.get(1)

	func z() -> float:
		assert(false, "TODO how to do z")
		return data.get(2)

	func mult(transform: Transform3D) -> Matrix3Xf:
		return self.data * transform

	func row(idx: int) -> Vector3:
		assert(false, "TODO row")
		return self.data[idx]

	func cols(idx: int) -> Vector3:
		assert(false, "TODO cols")
		return self.data[idx]

	static func copy(that: Matrix3Xf) -> Matrix3Xf:
		var matrix = Matrix3Xf()
		matrix.data = that.data.duplicate()
		return matrix


# 4 4×4 matrix of type float.
static class Matrix4f:
	var data = PackedVector4Array([Vector4(), Vector4(), Vector4(), Vector4()])

#     _
#    / \   _ __ _ __ __ _ _   _ ___
#   / _ \ | '__| '__/ _` | | | / __|
#  / ___ \| |  | | | (_| | |_| \__ \
# /_/   \_\_|  |_|  \__,_|\__, |___/
#                         |___/

static class Array3f:
	var data = PackedFloat32Array([0.0, 0.0, 0.0])

# __     __        _
# \ \   / /__  ___| |_ ___  _ __ ___
#  \ \ / / _ \/ __| __/ _ \| '__/ __|
#   \ V /  __/ (__| || (_) | |  \__ \
#    \_/ \___|\___|\__\___/|_|  |___/

static class VectorXf:
	var data = PackedFloat32Array()

static class Vector3f extends Array3f:
	pass

# TODO: I have no idea what is happening here!
func cwiseProduct(a: Matrix3Xf, b: Matrix3Xf) -> Matrix3Xf:
	# in c++ this is a:
	# Matrix3Xf a = ...
	# Matrix3Xf b = ...
	# Matrix3Xf c = a.cwiseProduct(b)

	assert(false, "TODO: I can't even figure out what a this method does!")
	pass
