from gfdl.experiment import Experiment, DiagTable

exp = Experiment('moist', overwrite_data=True)

diag = DiagTable()

# create one or more output files
diag.add_file('daily', 1, 'days', time_units='days')

# add diag fields to the output files
diag.add_field('dynamics', 'ucomp')
diag.add_field('dynamics', 'vcomp')
diag.add_field('dynamics', 'temp')
diag.add_field('dynamics', 'hgt')
diag.add_field('dynamics', 'vor')
diag.add_field('dynamics', 'div')

diag.add_field('two_stream', 'olr')
diag.add_field('two_stream', 'flux_sw')
diag.add_field('two_stream', 'flux_lw')

exp.use_diag_table(diag)

# compile the source code to $work_dir/exec
exp.disable_rrtm()	# when using two-stream gray rad we don't need rrtm
exp.compile()

exp.clear_rundir()

# set some values in the namelist
# overwrite the whole main_nml section
exp.namelist['main_nml'] = {
    'dt_atmos': 900,
    'seconds': 86400.0*30,
    'calendar': 'no_calendar'
}

# update specific values in some namelist sections
exp.namelist['idealized_moist_phys_nml']['two_stream_gray'] = False
exp.namelist['idealized_moist_phys_nml']['do_rrtm_radiation'] = True
exp.namelist['two_stream_gray_rad_nml']['do_seasonal'] = True
exp.namelist['spectral_dynamics_nml']['num_levels'] = 25

exp.namelist['idealized_moist_phys_nml']['land_option'] = 'input' #Use land mask from input file
exp.namelist['idealized_moist_phys_nml']['land_file_name'] = 'INPUT/era_land_t42.nc' #Tell model where to find input file
exp.namelist['spectral_init_cond_nml']['topog_file_name'] = 'era_land_t42.nc' #Name of land input file, which will also contain topography if generated using Isca's `land_file_generator_fn.py' routine.
exp.namelist['spectral_init_cond_nml']['topography_option'] = 'input' #Tell model to get topography from input file
exp.namelist['spectral_dynamics_nml']['ocean_topog_smoothing'] = 0.8 #Use model's in-built spatial smoothing to smooth topography in order to prevent unwanted aliasing at low horizontal resolution

exp.runmonth(1, num_cores=16, use_restart=False)
#for i in range(2, 13):
#  exp.runmonth(i,num_cores=16, use_restart=True)  # use the restart i-1 by default
