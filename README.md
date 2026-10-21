# Octant & Vector Dynamics

Stage 8 of a MATLAB R2026a scientific visualization project. The interactive
workbench demonstrates Cartesian octants, vector mathematics and projections,
eight moving satellite markers, velocity vectors, rolling trajectory trails,
playback controls, point-charge/wire electromagnetic field overlays, and a
configurable engineering dashboard. Satellite motion and field sources are
teaching examples, not a physically coupled satellite or orbital model.

## Run

From MATLAB, change the current folder to this project and run:

```matlab
main
```

Choose a satellite or `Custom point` from the selector. Edit Vx, Vy, and Vz to
inspect another vector; the inspector recalculates its octant and vector data.
The checkboxes toggle component projections, satellite trails, velocity
vectors, the position vector, and octant boundaries. Choose Global view or
Selected octant from the camera selector. Use Play, Pause, Reset, and Step to
control simulation time; adjust the speed slider to change playback rate. The
field selector shows a point-charge electric field or an infinite +Z wire's
magnetic field. Field arrows show direction; the data panel reports field
components and magnitude in SI units.

## Test

From the project directory in MATLAB:

```matlab
report = run_validation;
```

The reproducible validation entry point runs the unit/integration suite and
MATLAB Code Analyzer, then returns the MATLAB version, test totals, and any
analyzer findings. The suite covers octants, vector math, motion, fields,
graphics, and interactive controls.

## Project layout

- `main.m`: interactive MATLAB figure and inspector
- `config/`: display defaults
- `core/`: octant classification and vector calculations
- `visualization/`: coordinate scene and vector renderers
- `physics/`: idealized electric and magnetic field models
- `dynamics/`: illustrative motion, trajectory sampling, and simulation clock
- `tests/`: MATLAB unit and interaction tests
- `docs/`: mathematical model, system architecture, and user guide

## Conventions and scope

The octant numbering follows the sign convention documented in
[`docs/MATHEMATICAL_MODEL.md`](docs/MATHEMATICAL_MODEL.md). A point with any
zero coordinate is a boundary point, not an open octant. Direction angles are
the angles with the positive X, Y, and Z axes, in degrees. This is an
illustrative geometry tool; it does not claim orbital or electromagnetic
physical accuracy. The periodic motion model is a teaching example for
position, velocity, and octant transitions; it does not model gravity, orbital
forces, or perturbations. Read the [user guide](docs/USER_GUIDE.md),
[architecture](docs/SYSTEM_ARCHITECTURE.md), and
[mathematical model](docs/MATHEMATICAL_MODEL.md) before interpreting results.# The_8_OCTANT_MATLAB_SIMULATION
