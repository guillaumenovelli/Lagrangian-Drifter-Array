# Lagrangian Drifter Array Simulator & Scale Optimizer (WHIRLS)

An open-science MATLAB modeling framework designed to optimize Lagrangian drifter deployment configurations in dynamic mesoscale and submesoscale features (e.g., ocean dipoles, fronts, and eddies) for the WHIRLS field campaign. 

This tool helps physical oceanographers maximize the high-density yield of pairs and triads across multiple scales, mitigates asynoptic sampling distortion, and ensures straightforward operational navigation for the survey vessel.

## Research Problem & Intent
When deploying drifter arrays to capture submesoscale velocity gradient tensors ($\\\\nabla \\\\mathbf{u}$), traditional rigid geometric layouts are highly sensitive to the exact center of a dipole and can suffer severe geometric distortion due to ship routing delays. This framework allows for:
1. **High-density scaling:** Maintained high pair-density across submesoscale fields while broadening the overall spatial footprint to capture leaking/trapping kinetics inside eddy boundaries.
2. **Operational Simplicity:** Continuous, inline diagonal transit drops that eliminate complex ship maneuvers between core radiator rows.
3. **Multi-Scale Triad Indexing:** Post-deployment geometric analysis to catalog valid observing triads across varying spatial intervals without manual subsetting.

---

## Toolbox Dependencies
This framework requires a standard installation of **MATLAB (R2020a or later)** along with the following toolboxes:
* **Mapping Toolbox** (for the coordinate conversion function `km2deg`)
* **Statistics and Machine Learning Toolbox** (for distance metric and categorization functions `pdist` and `discretize`)

---

## Installation
To use this code within your local workspace or research group:

1. Clone this repository into your preferred working directory:
   bash
   git clone [https://github.com/YOUR-USERNAME/Lagrangian-Drifter-Array-Simulator.git](https://github.com/YOUR-USERNAME/Lagrangian-Drifter-Array-Simulator.git)
2. Open MATLAB and add the repository folder to your path:
addpath(genpath('Lagrangian-Drifter-Array-Simulator'))

## Usage
### 1. Setting Up the Master Parameters
Open the main simulation script and adjust the global deployment parameters inside the %% --- MASTER PARAMETERS --- block:
target_lat = -37.0;   % Estimated dynamic center of the ocean dipole

target_lon = 15.0;    % Estimated dynamic center of the ocean dipole

rotation_deg = -20;   % Heading rotation alignment (align with wind/swell for ship safety)

L_y = 5;              % Vertical spacing (km) between radiator rows

L_x = 5;              % Horizontal node spacing (km) within a row

X_dist = 11;          % Spatial flank distance (km) out to boundary picket fences

### 2. Running the Simulation
Execute the script to generate coordinates, process the ship's bridge routing logistics, and calculate the comprehensive triad scale grouping:
run('whirls_drifter_optimizer.m')

### 3. Interpreting Output Figures & Files
Subplot 1 (Spatial Layout): Visualizes the full array deployment track over geographical lat/lon space.

Subplot 2 (Separation Histogram): Illustrates the exact initial distribution of pair separations across your planned array. 

Bridge Log Text File: Automatically generates a 4-column navigator's reference sheet named WHIRLS_Deployment_Plan_Target Lat_Lon.txt formatted in both Decimal Degrees and Degrees/Decimal Minutes (DDM) for instant consumption by the ship's crew.

Navigation Summary: Outputs total steam line length (in kilometers and Nautical Miles) and total deployment duration assuming a survey baseline speed of 10 knots.

## Geometric Filtering Metrics (Triad Scale Analysis) 
The built-in structural analyzer evaluates all available 3-drifter combinations ($N \\\choose 3$) and dynamically weeds out ill-conditioned, elongated triads that amplify noise in kinematic gradient calculations.The aspect ratio ($AR$) is defined by the longest side relative to the minimum altitude:$$AR = \\\frac{s_{\\\max}^2}{2 \\\times \\\text{Area}}$$ Triads are automatically filtered out if they break the maximum shape threshold ($AR > 5$) or collapse into perfectly collinear structures ($\\\text{Area} \\\le 10^{-4}\\\text{ km}^2$). 
The remaining valid triplets are assigned into scale groups using the representative area scale metric:$$L = \\\sqrt{\\\text{Area}}$$

## Extracting Grouped Scales
Valid triads are stored in the structured cell array triads_by_scale. You can directly extract target scales for downstream calculations (e.g., divergence, vorticity, or strain) as shown below:
% Extract the list of drifter ID triplets belonging to the 2.0 to 5.0 km scale (Bin 4)
target_triads = triads_by_scale{4};
