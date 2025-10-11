@tool
class_name Absl

static enum Status {STATUS_OK, STATUS_ERROR}

# Status is just the rust `Result<OK, Err>` - we could just convert stuff to that, as that makes more sense than a "Status" class

# TODO: I know that gdscript has support for stuff like Array[int] and Dict[int, Foo]
#       Can we do Status[]
static class StatusOr:
	var value: Variant = null;
	var _ok: bool = true

	func _init(value: Variant):
		self.value = value

	static func Ok(value: Variant):
		return _init(value)

	static func Err(status: Status):
		var s = _init(null)
		s._ok = false
		return s
