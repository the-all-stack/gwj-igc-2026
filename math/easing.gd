class_name Easing

static func easeOutCubicDelta(current: float, target: float, curve_size: float, delta: float) -> float:
	if current == target:
		return target
	var start: float = target + signf(current - target) * curve_size
	var progress: float = 1 - Math.cbrt(1 - (current - start) / (target - start))
	progress = minf(1.0, progress + delta)
	return start + (target - start) * (1 - pow(1 - progress, 3))
