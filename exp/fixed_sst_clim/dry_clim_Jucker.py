import numpy as np
import os
from gfdl.experiment import Experiment, DiagTable
import f90nml

#Define our base experiment to compile
base_dir=os.getcwd()
GFDL_BASE        = os.environ['GFDL_BASE']

baseexp = Experiment('fixed_sst_clim_newtowian_relaxation', overwrite_data=False)

#Add any input files that are necessary for a particular experiment.
baseexp.inputfiles = [os.path.join(GFDL_BASE,'input/land_masks/era_land_t42.nc'),os.path.join(GFDL_BASE,'input/rrtm_input_files/ozone_null.nc'),
                      os.path.join(GFDL_BASE,'input/sst/sst_clim_ersst.nc'), os.path.join(GFDL_BASE,'input/seaice/siconc_clim_eraint.nc')]

#Tell model how to write diagnostics
diag = DiagTable()
diag.add_file('atmos_daily', 1, 'days', time_units='days')

#Tell model which diagnostics to write
diag.add_field('atmosphere', 'precipitation' ,time_avg=True)
diag.add_field('mixed_layer', 't_surf', time_avg=True)

diag.add_field('dynamics', 'ps', time_avg=True)
diag.add_field('dynamics', 'bk')
diag.add_field('dynamics', 'pk')
diag.add_field('dynamics', 'omega',time_avg=True)
diag.add_field('dynamics', 'sphum',time_avg=True)
diag.add_field('dynamics', 'ucomp',time_avg=True)
diag.add_field('dynamics', 'vcomp',time_avg=True)
diag.add_field('dynamics', 'temp',time_avg=True)
diag.add_field('dynamics', 'vor',time_avg=True)
diag.add_field('dynamics', 'height',time_avg=True)
diag.add_field('dynamics', 'height_half',time_avg=True)
diag.add_field('dynamics', 'slp',time_avg=True)

diag.add_field('rrtm_radiation', 'olr',time_avg=True)
diag.add_field('rrtm_radiation', 'flux_sw',time_avg=True)
diag.add_field('rrtm_radiation', 'flux_lw',time_avg=True)
diag.add_field('rrtm_radiation', 'tdt_rad',time_avg=True)

baseexp.use_diag_table(diag)

#Compile model if not already compiled
baseexp.compile()

#Empty the run directory ready to run
baseexp.clear_rundir()

#Define values for the 'core' namelist
baseexp.namelist['main_nml'] = f90nml.Namelist({
     'days'   : 360,
     'hours'  : 0,
     'minutes': 0,
     'seconds': 0,
     'dt_atmos':720,
     'current_date' : [0001,1,1,0,0,0],
     'calendar' : 'thirty_day'
})


baseexp.namelist['atmosphere_nml']['idealized_moist_model'] = False  #tells the model to use newtonian relaxation

baseexp.namelist['hs_forcing_nml'] = f90nml.Namelist({

   # 't_zero': 315.,    # temperature at reference pressure at equator (default 315K)
   # 't_strat': 200.,   # stratosphere temperature (default 200K)
   # 'delh': 60.,       # equator-pole temp gradient (default 60K)
   # 'delv': 10.,       # lapse rate (default 10K)
   # 'eps': 50.,         # stratospheric latitudinal variation (default 0K)

   # 'equilibrium_t_option' : 'from_file',
   # 'equilibrium_t_file' : 'temp',

    'equilibrium_tau_option' : 'JFV',
    'equilibrium_t_option' : 'JFV',

    'ka' : -1000.,  #negative values are damping time in days
    'k_strat' : -40., # tjr
    'ks' :  -1000.,  # dont relax the boundary layer
    'kf' : -1000.,  #

    'pv_sat_flag'   :  False,
    'sat_only_flag' :  False,
    'pv_gamma' : 4.e-3,
    'pv_phi0' : 60.,
    'pv_dphi' : -10.,
    'sc_flag' : False,
    'sponge_flag' :  False,

})

#baseexp.namelist['spectral_dynamics_nml']['num_fourier'] = 85 #Number of Fourier modes
#baseexp.namelist['spectral_dynamics_nml']['num_spherical'] = 86 #Number of spherical harmonics in triangular truncation
#baseexp.namelist['spectral_dynamics_nml']['lon_max'] = 256 #Lon grid points
#baseexp.namelist['spectral_dynamics_nml']['lat_max'] = 128 #Lat grid points

baseexp.namelist['idealized_moist_phys_nml']['two_stream_gray'] = False #Don't use grey radiation
baseexp.namelist['idealized_moist_phys_nml']['do_rrtm_radiation'] = True #Do use RRTM radiation
baseexp.namelist['idealized_moist_phys_nml']['convection_scheme'] = 'FULL_BETTS_MILLER' #Use the full betts-miller convection scheme

baseexp.namelist['damping_driver_nml']['sponge_pbottom'] = 50 #Setting the lower pressure boundary for the model sponge layer in Pa.
baseexp.namelist['spectral_dynamics_nml']['surf_res'] = 0.3 #Parameter that sets the vertical distribution of sigma levels
baseexp.namelist['spectral_dynamics_nml']['num_levels'] = 50 #Number of vertical levels
baseexp.namelist['spectral_dynamics_nml']['valid_range_T'] = [0, 1000]

baseexp.namelist['idealized_moist_phys_nml']['land_option'] = 'input' #Use land mask from input file
baseexp.namelist['idealized_moist_phys_nml']['land_file_name'] = 'INPUT/era_land_t42.nc' #Tell model where to find input file

baseexp.namelist['spectral_init_cond_nml']['topog_file_name'] = 'era_land_t42.nc' #Name of land input file, which will also contain topography if generated using Isca's `land_file_generator_fn.py' routine.
baseexp.namelist['spectral_init_cond_nml']['topography_option'] = 'input' #Tell model to get topography from input file
baseexp.namelist['spectral_dynamics_nml']['ocean_topog_smoothing'] = 0.7 #Use model's in-built spatial smoothing to smooth topography in order to prevent unwanted aliasing at low horizontal resolution

baseexp.namelist['mixed_layer_nml']['delta_T'] = 0. #Set latitude contrast in initial temperature profile to zero
baseexp.namelist['mixed_layer_nml']['depth'] = 20. #Mixed layer depth
baseexp.namelist['mixed_layer_nml']['land_option'] = 'input' #Tell mixed layer to get land mask from input file
baseexp.namelist['mixed_layer_nml']['land_h_capacity_prefactor'] = 0.1 #What factor to multiply mixed-layer depth by over land. 
baseexp.namelist['mixed_layer_nml']['albedo_value'] = 0.25 #Ocean albedo value (before 0.25)
baseexp.namelist['mixed_layer_nml']['land_albedo_prefactor'] = 1.3 #What factor to multiply ocean albedo by over land (before 1.3)
baseexp.namelist['surface_flux_nml']['land_humidity_prefactor'] = 0.7 #Evaporative resistance over land (before 0.7)
baseexp.namelist['idealized_moist_phys_nml']['land_roughness_prefactor'] = 10.0 #How much rougher to make land than ocean (before 10)
baseexp.namelist['idealized_moist_phys_nml']['roughness_mom'] = 2.e-4 #Ocean roughness lengths
baseexp.namelist['idealized_moist_phys_nml']['roughness_heat'] = 2.e-4 #Ocean roughness lengths
baseexp.namelist['idealized_moist_phys_nml']['roughness_moist'] = 2.e-4 #Ocean roughness lengths

baseexp.namelist['mixed_layer_nml']['do_qflux'] = False #Don't use the prescribed analytical formula for q-fluxes
baseexp.namelist['mixed_layer_nml']['do_read_sst'] = True #Read in sst values from input file
baseexp.namelist['mixed_layer_nml']['do_sc_sst'] = True #Do specified ssts (need both to be true)
baseexp.namelist['mixed_layer_nml']['sst_file'] = 'sst_clim_ersst' #Set name of sst input file
baseexp.namelist['mixed_layer_nml']['specify_sst_over_ocean_only'] = True #Make sure sst only specified in regions of ocean.

#baseexp.namelist['idealized_moist_phys_nml']['bucket'] = True #Run with the bucket model
#baseexp.namelist['idealized_moist_phys_nml']['init_bucket_depth'] = 10000. #Set initial bucket depth over ocean
#baseexp.namelist['idealized_moist_phys_nml']['init_bucket_depth_land'] = 5. #Set initial bucket depth over land
#baseexp.namelist['idealized_moist_phys_nml']['max_bucket_depth_land']  = 5. #Set max bucket depth over land

baseexp.namelist['mixed_layer_nml']['update_albedo_from_ice'] = True #Use the simple ice model to update surface albedo
baseexp.namelist['mixed_layer_nml']['ice_file_name'] = 'siconc_clim_eraint' #I change it in atmos_solo/driver/mixed_layer.F90
baseexp.namelist['mixed_layer_nml']['ice_albedo_value'] = 0.7 #What value of albedo to use in regions of ice
baseexp.namelist['mixed_layer_nml']['ice_concentration_threshold'] = 0.5 #ice concentration threshold above which to make albedo equal to ice_albedo_value

baseexp.namelist['rrtm_radiation_nml']['solr_cnst'] = 1360. #s set solar constant to 1360, rather than default of 1368.22
baseexp.namelist['rrtm_radiation_nml']['dt_rad'] = 4320   #Use 4320 as RRTM timestep
baseexp.namelist['rrtm_radiation_nml']['do_read_ozone'] = True #Read in CO2 timeseries from input file
baseexp.namelist['rrtm_radiation_nml']['ozone_file'] = 'ozone_null' #Tell model name of o3 input file

baseexp.namelist['spectral_init_cond_nml']['initial_temperature'] = 270 #Lower than normal initial temperature
baseexp.namelist['spectral_dynamics_nml']['initial_sphum'] = 0.0 #No initial specific humidity


#Lets do a run!
#baseexp.runmonth(1, use_restart=False, num_cores=32, overwrite_data=True, light=False)
for i in range(40,60):
	diag.add_file('atmos_daily_%2d' % i, 1, 'days', time_units='days')
	baseexp.runmonth(i, num_cores=16, use_restart=True, light=False)



