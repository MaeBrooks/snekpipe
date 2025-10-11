@tool
class_name ScreenToMetricSpaceConverter

const Absl = preload("./absl.gd")
const Eigen = preload("./eigen.gd")

const origin_point_location_: OriginPointLocation
const input_source_: InputSource
var canonical_metric_landmarks_: EigenMatrix3Xf
var landmark_weights_: EigenVectorXf
var procrustes_solver_: ProcrustesSolver


# TODO: Tests - How the hell do I test these?
# TODO: refactor c++'s Operator overloading

func _init(
		origin_point_location: OriginPointLocation,
		input_source: InputSource,
		# Eigen::Matrix3Xf&&
		canonical_metric_landmarks: Eigen.Matrix3Xf,
		# Eigen::VectorXf&&
		landmark_weights: Eigen.VectorXf,
		# std::unique_ptr<ProcrustesSolver>
		procrustes_solver: ProcrustesSolver):
	input_source_ = input_source
	origin_point_location_ = origin_point_location
	# std::move(canonical_metric_landmarks)
	canonical_metric_landmarks_ = canonical_metric_landmarks
	# std::move(landmark_weights)
	landmark_weights_ = landmark_weights
	# std::move(procrustes_solver)
	procrustes_solver_ = procrustes_solver

# `screen_landmark_list` into `metric_landmark_list` and estimates
# the `pose_transform_mat`.
#
# Here's the algorithm summary:
#
# (1) Project X- and Y- screen landmark coordinates at the Z near plane.
#
# (2) Estimate a canonical-to-runtime landmark set scale by running the
#     Procrustes solver using the screen runtime landmarks.
#
#     On this iteration, screen landmarks are used instead of unprojected
#     metric landmarks as it is not safe to unproject due to the relative
#     nature of the input screen landmark Z coordinate.
#
# (3) Use the canonical-to-runtime scale from (2) to unproject the screen
#     landmarks. The result is referenced as "intermediate landmarks" because
#     they are the first estimation of the resuling metric landmarks, but are
#     not quite there yet.
#
# (4) Estimate a canonical-to-runtime landmark set scale by running the
#     Procrustes solver using the intermediate runtime landmarks.
#
# (5) Use the product of the scale factors from (2) and (4) to unproject
#     the screen landmarks the second time. This is the second and the final
#     estimation of the metric landmarks.
#
# (6) Multiply each of the metric landmarks by the inverse pose
#     transformation matrix to align the runtime metric face landmarks with
#     the canonical metric face landmarks.
#
# Note: the input screen landmarks are in the left-handed coordinate system,
#       however any metric landmarks - including the canonical metric
#       landmarks, the final runtime metric landmarks and any intermediate
#       runtime metric landmarks - are in the right-handed coordinate system.
#
#       To keep the logic correct, the landmark set handedness is changed any
#       time the screen-to-metric semantic barrier is passed.
func convert(
		screen_landmark_list: NormalizedLandmarkList,
		pcf: PerspectiveCameraFrustum,
		metric_landmark_list: LandMarkList,
		pose_transform_mat: Eigen.Matrix4f
	) -> Absl.Status:

	# RET_CHECK_EQ(screen_landmark_list.landmark_size(), canonical_metric_landmarks_.cols()) <<
	# "The number of landmarks doesn't match the number passed upon initialization!";
	# TODO: These macros are more than just simple asserts!
	assert(screen_landmark_list.landmark_size() == canonical_metric_landmarks_.cols(), \
		"The number of landmarks doesn't match the number passed upon initialization!")

	var screen_landmarks Eigen.Matrix3Xf;
	_ConvertLandmarkListToEigenMatrix(screen_landmark_list, screen_landmarks)

	ProjectXY(pcf, screen_landmarks)
    const depth_offset: float = screen_landmarks.row(2).mean()

    # 1st iteration: don't unproject XY because it's unsafe to do so due to
    #                the relative nature of the Z coordinate. Instead, run the
    #                first estimation on the projected XY and use that scale to
    #                unproject for the 2nd iteration.
	# TODO: Convert code
	assert(false, "Is intermediate_landmarks a variable? is this short hand for " + \
		"Eigen.Matrix3Xf intermediate_landmarks = new Eigen.Matrix3Xf(screen_landmarks)")
    # Eigen.Matrix3Xf intermediate_landmarks(screen_landmarks);
    # ChangeHandedness(intermediate_landmarks);

	# TODO: Convert code
	# TODO: MP_ASSIGN_OR_RETURN
    # MP_ASSIGN_OR_RETURN(const float first_iteration_scale,
    #                    EstimateScale(intermediate_landmarks),
    #                     _ << "Failed to estimate first iteration scale!");
	# ----
	var result = _EstimateScale(intermediate_landmarks)
	if result.is_error():
		return result.error()

	const first_iteration_scale: float = result.value()
	# ---

    # 2nd iteration: unproject XY using the scale from the 1st iteration.
    intermediate_landmarks = screen_landmarks
    _MoveAndRescaleZ(pcf, depth_offset, first_iteration_scale, intermediate_landmarks);
    _UnprojectXY(pcf, intermediate_landmarks);
    _ChangeHandedness(intermediate_landmarks);

    # For face detection input landmarks, re-write Z-coord from the canonical landmarks.
	# InputSource::FACE_DETECTION_PIPELINE
	if input_source_ == InputSource.FACE_DETECTION_PIPELINE:
		var intermediate_pose_transform_mat: Eigen.Matrix4f
		# TODO: Convert code
		# TODO: MP_RETURN_IF_ERROR
		# MP_RETURN_IF_ERROR(procrustes_solver_->SolveWeightedOrthogonalProblem(
		# canonical_metric_landmarks_, intermediate_landmarks,
		# landmark_weights_, intermediate_pose_transform_mat))
		# << "Failed to estimate pose transform matrix!";
		# ----
		var result = procrustes_solver_.SolveWeightedOrthogonalProblem(\
			canonical_metric_landmarks_, \
			intermediate_landmarks, \
			landmark_weights_, \
			intermediate_pose_transform_mat)

		if result.is_error():
			return result.error()
		# ----

		intermediate_landmarks.row(2) = \
			(intermediate_pose_transform_mat * canonical_metric_landmarks_.colwise().homogeneous()) \
			.row(2)

	# TODO: Convert code
	# TODO: MP_ASSIGN_OR_RETURN
	# MP_ASSIGN_OR_RETURN(,
	# EstimateScale(intermediate_landmarks),
	# _ << "Failed to estimate second iteration scale!");
	var result = _EstimateScale(intermediate_landmarks)
	if result.is_error():
		return result.error()

	const second_iteration_scale: float = result.value()

	# Use the total scale to unproject the screen landmarks.
	const total_scale: float = first_iteration_scale * second_iteration_scale
	_MoveAndRescaleZ(pcf, depth_offset, total_scale, screen_landmarks)
	_UnprojectXY(pcf, screen_landmarks)
	_ChangeHandedness(screen_landmarks)

	# At this point, screen landmarks are converted into metric landmarks.
	var metric_landmarks: Eigen.Matrix3Xf = screen_landmarks;

	# TODO: Convert code
	# TODO: MP_RETURN_IF_ERROR
	# MP_RETURN_IF_ERROR(procrustes_solver_->SolveWeightedOrthogonalProblem(
	# 	canonical_metric_landmarks_, metric_landmarks, landmark_weights_,
	# 	pose_transform_mat))
	# << "Failed to estimate pose transform matrix!";
	# ----
	var result = procrustes_solver_.SolveWeightedOrthogonalProblem( \
		canonical_metric_landmarks_, \
		metric_landmarks, \
		landmark_weights_, \
		pose_transform_mat)

	if result.is_error():
		return result.error()
	# ----

	# For face detection input landmarks, re-write Z-coord from the canonical
	# landmarks and run the pose transform estimation again.
	# InputSource::FACE_DETECTION_PIPELINE
	if input_source_ == InputSource.FACE_DETECTION_PIPELINE:
		metric_landmarks.row(2) = \
			(pose_transform_mat * canonical_metric_landmarks_.colwise().homogeneous()) \
			.row(2);

		# TODO: Convert code
		# TODO: MP_RETURN_IF_ERROR
		# MP_RETURN_IF_ERROR(procrustes_solver_->SolveWeightedOrthogonalProblem(
		# 	canonical_metric_landmarks_, metric_landmarks, landmark_weights_,
		# 	pose_transform_mat))
		# << "Failed to estimate pose transform matrix!";
		# ----
		var result = procrustes_solver_->SolveWeightedOrthogonalProblem( \
			canonical_metric_landmarks_, \
			metric_landmarks, \
			landmark_weights_, \p
			pose_transform_mat)

		if result.is_error():
			return result.error()
		# ----

	# Multiply each of the metric landmarks by the inverse pose
	# transformation matrix to align the runtime metric face landmarks with
	# the canonical metric face landmarks.
	metric_landmarks = \
		(pose_transform_mat.inverse() * metric_landmarks.colwise().homogeneous()) \
		.topRows(3);

	_ConvertEigenMatrixToLandmarkList(metric_landmarks, metric_landmark_list)

	# Absl.OkStatus
    return Absl.STATUS_OK

func ProjectXY(
		pcf PerspectiveCameraFrustum,
		landmarks: Eigen.Matrix3Xf) -> void:
	var x_scale: float = pcf.right - pcf.left;
	var y_scale: float = pcf.top - pcf.bottom;
	var x_translation: float = pcf.left;
	var y_translation: float = pcf.bottom;

	if origin_point_location_ == OriginPointLocation::TOP_LEFT_CORNER:
		landmarks.row(1) = float(1) - landmarks.row(1).array()


	landmarks = landmarks.array().colwise() * Eigen.Array3f(x_scale, y_scale, x_scale)

	landmarks.colwise() += Eigen.Vector3f(x_translation, y_translation, float(0.0))

func EstimateScale(landmarks: Eigen.Matrix3Xf) -> Absl.StatusOr[float]:
	var transform_mat: Eigen.Matrix4f

	# TODO: MP_RETURN_IF_ERROR
	# MP_RETURN_IF_ERROR(procrustes_solver_->SolveWeightedOrthogonalProblem(
	#   canonical_metric_landmarks_, landmarks, landmark_weights_, transform_mat))
	#   << "Failed to estimate canonical-to-runtime landmark set transform!";
	assert(procrustes_solver_.SolveWeightedOrthogonalProblem(\
		canonical_metric_landmarks_, \
		landmarks, \
		landmark_weights_, \
		transform_mat),
		"Failed to estimate canonical-to-runtime landmark set transform!")

    return transform_mat.col(0).norm()

static func _MoveAndRescaleZ(
		pcf: PerspectiveCameraFrustum,
		depth_offset: float,
		scale: float,
		landmarks: Eigen.Matrix3Xf) -> void:
	landmarks.row(2) = \
		(landmarks.array().row(2) - depth_offset + pcf.near) \
		/ scale

static func _UnprojectXY(
		pcf: PerspectiveCameraFrustum,
		landmarks: Eigen.Matrix3Xf) -> void:
    landmarks.row(0) = \
        landmarks.row(0).cwiseProduct(landmarks.row(2)) / pcf.near;

    landmarks.row(1) = \
        landmarks.row(1).cwiseProduct(landmarks.row(2)) / pcf.near;

static func _ChangeHandedness(landmarks: Eigen.Matrix3Xf) -> void:
	landmarks.row(2) *= float(-1)

static func _ConvertLandmarkListToEigenMatrix(
		landmark_list: NormalizedLandmarkList,
		eigen_matrix: Eigen.Matrix3Xf) -> void:
	eigen_matrix = Eigen.Matrix3Xf(3, landmark_list.landmark_size()) -> void:

	for i in range(landmark_list.landmark_size()):
		var landmark = landmark_list.landmark(i)
		# TODO: Propbably macro magic
		eigen_matrix(0, i) = landmark.x()
		eigen_matrix(1, i) = landmark.y()
		eigen_matrix(2, i) = landmark.z()

static func _ConvertEigenMatrixToLandmarkList(
		eigen_matrix: Eigen.Matrix3Xf,
		landmark_list: LandmarkList) -> void:
    landmark_list.Clear();

	for i in range(eigen_matrix.cols()):
		var landmark = landmark_list.add_landmark()
		landmark.set_x(eigen_matrix(0, i));
		landmark.set_y(eigen_matrix(1, i));
		landmark.set_z(eigen_matrix(2, i));

