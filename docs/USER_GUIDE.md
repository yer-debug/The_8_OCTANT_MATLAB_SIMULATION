# User Guide

## Launch

In MATLAB, set the current folder to `OCTANT_VECTOR_DYNAMICS` and run:

```matlab
main
```

The dashboard contains a 3D scene, controls at the right, a selected-object
data strip below the scene, and simulation controls along the bottom.

## Inspect vectors and satellites

- Choose `SAT-01` through `SAT-08` to inspect a moving reference satellite.
- Choose `Custom point` to enter Vx, Vy, and Vz manually. Values are in km.
- The data strip reports coordinates, octant/boundary classification, position
  magnitude and direction, velocity and speed for satellites, and the selected
  electromagnetic field when enabled.
- Points with any zero coordinate are boundary cases, not open octants.
- A zero vector has no direction angles or unit vector.

## Display controls

- `Vector components` shows or hides the dashed component projections.
- `Octant boundaries` shows or hides the coordinate planes and octant labels.
- `Position vector` toggles the custom point's position vector independently.
- `Satellite trails` toggles recent path samples.
- `Velocity vectors` toggles satellite velocity arrows.
- `Field model` selects no field, a point-charge electric field, or an infinite
  +Z wire magnetic field.
- `Camera view` selects the full global extent or focuses on the selected
  satellite/custom point. MATLAB rotate, pan, and zoom tools remain available.

Field arrow length is normalized to show direction. Use the data strip to read
field components and magnitude. At a source singularity, the field is shown as
undefined and no field arrow is drawn.

## Playback

- `Play` starts the timer-driven simulation.
- `Pause` stops advancement without changing the current state.
- `Step` advances by one configured simulation step, multiplied by playback
  speed.
- `Reset` stops playback and returns simulation time to zero.
- The speed slider changes simulation-time advancement per timer tick.

The sample satellites are initialized one per octant. Their periodic motion
can cross coordinate planes, so the current octant is recalculated continuously.
This is illustrative motion, not a physically accurate orbital path.

## Validate

Run the automated suite and Code Analyzer from MATLAB:

```matlab
report = run_validation;
```

The function raises an error on failed tests or analyzer findings. On success,
`report` contains the MATLAB version, test totals, and an empty analyzer-findings
array. See [MATHEMATICAL_MODEL.md](MATHEMATICAL_MODEL.md) for equations, units,
and model assumptions.