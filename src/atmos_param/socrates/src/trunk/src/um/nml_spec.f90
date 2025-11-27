! *****************************COPYRIGHT*******************************
! (C) Crown copyright Met Office. All rights reserved.
! For further details please refer to the file COPYRIGHT.txt
! which you should have received as part of this distribution.
! *****************************COPYRIGHT*******************************
!
!+ Program to convert a namelist to a spectral file.
!
PROGRAM nml_spec
!
! Description:
!   This program converts a namelist to the normal format
!   of a spectral file. This is normally used to add new
!   data to an existing spectral namelist, followed by
!   reverse conversion using spec_nml.
!
! Method:
!   A spectral namelist is read in the normal UM format and
!   simply written out.
!
! Code Description:
!   Fortran 90
!
! Modules used:
  USE dimensions_spec_ucf
  USE def_std_io_icf
  USE def_um_nml
  USE def_spectrum
  USE rad_pcf
!
!
  IMPLICIT NONE
!
!
!
! Declaration of variables.
!
  CHARACTER  (LEN=80) :: file_spectral
!   Name of spectral file
  INTEGER :: ierr = i_normal
!   Error flag
  INTEGER :: iu_file_in
!   Unit number for input file
  INTEGER :: ios
!   I/O status after reading file
  INTEGER :: i
!   Loop variable
  LOGICAL :: l_rad_nml
!   Flag for radiance-style namelist
  CHARACTER  (LEN=1) :: char_sr
!   Character for type of operation
!
  TYPE (StrSpecData) :: Spectrum
!   Spectrum to be written out
!
! Declaration of SW and LW namelists.
  NAMELIST/R2SWSP/ &
!                   blocks present
    l_present, &
!                   block 0
    n_band, n_absorb, n_aerosol, type_absorb, type_aerosol, &
!                   block 1
    wave_length_short, wave_length_long, &
!                   block 2
    solar_flux_band, &
!                  block 3
    rayleigh_coefficient, &
!                   block 4
    n_band_absorb, index_absorb, &
!                   block 5
    i_band_esft, i_scale_esft, i_scale_fnc, &
    p_reference, t_reference, k_esft, w_esft, scale_vector, &
!                   block 6
    n_deg_fit, t_ref_planck, thermal_coefficient, &
!                   block 8
    n_band_continuum, index_continuum, index_water, &
!                   block 9
    i_scale_fnc_cont, p_ref_continuum, t_ref_continuum, &
    k_continuum, scale_continuum, &
!                   block 10
    i_drop_parametrization, l_drop_type, n_drop_phf_term, &
    drop_parameter_list, drop_parm_min_dim, drop_parm_max_dim, &
!                   block 11
    i_aerosol_parametrization, nhumidity, l_aerosol_species, &
    aerosol_absorption, aerosol_scattering, aerosol_asymmetry, &
    aerosol_phase_fnc, &
    humidities, &
!                   block 12
    i_ice_parametrization, l_ice_type, n_ice_phf_term, &
    ice_parameter_list, ice_parm_min_dim, ice_parm_max_dim, &
!                   block 14
    n_band_exclude, index_exclude
!
!
  NAMELIST/R2LWSP/ &
!                   blocks present
    l_present, &
!                   block 0
    n_band, n_absorb, n_aerosol, type_absorb, type_aerosol, &
!                   block 1
    wave_length_short, wave_length_long, &
!                   block 2
    solar_flux_band, &
!                   block 3
    rayleigh_coefficient, &
!                   block 4
    n_band_absorb, index_absorb, &
!                   block 5
    i_band_esft, i_scale_esft, i_scale_fnc, &
    p_reference, t_reference, k_esft, w_esft, scale_vector, &
!                   block 6
    n_deg_fit, t_ref_planck, thermal_coefficient, &
!                   block 8
    n_band_continuum, index_continuum, index_water, &
!                   block 9
    i_scale_fnc_cont, p_ref_continuum, t_ref_continuum, &
    k_continuum, scale_continuum, &
!                   block 10
    i_drop_parametrization, l_drop_type, n_drop_phf_term, &
    drop_parameter_list, drop_parm_min_dim, drop_parm_max_dim, &
!                   block 11
    i_aerosol_parametrization, nhumidity, l_aerosol_species, &
    aerosol_absorption, aerosol_scattering, aerosol_asymmetry, &
    aerosol_phase_fnc, &
    humidities, &
!                   block 12
    i_ice_parametrization, l_ice_type, n_ice_phf_term, &
    ice_parameter_list, ice_parm_min_dim, ice_parm_max_dim, &
!                   block 13
    l_doppler_present, doppler_correction, &
!                   block 14
    n_band_exclude, index_exclude, &
!                   Block 15
    n_aod_wavel, aod_wavel, aod_absorption, aod_scattering, &
    i_aod_type
!
!
!
!
! Initialization of potentially missing data. This is also used to flag 
! historical options: by initializing alternative names to  negative
! values we can detect the ones actually used by searching for positive
! values.
  drop_parm_min_dim = -3.0_RealK
  drop_parm_max_dim = -3.0_RealK
  ice_parm_min_dim  = -3.0_RealK
  ice_parm_max_dim  = -3.0_RealK
  aerosol_phase_fnc = -3.0_RealK
  aerosol_asymmetry = -3.0_RealK
!
! Initialize all phase functions as containing only one term: where there
! are more, the appropriate value will overwrite this.
  n_drop_phf_term    = 1
  n_aerosol_phf_term = 1
  n_ice_phf_term     = 1
!
!
! Get a unit to read the file.
  CALL get_free_unit(ierr, iu_file_in)

! Obtain spectral information from the namelist.
  CALL open_file_in(ierr, iu_file_in, &
    'Give the name of the file containing the namelist.')
  IF (ierr /= i_normal) STOP

! Read the namelist.
  l_present=.FALSE.
  aerosol_asymmetry(1,1,1)=-999.0_RealK
  READ(iu_file_in, r2swsp, iostat=ios) 
  IF (l_present(0)) THEN
    WRITE(iu_stdout, '(a)') 'Found SW namelist.'
  ELSE
    REWIND(iu_file_in)
    READ(iu_file_in, r2lwsp, iostat=ios) 
    IF (l_present(0)) WRITE(iu_stdout, '(a)') 'Found LW namelist.'
  END IF

  IF (.NOT.l_present(0)) THEN
    WRITE(iu_stdout, '(a)') 'No namelist found.'
    STOP
  END IF

  IF (aerosol_asymmetry(1,1,1) < -99.0_RealK) THEN
    l_rad_nml=.TRUE.
    WRITE(iu_stdout, '(a)') 'Radiance namelist.'
  ELSE
    l_rad_nml=.FALSE.
    WRITE(iu_stdout, '(a)') 'Aerosol asymmetry only.'
  END IF

  DO i=1, npd_drop_type
    IF (l_drop_type(i)) THEN
      IF ( (drop_parm_min_dim(i) < 0.0_RealK) .OR. &
           (drop_parm_max_dim(i) < 0.0_RealK) ) THEN
        WRITE(iu_err, '(/a, /a, 1x, i2, a1, /a, /a)') &
          '*** Warning: This namelist does not contain limits ', &
          'on the range of validity of droplet parametrization ', &
          i, '.', &
          'Limits are now required and must be added to the ' &
          //'namelist', 'seek guidance if possible. '
        WRITE(iu_err, '(a, /a, i2, a, /a, i2, a, /a)') &
          'If this is not possible it will probably suffice', &
          'to set DROP_PARM_MIN_DIM(', i,' ) to 3.5e-07 and', &
          'DROP_PARM_MAX_DIM(', i,') to 3.75e-05', &
          'which are the historical defaults.'
        drop_parm_min_dim(i) = 3.5e-07
        drop_parm_max_dim(i) = 3.75e-05
      ENDIF
    ENDIF
  ENDDO
!
  DO i=1, npd_ice_type
    IF (l_ice_type(i)) THEN
      IF (i_ice_parametrization(i) == ip_ice_t_iwc) THEN
        ice_parm_min_dim(i)=0.0_RealK
        ice_parm_max_dim(i)=0.0_RealK
      ELSE IF ( (ice_parm_min_dim(i) < 0.0_RealK) .OR. &
                (ice_parm_max_dim(i) < 0.0_RealK) ) THEN
        WRITE(iu_err, '(/a, /a, 1x, i2, a1, /a, /a)') &
          '*** Warning: This namelist does not contain limits ', &
          'on the range of validity of ice parametrization ', &
          i, '.', &
          'Limits are now required and must be added to the ' &
          //'namelist', 'seek guidance if possible.'
        WRITE(iu_err, &
          '(a, /a, i2, a, /a, i2, a, /a, /a, i2, a, /a)') &
          'If this is not possible it will probably suffice', & 
          'to set ICE_PARM_MIN_DIM(', i,' ) to 3.75e-07_RealK and', &
          'ICE_PARM_MAX_DIM(', i,') to 8.0e-05', &
          'which are the historical defaults; unless', &
          'i_ice_parametrization(', i, ')=6, in which case', &
          'the limits should be 3.0e-06_RealK and 7.2e-04.'
        IF (i_ice_parametrization(i) == ip_ice_adt) THEN
          ice_parm_min_dim(i) = 3.0e-06
          ice_parm_max_dim(i) = 7.2e-04
        ELSE
          ice_parm_min_dim(i) = 3.75e-07
          ice_parm_max_dim(i) = 8.0e-05
        ENDIF
      ENDIF
    ENDIF
  ENDDO
!
  WRITE(iu_stdout, '(/a)') &
     'Enter the name of the spectral file.'
  READ(iu_stdin, '(a)') file_spectral
!
!
!
! Copy the namelist into the spectrum. Sizes are allocated to be
! the same as the hard-wired copies in the namelist, except where
! the mapping of historical features requires different behaviour.
!
!
! Dimensions:
  Spectrum%Dim%nd_type            = npd_type
  Spectrum%Dim%nd_band            = npd_band
  Spectrum%Dim%nd_exclude         = npd_exclude
  Spectrum%Dim%nd_k_term          = npd_k_term
  Spectrum%Dim%nd_species         = npd_species
  Spectrum%Dim%nd_scale_variable  = npd_scale_variable
  Spectrum%Dim%nd_continuum       = npd_continuum
  Spectrum%Dim%nd_drop_type       = npd_drop_type
  Spectrum%Dim%nd_ice_type        = npd_ice_type
  Spectrum%Dim%nd_aerosol_species = npd_aerosol_species
  Spectrum%Dim%nd_thermal_coeff   = npd_thermal_coeff
  Spectrum%Dim%nd_cloud_parameter = npd_cloud_parameter
  Spectrum%Dim%nd_humidity        = npd_humidities
  Spectrum%Dim%nd_aod_wavel       = npd_aod_wavel
  Spectrum%Dim%nd_phase_term      = npd_phase_term
  Spectrum%Dim%nd_tmp             = 1
  Spectrum%Dim%nd_pre             = 1
  Spectrum%Dim%nd_mix             = 1
  Spectrum%Dim%nd_band_mix_gas    = 1

!
! Basic Properties:
  ALLOCATE(Spectrum%Basic%l_present(0:npd_type))
  Spectrum%Basic%l_present          = l_present
  Spectrum%Basic%n_band             = n_band
  ALLOCATE(Spectrum%Basic%wavelength_long(npd_band))
  Spectrum%Basic%wavelength_long    = wave_length_long
  ALLOCATE(Spectrum%Basic%wavelength_short(npd_band))
  Spectrum%Basic%wavelength_short   = wave_length_short
  ALLOCATE(Spectrum%Basic%n_band_exclude(npd_band))
  Spectrum%Basic%n_band_exclude     = n_band_exclude
  ALLOCATE(Spectrum%Basic%index_exclude(npd_exclude, npd_band))
  Spectrum%Basic%index_exclude      = index_exclude
!
  IF (l_present(2)) THEN
!   Solar Properties:
    ALLOCATE(Spectrum%Solar%solar_flux_band(npd_band))
    Spectrum%Solar%solar_flux_band    = solar_flux_band
  ENDIF
!
  IF (l_present(3)) THEN
!   Rayleigh Scattering Properties:
    ALLOCATE(Spectrum%Rayleigh%rayleigh_coeff(npd_band))
    Spectrum%Rayleigh%rayleigh_coeff = rayleigh_coefficient
  ENDIF
!
  IF (l_present(4)) THEN
!   Gaseous Properties
    Spectrum%Gas%n_absorb            = n_absorb
    ALLOCATE(Spectrum%Gas%n_band_absorb(npd_band))
    Spectrum%Gas%n_band_absorb       = n_band_absorb
    ALLOCATE(Spectrum%Gas%index_absorb(npd_species, npd_band))
    Spectrum%Gas%index_absorb        = index_absorb
    ALLOCATE(Spectrum%Gas%type_absorb(npd_species))
    Spectrum%Gas%type_absorb         = type_absorb
    ALLOCATE(Spectrum%Gas%i_band_k(npd_band, npd_species))
    Spectrum%Gas%i_band_k            = i_band_esft
    ALLOCATE(Spectrum%Gas%i_scale_k(npd_band, npd_species))
    Spectrum%Gas%i_scale_k           = i_scale_esft
    ALLOCATE(Spectrum%Gas%i_scale_fnc(npd_band, npd_species))
    Spectrum%Gas%i_scale_fnc         = i_scale_fnc
    ALLOCATE(Spectrum%Gas%k(npd_k_term, npd_band, npd_species))
    Spectrum%Gas%k                   = k_esft
    ALLOCATE(Spectrum%Gas%w(npd_k_term, npd_band, npd_species))
    Spectrum%Gas%w                   = w_esft
    ALLOCATE(Spectrum%Gas%scale(npd_scale_variable, npd_k_term, &
    npd_band, npd_species))
    Spectrum%Gas%scale               = scale_vector
    ALLOCATE(Spectrum%Gas%p_ref(npd_species, npd_band))
    Spectrum%Gas%p_ref               = p_reference
    ALLOCATE(Spectrum%Gas%t_ref(npd_species, npd_band))
    Spectrum%Gas%t_ref               = t_reference
    ALLOCATE(Spectrum%Gas%i_scat(npd_k_term, npd_band, npd_species))
    Spectrum%Gas%i_scat              = 0
    ALLOCATE(Spectrum%Gas%num_ref_p(npd_species, npd_band))
    Spectrum%Gas%num_ref_p           = 0
    ALLOCATE(Spectrum%Gas%num_ref_t(npd_species, npd_band))
    Spectrum%Gas%num_ref_t           = 0
  ENDIF
!
  IF (l_present(6)) THEN
!   Planckian Function:
    Spectrum%Planck%n_deg_fit         = n_deg_fit
    ALLOCATE(Spectrum%Planck%thermal_coeff(0: npd_thermal_coeff-1, npd_band))
    Spectrum%Planck%thermal_coeff     = thermal_coefficient
    Spectrum%Planck%t_ref_planck      = t_ref_planck
  ENDIF
!
  IF (l_present(8)) THEN
!   Continuum Properties
    ALLOCATE(Spectrum%Cont%n_band_continuum(npd_band))
    Spectrum%Cont%n_band_continuum    = n_band_continuum
    ALLOCATE(Spectrum%Cont%index_continuum(npd_band, npd_continuum))
    Spectrum%Cont%index_continuum     = index_continuum
    Spectrum%Cont%index_water         = index_water
    ALLOCATE(Spectrum%Cont%i_scale_fnc_cont(npd_band, npd_continuum))
    Spectrum%Cont%i_scale_fnc_cont    = i_scale_fnc_cont
    ALLOCATE(Spectrum%Cont%k_cont(npd_band, npd_continuum))
    Spectrum%Cont%k_cont              = k_continuum
    ALLOCATE(Spectrum%Cont%scale_cont(npd_scale_variable, &
      npd_band, npd_continuum))
    Spectrum%Cont%scale_cont          = scale_continuum
    ALLOCATE(Spectrum%Cont%p_ref_cont(npd_continuum, npd_band))
    Spectrum%Cont%p_ref_cont          = p_ref_continuum
    ALLOCATE(Spectrum%Cont%t_ref_cont(npd_continuum, npd_band))
    Spectrum%Cont%t_ref_cont          = t_ref_continuum
  ENDIF
!
  IF (l_present(10)) THEN
!   Droplet Properties:
    ALLOCATE(Spectrum%Drop%l_drop_type(npd_drop_type))
    Spectrum%Drop%l_drop_type         = l_drop_type
    ALLOCATE(Spectrum%Drop%i_drop_parm(npd_drop_type))
    Spectrum%Drop%i_drop_parm         = i_drop_parametrization
    ALLOCATE(Spectrum%Drop%n_phf(npd_drop_type))
    Spectrum%Drop%n_phf               = n_drop_phf_term
    ALLOCATE(Spectrum%Drop%parm_list(npd_cloud_parameter, npd_band, &
      npd_drop_type))
    Spectrum%Drop%parm_list           = drop_parameter_list
    ALLOCATE(Spectrum%Drop%parm_min_dim(npd_drop_type))
    Spectrum%Drop%parm_min_dim        = drop_parm_min_dim
    ALLOCATE(Spectrum%Drop%parm_max_dim(npd_drop_type))
    Spectrum%Drop%parm_max_dim        = drop_parm_max_dim
  ENDIF
!
  IF (l_present(11)) THEN
!   Aerosol Properties:
    Spectrum%Aerosol%n_aerosol        = n_aerosol
    ALLOCATE(Spectrum%Aerosol%l_aero_spec(npd_aerosol_species))
    Spectrum%Aerosol%l_aero_spec      = l_aerosol_species
    ALLOCATE(Spectrum%Aerosol%type_aerosol(npd_aerosol_species))
    Spectrum%Aerosol%type_aerosol     = type_aerosol
    ALLOCATE(Spectrum%Aerosol%i_aerosol_parm(npd_aerosol_species))
    Spectrum%Aerosol%i_aerosol_parm  = i_aerosol_parametrization
    ALLOCATE(Spectrum%Aerosol%n_aerosol_phf_term(npd_aerosol_species))
    Spectrum%Aerosol%n_aerosol_phf_term   = n_aerosol_phf_term
    ALLOCATE(Spectrum%Aerosol%nhumidity(npd_aerosol_species))
    Spectrum%Aerosol%nhumidity        = nhumidity
    ALLOCATE(Spectrum%Aerosol%abs(npd_humidities, npd_aerosol_species, &
      npd_band))
    Spectrum%Aerosol%abs              = aerosol_absorption
    ALLOCATE(Spectrum%Aerosol%scat(npd_humidities, npd_aerosol_species, &
      npd_band))
    Spectrum%Aerosol%scat             = aerosol_scattering
    ALLOCATE(Spectrum%Aerosol%phf_fnc(npd_humidities, npd_phase_term, &
      npd_aerosol_species, npd_band))
    IF (l_rad_nml) THEN
      Spectrum%Aerosol%phf_fnc          = aerosol_phase_fnc
    ELSE
      Spectrum%Aerosol%phf_fnc(:, 1, :, :)   = aerosol_asymmetry
    ENDIF
    ALLOCATE(Spectrum%Aerosol%humidities(npd_humidities, npd_aerosol_species))
    Spectrum%Aerosol%humidities                = humidities
  ENDIF
!
  IF (l_present(12)) THEN
!   Ice crystal Properties:
    ALLOCATE(Spectrum%Ice%l_ice_type(npd_ice_type))
    Spectrum%Ice%l_ice_type          = l_ice_type
    ALLOCATE(Spectrum%Ice%i_ice_parm(npd_ice_type))
    Spectrum%Ice%i_ice_parm          = i_ice_parametrization
    ALLOCATE(Spectrum%Ice%n_phf(npd_ice_type))
    Spectrum%Ice%n_phf               = n_ice_phf_term
    ALLOCATE(Spectrum%Ice%parm_list(npd_cloud_parameter, npd_band, &
      npd_ice_type))
    Spectrum%Ice%parm_list           = ice_parameter_list
    ALLOCATE(Spectrum%Ice%parm_min_dim(npd_ice_type))
    Spectrum%Ice%parm_min_dim        = ice_parm_min_dim
    ALLOCATE(Spectrum%Ice%parm_max_dim(npd_ice_type))
    Spectrum%Ice%parm_max_dim        = ice_parm_max_dim
  ENDIF

  IF (l_present(13)) THEN
!   Doppler coefficients (should now be obsolete)
    ALLOCATE(Spectrum%Gas%l_doppler(npd_species))
    Spectrum%Gas%l_doppler   = l_doppler_present
    ALLOCATE(Spectrum%Gas%doppler_cor(npd_species))
    Spectrum%Gas%doppler_cor = doppler_correction
  END IF

  IF (l_present(15)) THEN
!   Aerosol optical depths:
    Spectrum%Aerosol%n_aod_wavel = n_aod_wavel
    ALLOCATE(Spectrum%Aerosol%i_aod_type(npd_aerosol_species))
    Spectrum%Aerosol%i_aod_type  = i_aod_type
    ALLOCATE(Spectrum%Aerosol%aod_wavel(npd_aod_wavel))
    Spectrum%Aerosol%aod_wavel  = aod_wavel
    ALLOCATE(Spectrum%Aerosol%aod_abs(npd_humidities, &
      npd_aerosol_species, npd_aod_wavel))
    Spectrum%Aerosol%aod_abs  = aod_absorption
    ALLOCATE(Spectrum%Aerosol%aod_scat(npd_humidities, &
      npd_aerosol_species, npd_aod_wavel))
    Spectrum%Aerosol%aod_scat  = aod_scattering
  END IF


  CALL out_spectrum(file_spectral, Spectrum, ierr)

END PROGRAM nml_spec
