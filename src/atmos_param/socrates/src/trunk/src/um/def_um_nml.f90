! *****************************COPYRIGHT*******************************
! (C) Crown copyright Met Office. All rights reserved.
! For further details please refer to the file COPYRIGHT.txt
! which you should have received as part of this distribution.
! *****************************COPYRIGHT*******************************
!
!+ Module to declare the elements of a spectral file as a namelist.
!
MODULE def_um_nml
!
! Description:
!
! This module defines elements of a spectral as arrays of fixed
! sizes for use as elements of a namelist in the UM. The type of
! variable which can appear in a namelist is quite restricted and
! allocatable and pointer arrays appear not to work.
!
! NOTES:
!    1.) The term "ESFT" is retained in namelists for backward
!        compatibility.
!    2.) AEROSOL_ASYMMETRY and AEROSOL_PHASE_FNC are alternatives,
!        the former being retained for backward compatibility.
!
! Language: Fortran 90
!
! Modules used:
  USE realtype_rd
  USE dimensions_spec_ucf
!
!
  IMPLICIT NONE
!
!
!- End of header
!
!
!
! General Fields:
!
  LOGICAL :: l_present(0: npd_type)
!   Flag for types of data present
!
!
!
! Properties of the spectral bands:
!
  INTEGER :: n_band
!   Number of spectral bands
!
  REAL  (RealK) :: wave_length_short(npd_band)
!   Shorter wavelength limits
  REAL  (RealK) :: wave_length_long(npd_band)
!   Longer wavelength limits
!
!
!
! Exclusion of specific bands from parts of the spectrum:
!
  INTEGER :: n_band_exclude(npd_band)
!   Number of excluded bands within each spectral band
  INTEGER :: index_exclude(npd_exclude, npd_band)
!   Indices of excluded bands
!
!
!
! Fields for the solar flux:
!
  REAL  (RealK) :: solar_flux_band(npd_band)
!   Fraction of the incident solar flux in each band
!
!
!
! Fields for rayleigh scattering:
!
  REAL  (RealK) :: rayleigh_coefficient(npd_band)
!   Rayleigh coefficients
!
!
!
! Fields for gaseous absorption:
!
  INTEGER :: n_absorb
!   Number of absorbers
  INTEGER :: n_band_absorb(npd_band)
!   Number of absorbers in each band
  INTEGER :: index_absorb(npd_species, npd_band)
!   List of absorbers in each band
  INTEGER :: type_absorb(npd_species)
!   Types of each gas in the spectral file
  INTEGER :: i_band_esft(npd_band, npd_species)
!   Number of esft terms in band for each gas
  INTEGER :: i_scale_esft(npd_band, npd_species)
!   Type of esft scaling
  INTEGER :: i_scale_fnc(npd_band, npd_species)
!   Type of scaling function
!
  REAL  (RealK) :: k_esft(npd_k_term, npd_band, npd_species)
!   ESFT exponents
  REAL  (RealK) :: w_esft(npd_k_term, npd_band, npd_species)
!   ESFT weights
  REAL  (RealK) :: scale_vector(npd_scale_variable, &
    npd_k_term, npd_band, npd_species)
!   Scaling parameters for each absorber and term
  REAL  (RealK) :: p_reference(npd_species, npd_band)
!   Reference pressure for scaling function
  REAL  (RealK) :: t_reference(npd_species, npd_band)
!   Reference temperature for scaling function
!
!
!
! Representation of the Planckian:
!
  INTEGER :: n_deg_fit
!   Degree of thermal polynomial
!
  REAL  (RealK) :: thermal_coefficient(0: npd_thermal_coeff-1, npd_band)
!   Coefficients in polynomial fit to source function
  REAL  (RealK) :: t_ref_planck
!   Planckian reference temperature
!
!
!
! Fields for continua:
!
  INTEGER :: n_band_continuum(npd_band)
!   Number of continua in each band
  INTEGER :: index_continuum(npd_band, npd_continuum)
!   list of continua continuua in each band
  INTEGER :: index_water
!   Index of water vapour
  INTEGER :: i_scale_fnc_cont(npd_band, npd_continuum)
!   Type of scaling function for continuum
!
  REAL  (RealK) :: k_continuum(npd_band, npd_continuum)
!   Grey extinction coefficients for continuum
  REAL  (RealK) :: scale_continuum(npd_scale_variable, &
    npd_band, npd_continuum)
!   Scaling parameters for continuum
  REAL  (RealK) :: p_ref_continuum(npd_continuum, npd_band)
!   Reference pressure for scaling of continuum
  REAL  (RealK) :: t_ref_continuum(npd_continuum, npd_band)
!   Reference temperature for scaling of continuum
!
!
!
! Fields for water droplets:
!
  INTEGER :: i_drop_parametrization(npd_drop_type)
!   Parametrization type of droplets
  INTEGER :: n_drop_phf_term(npd_drop_type)
!   Number of terms in the phase function
!
  LOGICAL :: l_drop_type(npd_drop_type)
!   Types of droplet present
!
  REAL  (RealK) :: drop_parameter_list(npd_cloud_parameter, &
    npd_band, npd_drop_type)
!   Parameters used to fit optical properties of clouds
  REAL  (RealK) :: drop_parm_min_dim(npd_drop_type)
!   Minimum dimension permissible in the parametrization
  REAL  (RealK) :: drop_parm_max_dim(npd_drop_type)
!   Maximum dimension permissible in the parametrization
!
!
!
! Fields for aerosols:
!
  INTEGER :: n_aerosol
!   Number of species of aerosol
  INTEGER :: type_aerosol(npd_aerosol_species)
!   Types of aerosols
  INTEGER :: i_aerosol_parametrization(npd_aerosol_species)
!   Parametrization of aerosols
  INTEGER :: n_aerosol_phf_term(npd_aerosol_species)
!   Number of terms in the phase function
  INTEGER :: nhumidity(npd_aerosol_species)
!   Numbers of humidities
!
  LOGICAL :: L_aerosol_species(npd_aerosol_species)
!   Aerosol species included
!
  REAL  (RealK) :: aerosol_absorption(npd_humidities, &
    npd_aerosol_species, npd_band)
!   Absorption by aerosols
  REAL  (RealK) :: aerosol_scattering(npd_humidities, &
    npd_aerosol_species, npd_band)
!   Scattering by aerosols
  REAL  (RealK) :: aerosol_asymmetry(npd_humidities, &
    npd_aerosol_species, npd_band)
!   Asymmetries of aerosols
  REAL  (RealK) :: aerosol_phase_fnc(npd_humidities, &
    npd_phase_term, npd_aerosol_species, npd_band)
!   Phase function of aerosols
  REAL  (RealK) :: humidities(npd_humidities, npd_aerosol_species)
!   Humidities for components
!
!
! Fields for aerosol optical depth:

    INTEGER :: n_aod_wavel
!     Number of wavelengths
    INTEGER :: i_aod_type(npd_aerosol_species)
!     Relationship between aerosol component and type
    REAL :: aod_wavel(npd_aod_wavel)
!     Wavelengths for the aod
    REAL :: aod_absorption(npd_humidities, npd_aerosol_species, &
      npd_aod_wavel)
!     Monochromatic specific absorption coefficient
    REAL :: aod_scattering(npd_humidities, npd_aerosol_species, &
      npd_aod_wavel)
!     Monochromatic specific scattering coefficient
!
!
! Fields for ice crystals:
!
  INTEGER :: i_ice_parametrization(npd_ice_type)
!   Types of parametrization of ice crystals
  INTEGER :: n_ice_phf_term(npd_ice_type)
!   Number of terms in the phase function
!
  LOGICAL :: l_ice_type(npd_ice_type)
!   Types of ice crystal present
!
  REAL  (RealK) :: ice_parameter_list(npd_cloud_parameter, &
    npd_band, npd_ice_type)
!   Parameters used to fit single scattering of ice crystals
  REAL  (RealK) :: ice_parm_min_dim(npd_ice_type)
!   Minimum dimension permissible in the parametrization
  REAL  (RealK) :: ice_parm_max_dim(npd_ice_type)
!   Maximum dimension permissible in the parametrization
!
!
!
! Fields for doppler broadening:
!
  LOGICAL :: l_doppler_present(npd_species)
!   Flag for Doppler broadening for each species
!
  REAL  (RealK) :: doppler_correction(npd_species)
!   Doppler correction terms
!
!
!
END MODULE def_um_nml
