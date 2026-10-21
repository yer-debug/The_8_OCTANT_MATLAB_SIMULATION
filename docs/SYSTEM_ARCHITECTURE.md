# System Architecture

## Runtime flow

`main.m` assembles the MATLAB dashboard. Configuration is loaded once, the
scene creates static coordinate geometry, and the initial satellite positions
are passed to the renderers. A `SimulationClock` invokes the frame callback;
each frame computes positions and velocities, samples recent trajectories,
updates scene graphics in place, evaluates the selected field model, and
refreshes the data panel.

```text
simulationConfig
       |
       v
main dashboard <---- user controls
       |
       +---- SimulationClock --> MotionModel --> TrajectoryEngine
       |                                      |
       |                                      v
       +-------------------------------> SceneManager
       |                                  |       |
       |                         renderers       selected state
       |
       +---- FieldVectorEngine --> ElectricFieldModel
                                --> MagneticFieldModel
```

## Module responsibilities

| Area | Responsibility |
| --- | --- |
| `config/simulationConfig.m` | Initial geometry, motion parameters, physical constants, units, colors, and display scales. |
| `core/OctantClassifier.m` | Sign-based open-octant classification and boundary detection. |
| `core/VectorEngine.m` | Cartesian vector operations, properties, and relationships. |
| `dynamics/MotionModel.m` | Deterministic analytic position and velocity for the illustrative model. |
| `dynamics/TrajectoryEngine.m` | Samples the motion model over the configured recent-time window. |
| `dynamics/SimulationClock.m` | Playback timer, pause, reset, step, and speed. |
| `physics/ElectricFieldModel.m` | Point-charge electric field in SI units. |
| `physics/MagneticFieldModel.m` | Infinite straight +Z wire magnetic field in SI units. |
| `physics/FieldVectorEngine.m` | Dispatches field requests and returns defined masks. |
| `visualization/SceneManager.m` | Owns scene handles, visibility state, camera framing, and per-frame updates. |
| `visualization/*Renderer.m` | Draws coordinate planes, vectors, satellites, and fields. |
| `main.m` | Connects user controls to models, scene updates, and numerical readouts. |
| `tests/` | Unit and graphics/UI integration tests. |

## Coordinate and unit boundaries

Positions entered and displayed in the dashboard are in kilometres. The
kinematic model uses seconds and kilometres, so velocity is in km/s. Before
field evaluation, `main.m` applies `positionScaleToMeters`; field equations
therefore receive metres, charge in coulombs, current in amperes, and return
electric field in N/C or magnetic flux density in teslas. Field arrows are
normalized to a display length and must not be read as magnitude-scaled.

## Reproducibility and limitations

The default configuration is deterministic. There is no random initialization
or external data dependency. Timer frames may occur at different wall-clock
times on different machines; all model calculations are functions of the
simulation time and are repeatable for the same inputs. Tests call deterministic
model and clock-step APIs directly where possible.

Satellite motion is a configurable kinematic illustration, not an orbit
integrator. The point-charge and infinite-wire field sources are independent
of satellite motion; the satellites are sample locations, not charge/current
sources. No material models, forces, uncertainty estimates, or numerical field
solvers are included.