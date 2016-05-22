// Physics utilities for use in scripts

declare function physics_localg {
  return constant():G * (ship:body:mass / (ship:altitude + body:radius)^2).
}

declare function physics_localFg {
  return ship:mass * physics_localg().
}
