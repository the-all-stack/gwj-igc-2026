class_name Math

static func cbrt(x: float) -> float:
	return signf(x) * pow(absf(x), 1.0/3.0)
