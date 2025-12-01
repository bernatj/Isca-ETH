# Isca Fixed SST Experiments

Custom configuration of the [Isca](https://github.com/ExeClim/Isca) framework for running fixed sea-surface-temperature (SST) experiments. All experiment definitions used in the companion publications live in `exp/fixed_sst_clim/`. The `fixed_sst_clim.py` script is the main driver, while the other Python files in that directory adjust SST patterns, physics packages, and diagnostics for each study.

## Repository Layout

- `exp/`: Python scripts used to configure and run experiments. The configurations cited in the papers live inside `exp/fixed_sst_clim/`; for example, `exp/fixed_sst_clim/fixed_sst_clim_nudging.py` sets up a nudging case. File names do not always perfectly reflect the final tweaks, because the experiments evolved over time.
- `src/`: The Isca source tree with my modifications. The main change is in `atmosphere.F90`, which adds the zonal-mean stratospheric wind nudging. Additional adjustments appear in the RRTM modules to keep the stratospheric water vapour tracer from overcooling, and the build uses a 3D ERA5 ozone climatology to better capture the polar vortex.
- `input/`: All input datasets referenced by the experiment scripts (land masks, SSTs, ice concentration, ozone, etc.).

## Citations

If you use this code, please cite the upstream project and the studies that motivated these configurations:

> Vallis, G. K., Colyer, G., Geen, R., Gerber, E., Jucker, M., Maher, P., Paterson, A., Pietschnig, M., Penn, J., & Thomson, S. I. (2018). *Isca, v1.0: a framework for the global modelling of the atmospheres of Earth and other planets at varying levels of complexity*. Geoscientific Model Development, 11, 843–859. [https://github.com/ExeClim/Isca](https://github.com/ExeClim/Isca). [https://doi.org/10.5194/gmd-11-843-2018](https://doi.org/10.5194/gmd-11-843-2018)

- Paper where I've used Isca:

> Jiménez-Esteve, B., & Domeisen, D. I. V. (2019). *Nonlinearity in the North Pacific Atmospheric Response to a Linear ENSO Forcing*. Geophysical Research Letters, 46(4), 2271–2281. [https://doi.org/10.1029/2018GL081226](https://doi.org/10.1029/2018GL081226)

> Finke, K., Jiménez-Esteve, B., Taschetto, A. S., Ummenhofer, C. C., Bumke, K., & Domeisen, D. I. V. (2020). *Revisiting remote drivers of the 2014 drought in South-Eastern Brazil*. Climate Dynamics, 55(11–12), 3197–3211. [https://doi.org/10.1007/s00382-020-05442-9](https://doi.org/10.1007/s00382-020-05442-9)

> Jiménez-Esteve, B., & Domeisen, D. I. V. (2020). *Nonlinearity in the tropospheric pathway of ENSO to the North Atlantic*. Weather and Climate Dynamics, 1, 225–245. [https://doi.org/10.5194/wcd-1-225-2020](https://doi.org/10.5194/wcd-1-225-2020)

> Casselman, J. W., Jiménez-Esteve, B., & Domeisen, D. I. V. (2022). *Modulation of the El Niño teleconnection to the North Atlantic by the tropical North Atlantic during boreal spring and summer*. Weather and Climate Dynamics, 3, 1077–1096. [https://doi.org/10.5194/wcd-3-1077-2022](https://doi.org/10.5194/wcd-3-1077-2022)
