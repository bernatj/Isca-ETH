import numpy as np
import os
from gfdl.experiment import Experiment, DiagTable
import f90nml

#Define our base experiment to compile
base_dir=os.getcwd()
GFDL_BASE        = os.environ['GFDL_BASE']

baseexp = Experiment('mima_test_experiment', overwrite_data=False)

baseexp.inputfiles = [os.path.join(GFDL_BASE,'input/rrtm_input_files/ozone_1990.nc')]

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

#Use RRTM radiation, not grey
baseexp.namelist['idealized_moist_phys_nml']['two_stream_gray'] = False
baseexp.namelist['idealized_moist_phys_nml']['do_rrtm_radiation'] = True

#Use the simple Betts Miller convection scheme
baseexp.namelist['idealized_moist_phys_nml']['convection_scheme'] ='SIMPLE_BETTS_MILLER'

baseexp.namelist['damping_driver_nml']['sponge_pbottom'] = 100 #Setting the lower pressure boundary for the model sponge layer in Pa.
baseexp.namelist['spectral_dynamics_nml']['surf_res'] = 0.5 #Parameter that sets the vertical distribution of sigma levels
baseexp.namelist['spectral_dynamics_nml']['num_levels'] = 40 #Number of vertical levels
baseexp.namelist['spectral_dynamics_nml']['scale_heights'] = 9.0 #Number of vertical levels
baseexp.namelist['spectral_dynamics_nml']['exponent'] = 7.0 #Number of vertical levels


baseexp.namelist['spectral_init_cond_nml']['topography_option'] = 'gaussian'
baseexp.namelist['gaussian_topog_nml'] = f90nml.Namelist({
  'height' : [3000, 3000],
   'olat'  : [45.,   45.],
   'olon'  : [90.,  270.],
   'wlat'  : [20.,   20.],
   'wlon'  : [20.,   20.],
   'rlat'  : [0.,    0.],
   'rlon'  : [0.,    0.], 
})

#Use a large mixed-layer depth, and the Albedo of the CTRL case in Jucker & Gerber, 2017
baseexp.namelist['mixed_layer_nml']['depth'] = 100.
baseexp.namelist['mixed_layer_nml']['albedo_value'] = 0.22


#Use the analytic formula for q-fluxes with an amplitude of 30 wm^-2
baseexp.namelist['mixed_layer_nml']['do_qflux'] = True
baseexp.namelist['qflux_nml']['qflux_amp'] = 30.0

baseexp.namelist['rrtm_radiation_nml']['solr_cnst'] = 1360. #s set solar constant to 1360, rather than default of 1368.22
baseexp.namelist['rrtm_radiation_nml']['dt_rad'] = 7200 #Use long RRTM timestep

#Lets do a run!
baseexp.runmonth(1, use_restart=False,num_cores=16, light=False)
for i in range(2,60):
    baseexp.runmonth(i, num_cores=16, light=False)
