! *****************************COPYRIGHT*******************************
! (C) Crown copyright Met Office. All rights reserved.
! For further details please refer to the file COPYRIGHT.txt
! which you should have received as part of this distribution.
! *****************************COPYRIGHT*******************************
!
!+ Subroutines to write a spectral file as a UM namelist.
!
SUBROUTINE out_nml &
!
(Spectrum, l_asymmetry, l_interactive, ierr)
!
! Method:
!   The output file is opened and an internal subroutine is called to
! write out each block of data.
!
! Description of Code:
!   Fortran90.
!
!
! Modules used
  USE realtype_rd
  USE rad_pcf
  USE def_spectrum
  USE dimensions_spec_ucf
  USE def_std_io_icf

  IMPLICIT NONE
!
!
!
! Dummy variables.
  LOGICAL, Intent(IN) :: l_interactive
!   Flag for interactive operation
  LOGICAL, Intent(IN) :: l_asymmetry
!   Flag to write asymmetries (for the older version of the code)
!   Otherwise, the full phase function is written out: this is
!   compatible with the UM only if the appropriate radiance modset
!   is used.
  INTEGER, Intent(INOUT) :: ierr
!   Error flag
  TYPE (StrSpecData), Target, Intent(IN) :: Spectrum
!   Spectral data
!
! Local variables.
  CHARACTER (LEN=80) :: file_nml
!   Name of file to contain the namelist
  CHARACTER (LEN=20) :: namelist_group
!   Group name for namelist
  INTEGER :: ios
!   I/O error flag
  INTEGER :: iu_nml
!   Unit number for output of the namelist
  INTEGER :: i
!   Loop variable
!
!
!
! Get a unit to read the file.
  CALL get_free_unit(ierr, iu_nml)
  IF (ierr /= i_normal) RETURN
!
  CALL open_file_out_90(iu_nml, l_interactive, &
    'Give the name of the file to contain the namelist.', &
    file_nml, ierr)
  IF (ierr /= i_normal) STOP
!
! Open the file for writing.
  OPEN(UNIT=iu_nml, FILE=file_nml, IOSTAT=ios, STATUS='UNKNOWN')
  IF (ios /= 0) THEN
    WRITE(iu_err, '(/a)') &
      '*** Error: File for namelist could not be opened.'
    ierr=i_err_fatal
    RETURN
  ENDIF
!
  WRITE(iu_stdout, '(/a)') &
    'Enter the groupname for the namelist.'
  READ(iu_stdin, '(a)') namelist_group
  WRITE(iu_nml, '(1x, a1, a)') '&', namelist_group
!
!
!
! For each group of data which is present write out the 
! appropriate block, implicitly using the most recent type and
! version.
  IF (Spectrum%Basic%l_present(0)) CALL nml_write_block_0_int
  IF (Spectrum%Basic%l_present(1)) &
    CALL nml_write_block_1_int(Spectrum%Basic)
  IF (Spectrum%Basic%l_present(2)) &
    CALL nml_write_block_2_int(Spectrum%Basic, Spectrum%Solar)
  IF (Spectrum%Basic%l_present(3)) &
    CALL nml_write_block_3_int(Spectrum%Basic, Spectrum%Rayleigh)
  IF (Spectrum%Basic%l_present(4)) CALL nml_write_block_4_int
  IF (Spectrum%Basic%l_present(5)) &
    CALL nml_write_block_5_int(Spectrum%Basic, Spectrum%Gas)
  IF (Spectrum%Basic%l_present(6)) &
    CALL nml_write_block_6_int(Spectrum%Basic, Spectrum%Planck)
! Block 7 is obsolete and omitted.
  IF (Spectrum%Basic%l_present(8)) &
    CALL nml_write_block_8_int
  IF (Spectrum%Basic%l_present(9)) &
    CALL nml_write_block_9_int(Spectrum%Basic, Spectrum%Cont)
  IF (Spectrum%Basic%l_present(10)) &
    CALL nml_write_block_10_int(Spectrum%Basic, Spectrum%Drop)
  IF (Spectrum%Basic%l_present(11)) &
    CALL nml_write_block_11_int(Spectrum%Basic, Spectrum%Aerosol)
  IF (Spectrum%Basic%l_present(12)) &
    CALL nml_write_block_12_int(Spectrum%Basic, Spectrum%Ice)
! Block 13 is obsolete and now omitted.
  IF (Spectrum%Basic%l_present(14)) &
    CALL nml_write_block_14_int(Spectrum%Basic)
!
  WRITE(iu_nml, '(1x, a2)') '/'
!
! Close the file.
  CLOSE(iu_nml)
!
!
!
  RETURN
!
CONTAINS
!
!
!
  SUBROUTINE nml_write_block_0_int
!
!
!   Modules used locally.
    USE gas_list_pcf
!
!
!
!   Local variables.
    INTEGER :: i
!     Loop variable
    INTEGER, Pointer :: i_type
!     Identifier for gas
!
!
!
    WRITE(iu_nml, '(2x, a12, t38, a1, t40, a7)') &
     'L_PRESENT(0)', '=', '.TRUE.,'
!
    WRITE(iu_nml, '(3x, a6, t38, a1, t40, i5, a1)') &
     'N_BAND', '=', Spectrum%Basic%n_band, ','
    WRITE(iu_nml, '(3x, a8, t38, a1, t40, i5, a1)') &
     'N_ABSORB', '=', Spectrum%Gas%n_absorb, ','
    WRITE(iu_nml, '(3x, a9, t38, a1, t40, i5, a1)') &
     'N_AEROSOL', '=', Spectrum%Aerosol%n_aerosol, ','
!
    WRITE(iu_nml, '(3x, a, t38, a1, (t40, (5(i5, ", "))))') &
      'TYPE_ABSORB', '=', &
      Spectrum%Gas%type_absorb(1:Spectrum%Gas%n_absorb)
!
    IF (Spectrum%Aerosol%n_aerosol > 0) THEN
      WRITE(iu_nml, '(3x, a, t38, a1, (t40, (5(i5, ", "))))') &
        'TYPE_AEROSOL', '=', &
        Spectrum%Aerosol%type_aerosol(1:Spectrum%Aerosol%n_aerosol)
    ENDIF
!
!
!
  END SUBROUTINE nml_write_block_0_int
!
!
!
  SUBROUTINE nml_write_block_1_int(SpBasic) 
!
!
    TYPE (StrSpecBasic) :: SpBasic
!
!
!
    WRITE(iu_nml, '(2x, a12, t38, a1, t40, a7)') &
      'L_PRESENT(1)', '=', '.TRUE.,'
!
    WRITE(iu_nml, '(3x, a, t38, a1, (t40, (2(1pe16.9, ", "))))') &
      'WAVE_LENGTH_SHORT', '=', &
      SpBasic%wavelength_short(1:SpBasic%n_band)
    WRITE(iu_nml, '(3x, a, t38, a1, (t40, (2(1pe16.9, ", "))))') &
      'WAVE_LENGTH_LONG', '=', &
      SpBasic%wavelength_long(1:SpBasic%n_band)
!
!
!
  END SUBROUTINE nml_write_block_1_int
!
!
!
  SUBROUTINE nml_write_block_2_int(SpBasic, SpSolar)
!
!
!
    TYPE  (StrSpecBasic) :: SpBasic
    TYPE  (StrSpecSolar) :: SpSolar
!
!
!
    WRITE(iu_nml, '(2x, a12, t38, a1, t40, a7)') &
      'L_PRESENT(2)', '=', '.TRUE.,'
!
    WRITE(iu_nml, '(3x, a, t38, a1, (t40, (2(1pe16.9, ", "))))') &
      'SOLAR_FLUX_BAND', '=', &
      SpSolar%solar_flux_band(1:SpBasic%n_band)
!
!
!
  END SUBROUTINE nml_write_block_2_int
!
!
!
  SUBROUTINE nml_write_block_3_int(SpBasic, SpRayleigh)
!
!
!
    TYPE  (StrSpecBasic) :: SpBasic
    TYPE  (StrSpecRayleigh) :: SpRayleigh
!
!
!
    WRITE(iu_nml, '(2x, a12, t38, a1, t40, a7)') &
      'L_PRESENT(3)', '=', '.TRUE.,'
!
    WRITE(iu_nml, '(3x, a, t38, a1, (t40, (2(1pe16.9, ", "))))') &
      'RAYLEIGH_COEFFICIENT', '=', &
      SpRayleigh%rayleigh_coeff(1:SpBasic%n_band)
!
!
!
  END SUBROUTINE nml_write_block_3_int
!
!
!
  SUBROUTINE nml_write_block_4_int
!
!
!
!   Local variables
    INTEGER :: i
!     Loop variable
!
!
!
    WRITE(iu_nml, '(2x, a12, t38, a1, t40, a7)') &
      'L_PRESENT(4)', '=', '.TRUE.,'
!
    WRITE(iu_nml, '(3x, a, t38, a1, (t40, (5(i5, ", "))))') &
      'N_BAND_ABSORB', '=', &
      Spectrum%Gas%n_band_absorb(1:Spectrum%Basic%n_band)
    DO i=1, Spectrum%Basic%n_band
      WRITE(iu_nml, &
        '(3x, a12, a4, i3, a1, t38, a1, (t40, (5(i5, ", "))))') &
        'INDEX_ABSORB', '(1, ', i, ')', '=', &
        Spectrum%Gas%index_absorb(1:Spectrum%Gas%n_band_absorb(i), i)
    ENDDO
!
!
!
  END SUBROUTINE nml_write_block_4_int
!
!
!
!
  SUBROUTINE nml_write_block_5_int(SpBasic, SpGas)
!
!
!
    TYPE  (StrSpecBasic) :: SpBasic
    TYPE  (StrSpecGas) :: SpGas
!
!   Local variables.
    INTEGER :: i
!     Loop variable
    INTEGER :: j
!     Loop variable
    INTEGER :: k
!     Loop variable
    INTEGER :: i_index
!     Index of gas
!
!
!
    WRITE(iu_nml, '(2x, a12, t38, a1, t40, a7)') &
      'L_PRESENT(5)', '=', '.TRUE.,'
!
    DO i=1, SpBasic%n_band
      DO j=1, SpGas%n_band_absorb(i)
        i_index=SpGas%index_absorb(j, i)
        WRITE(iu_nml, &
          '(3x, a11, a1, i3, a2, i3, a1, t38, a1, t40, i5, a1)') &
          'I_BAND_ESFT', '(', i, ',', i_index, ')', '=', &
          SpGas%i_band_k(i, i_index), ','
        WRITE(iu_nml, &
          '(3x, a12, a1, i3, a2, i3, a1, t38, a1, t40, i5, a1)') &
          'I_SCALE_ESFT', '(', i, ',', i_index, ')', '=', &
          SpGas%i_scale_k(i, i_index), ','
        WRITE(iu_nml, &
          '(3x, a11, a1, i3, a2, i3, a1, t38, a1, t40, i5, a1)') &
          'I_SCALE_FNC', '(', i, ',', i_index, ')', '=', &
          SpGas%i_scale_fnc(i, i_index), ','
        WRITE(iu_nml, &
          '(3x, a11, a1, i3, a2, i3, a1, t38, a1, t40, 1pe16.9, a1)') &
          'P_REFERENCE', '(', i_index, ',', i, ')', '=', &
          SpGas%p_ref(i_index, i), ','
        WRITE(iu_nml, &
          '(3x, a11, a1, i3, a2, i3, a1, t38, a1, t40, 1pe16.9, a1)') &
          'T_REFERENCE', '(', i_index, ',', i, ')', '=', &
          SpGas%t_ref(i_index, i), ','
!
        IF ( (SpGas%i_scale_fnc(i, i_index) == &
                IP_scale_power_law)    .OR. &
             (SpGas%i_scale_fnc(i, i_index) == &
                IP_scale_power_quad)   .OR. &
             (SpGas%i_scale_fnc(i, i_index) == &
                IP_scale_doppler_quad) .OR. &
             (SpGas%i_scale_fnc(i, i_index) == &
                IP_scale_dbl_pow_law)  .OR. &
             (SpGas%i_scale_fnc(i, i_index) == &
                IP_scale_dbl_pow_quad) .OR. &
             (SpGas%i_scale_fnc(i, i_index) == &
                IP_scale_dbl_dop_quad) ) THEN
          DO k=1, SpGas%i_band_k(i, i_index)
            WRITE(iu_nml, &
              '(2(3x, a6, a1, i3, a2, i3, a2, i3, ' // &
              'a1, t38, a1, t40, 1pe16.9, a1, /),' // &
              '6x, a12, a2, 3(a2, i3), a1, t38, a1, 1x,' // &
              '(t40, 2(1pe16.9, ", ")))') &
              'K_ESFT', '(', k, ', ', i, ', ', i_index, ')', &
              '=', &
              SpGas%k(k, i, i_index), ',', &
              'W_ESFT', '(', k, ', ', i, ', ', i_index, ')', &
              '=', &
              SpGas%w(k, i, i_index), ',', &
              'SCALE_VECTOR', '(1', ', ', k, ', ', i, ', ', &
              i_index, ')', '=', &
              SpGas%scale(1: &
                n_scale_variable(SpGas%i_scale_fnc(i, i_index)), &
                k, i, i_index)
          ENDDO
        ELSE IF ( (SpGas%i_scale_fnc(i, i_index) == &
                     IP_scale_fnc_null) .OR. &
                  (SpGas%i_scale_fnc(i, i_index) == &
                     IP_scale_wenyi) ) THEN
          DO k=1, SpGas%i_band_k(i, i_index)
            WRITE(iu_nml, '(3x, a6, a1, i3, a2, i3, a2, i3, ' // &
              'a1, t38, a1, t40, 1pe16.9, ", ")') &
              'K_ESFT', '(', k, ', ', i, ', ', i_index, ')', &
              '=', SpGas%k(k, i, i_index), &
              'W_ESFT', '(', k, ', ', i, ', ', i_index, ')', &
              '=', SpGas%w(k, i, i_index)
          ENDDO
        ENDIF
      ENDDO
    ENDDO
!
!
!
  END SUBROUTINE nml_write_block_5_int
!
!
!
  SUBROUTINE nml_write_block_6_int(SpBasic, SpPlanck)
!
!
!
    TYPE  (StrSpecBasic) :: SpBasic
    TYPE  (StrSpecPlanck) :: SpPlanck
!
!   Local variables.
    INTEGER :: i
!     Loop variable
!
!
!
    WRITE(iu_nml, '(2x, a12, t38, a1, t40, a7)') &
      'L_PRESENT(6)', '=', '.TRUE.,'
!
    WRITE(iu_nml, '(3x, a9, t38, a1, t40, i3, a1)') &
      'N_DEG_FIT', '=', SpPlanck%n_deg_fit, ','
    WRITE(iu_nml, '(3x, a12, t38, a1, t40, 1pe16.9, a1)') &
      'T_REF_PLANCK', '=', SpPlanck%t_ref_planck, ','
    DO i=1, SpBasic%n_band
      WRITE(iu_nml, &
        '(3x, a19, a4, i3, a1, t38, a1, (t40, 2(1pe16.9, ", ")))') &
        'THERMAL_COEFFICIENT', '(0, ', i, ')', '=', &
        SpPlanck%thermal_coeff(0:SpPlanck%n_deg_fit, i)
    ENDDO
!
!
!
  END SUBROUTINE nml_write_block_6_int
!
!
!
  SUBROUTINE nml_write_block_8_int
!
!      
!
!   Local variables
    INTEGER :: i
!     Loop variable
    INTEGER :: j
!     Loop variable
!
!
!
    WRITE(iu_nml, '(2x, a12, t38, a1, t40, a7)') &
      'L_PRESENT(8)', '=', '.TRUE.,'
!
    DO i=1, Spectrum%Basic%n_band
      WRITE(iu_nml, '(3x, a16, a1, i3, a1, t38, a1, t40, i3, a1)') &
        'N_BAND_CONTINUUM', '(', i, ')', '=', &
        Spectrum%Cont%n_band_continuum(i), ','
      IF (Spectrum%Cont%n_band_continuum(i) > 0) THEN
        WRITE(iu_nml, &
          '(3x, a15, a1, i3, a1, 1x, i3, a1, t38, a1, t40, i3, a1)') &
          ('INDEX_CONTINUUM', '(', i, ',' ,  j, ')', '=', &
          Spectrum%Cont%index_continuum(i, j), ',', &
          j=1, Spectrum%Cont%n_band_continuum(i))
      ENDIF
    ENDDO
!
    WRITE(iu_nml, '(3x, a11, t38, a1, t40, i3, a1)') &
      'INDEX_WATER', '=', Spectrum%Cont%index_water, ','
!
!
!
  END SUBROUTINE nml_write_block_8_int
!
!
!
  SUBROUTINE nml_write_block_9_int(SpBasic, SpCont)
!
!
!
    TYPE  (StrSpecBasic) :: SpBasic
    TYPE  (StrSpecCont) :: SpCont
!
!   Local variables.
    INTEGER :: i
!     Loop variable
    INTEGER :: j
!     Loop variable
    INTEGER :: l
!     Loop variable
    INTEGER :: i_index
!     Index of gas
!
!
!
    WRITE(iu_nml, '(2x, a12, t38, a1, t40, a7)') &
      'L_PRESENT(9)', '=', '.TRUE.,'
!
    DO i=1, SpBasic%n_band
      DO j=1, SpCont%n_band_continuum(i)
        i_index=SpCont%index_continuum(i, j)
        WRITE(iu_nml, &
          '(3x, a16, a1, i3, a1, 1x, i3, a1, t38, a1, t40, i3, a1)') &
          'I_SCALE_FNC_CONT', '(', i, ',',  i_index, ')', '=', &
          SpCont%i_scale_fnc_cont(i, i_index), ','
        WRITE(iu_nml, &
          '((3x, a15, a1, i3, a1, 1x, i3, a1, t38, a1, t40, 1pe16.9, a1))') &
          'P_REF_CONTINUUM', '(', i_index, ',',  i, ')', '=', &
          SpCont%p_ref_cont(i_index, i), ',', &
          'T_REF_CONTINUUM', '(', i_index, ',',  i, ')', '=', &
          SpCont%t_ref_cont(i_index, i), ','
        WRITE(iu_nml, &
          '((3x, a11, a1, i3, a1, 1x, i3, a1, t38, a1, t40, 1pe16.9, a1))') &
          'K_CONTINUUM', '(', i, ',',  i_index, ')', '=', &
          SpCont%k_cont(i, i_index), ','
        IF ( (SpCont%i_scale_fnc_cont(i, i_index) == &
               IP_scale_power_law)       .OR. &
             (SpCont%i_scale_fnc_cont(i, i_index) == &
               IP_scale_power_quad)      .OR. &
             (SpCont%i_scale_fnc_cont(i, i_index) == &
               IP_scale_doppler_quad) ) THEN
          WRITE(iu_nml, &
            '(3x, a19, i3, a2, i3, a1, t38, a1, (t40, 2(1pe16.9, ", ")))') &
            'SCALE_CONTINUUM(1, ', i, ', ', i_index, ')', '=', &
            SpCont%scale_cont(1: &
            n_scale_variable(SpCont%i_scale_fnc_cont &
            (i, i_index)), i, i_index)
        ENDIF
      ENDDO
    ENDDO
!
!
!
  END SUBROUTINE nml_write_block_9_int
!
!
!
  SUBROUTINE nml_write_block_10_int(SpBasic, SpDrop)
!
!
!
!   Dummy variables:
    INTEGER :: i_d
!     Type of droplet
    TYPE  (StrSpecBasic), Intent(IN) :: SpBasic
    TYPE  (StrSpecDrop), Intent(IN) :: SpDrop
!
!
!
!   Local variables.
    INTEGER :: highest_type
!     Type present with the highest number
    INTEGER :: n_phf_term_used
!     Number of terms in the phase function to written to
!     the output namelist: this allows us to write out just
!     the asymmetry for use in older versions of the model
    INTEGER :: n_parameter
!     Number of parameters
    INTEGER :: i_b
!     Loop variable over bands
    INTEGER :: i_dr
!     Loop variable over droplets

!   Functions called:
    INTEGER, EXTERNAL :: set_n_cloud_parameter


!   Find the highest number indexing the type actually present and
!   write data only as far as that type. This helps to prevent some
!   obscure errors when reading namelists.
    highest_type=0
    DO i_dr=1, Spectrum%Dim%nd_drop_type
      IF (SpDrop%l_drop_type(i_dr)) highest_type = i_dr
    ENDDO
!
    WRITE(iu_nml, '(2x, a13, t38, a1, t40, a7)') &
      'L_PRESENT(10)', '=', '.TRUE.,'
!
    DO i_dr=1, highest_type
!
      IF ( SpDrop%l_drop_type(i_dr) .AND. &
           ( (SpDrop%i_drop_parm(i_dr) == IP_slingo_schrecker) .OR. &
	     (SpDrop%i_drop_parm(i_dr) == IP_slingo_schr_PHF) .OR. &
             (SpDrop%i_drop_parm(i_dr) == IP_ackerman_stephens) .OR. &
             (SpDrop%i_drop_parm(i_dr) == IP_drop_pade_2) ) ) THEN
!
!
        WRITE(iu_nml, '(3x, a11, a1, i3, a1, t38, a1, t40, a7)') &
          'L_DROP_TYPE', '(', i_dr, ')', '=', '.TRUE.,'
        WRITE(iu_nml, '(3x, a22, a1, i3, a1, 1x, a1, 1x, t35, i3, a1)') &
          'I_DROP_PARAMETRIZATION', '(', i_dr, ')', '=', &
          SpDrop%i_drop_parm(i_dr), ','
!
!       The range of validity of the parametrization will
!       be written out only if it is not set to zero.
!       these variables will be recognised by the UM only
!       at version 4.4 and above: this test should ensure
!       consistency at earlier releases.
        IF (SpDrop%parm_max_dim(i_dr) > 0.0) THEN
          WRITE(iu_nml, &
            '(3x, a17, a1, i3, a1, t38, a1, t40, 1pe16.9, a1)') &
            'DROP_PARM_MIN_DIM', '(', i_dr, ')', '=', &
            SpDrop%parm_min_dim(i_dr), ','
          WRITE(iu_nml, &
            '(3x, a17, a1, i3, a1, t38, a1, t40, 1pe16.9, a1)') &
            'DROP_PARM_MAX_DIM', '(', i_dr, ')', '=', &
            SpDrop%parm_max_dim(i_dr), ','
        ENDIF
!
        IF (l_asymmetry) THEN
          n_phf_term_used=1
        ELSE
          n_phf_term_used=SpDrop%n_phf(i_dr)
          WRITE(iu_nml, &
            '(3x, a15, a1, i3, a1, t38, a1, t40, i5, a1)') &
            'N_DROP_PHF_TERM', '(', i_dr, ')', '=', n_phf_term_used, ','
        ENDIF
!       Calculate the number of parameters for the scheme.
        n_parameter = set_n_cloud_parameter( &
          SpDrop%i_drop_parm(i_dr), ip_clcmp_st_water, n_phf_term_used)
!
!       Write out the scattering parameters in each band.
        DO i_b=1, SpBasic%n_band
          WRITE(iu_nml, &
            '(6x, a19, a4, i3, a1, i3, a1, t43, a1, '// &
            '(t45, 2(1pe12.5, ", ")))') &
            'DROP_PARAMETER_LIST', '(1, ', i_b, ',', i_dr, ')', '=', &
            SpDrop%parm_list(1: n_parameter, i_b, i_dr)
        ENDDO
!
      ELSE
!
        WRITE(iu_nml, '(3x, a11, a1, i3, a1, t38, a1, t40, a8)') &
          'L_DROP_TYPE', '(', i_dr, ')', '=', '.FALSE.,'
!
      ENDIF
!
    ENDDO
!
!
!
  END SUBROUTINE nml_write_block_10_int
!
!
!
  SUBROUTINE nml_write_block_11_int(SpBasic, SpAerosol)
!
!
!
    TYPE  (StrSpecBasic), Intent(IN) :: SpBasic
    TYPE  (StrSpecAerosol), Intent(IN) :: SpAerosol
!
!   Local variables.
    INTEGER :: highest_type
!     Type present with the highest number
    INTEGER :: n_phf_term_used
!     Number of terms in the phase function to written to
!     the output namelist: this allows us to write out just
!     the asymmetry for use in older versions of the model
    INTEGER :: i_a
!     Species of aerosol
    INTEGER :: n_values
!     Number of values of the humidity
    INTEGER :: i
!     Loop variable
    INTEGER :: j
!     Loop variable
    INTEGER :: k
!     Loop variable
    INTEGER :: l
!     Loop variable
!
!
!
!   Find the highest number indexing the type actually present and
!   write data only as far as that type. This helps to prevent some
!   obscure errors when reading namelists.
    highest_type=0
    DO i_a=1, Spectrum%Dim%nd_aerosol_species
      IF (SpAerosol%l_aero_spec(i_a)) highest_type = i_a
    ENDDO
!
    WRITE(iu_nml, '(2x, a13, t38, a1, t40, a7)') &
      'L_PRESENT(11)', '=', '.TRUE.,'
!
    DO i_a=1, highest_type
!
      IF ( SpAerosol%l_aero_spec(i_a) .AND. &
           ( (SpAerosol%i_aerosol_parm(i_a) == &
                IP_aerosol_param_dry) .OR. &
             (SpAerosol%i_aerosol_parm(i_a) == &
                IP_aerosol_param_phf_dry) .OR. &
             (SpAerosol%i_aerosol_parm(i_a) == &
                IP_aerosol_param_phf_moist) .OR. &
             (SpAerosol%i_aerosol_parm(i_a) == &
                IP_aerosol_param_moist) ) ) THEN
        WRITE(iu_nml, '(3x, a17, a1, i3, a1, t38, a1, t40, a7)') &
          'L_AEROSOL_SPECIES', '(', i_a, ')', '=', '.TRUE.,'
        WRITE(iu_nml, '(3x, a25, a1, i3, a1, 1x, a1, 1x, t38, i3, a1)') &
          'I_AEROSOL_PARAMETRIZATION', '(', i_a, ')', '=', &
          SpAerosol%i_aerosol_parm(i_a), ','
!
        SELECT CASE(SpAerosol%i_aerosol_parm(i_a))
          CASE(IP_aerosol_param_dry, IP_aerosol_param_phf_dry)
            n_values=1
          CASE(IP_aerosol_param_moist, IP_aerosol_param_phf_moist)
            WRITE(iu_nml, '(3x, a9, a1, i3, a1, t38, a1, t40, i5, a1)') &
              'NHUMIDITY', '(', i_a, ')', '=', SpAerosol%nhumidity(i_a), ','
            WRITE(iu_nml, &
              '(6x, a10, a3, 1x, i3, a1, t48, a1, 1x, ' // &
              '(t50, 2(1pe12.5, ", ")))') &
              'HUMIDITIES', '(1,', i_a, ')', '=', &
              SpAerosol%humidities(1:SpAerosol%nhumidity(i_a), i_a)
            n_values=SpAerosol%nhumidity(i_a)
        END SELECT
!
!       Write out the scattering parameters in each band.
        DO j=1, SpBasic%n_band
           WRITE(iu_nml, '(6x, a18, a4, i3, a1, i3, a1, t48, a1, ' // &
             '(t50, 2(1pe12.5, ", ")))') &
             'AEROSOL_ABSORPTION', '(1, ', i_a, &
             ',', j, ')', '=', &
             SpAerosol%abs(1:n_values, i_a, j)
           WRITE(iu_nml, '(6x, a18, a4, i3, a1, i3, a1, t48, a1, ' // &
             '(t50, 2(1pe12.5, ", ")))') &
             'AEROSOL_SCATTERING', '(1, ', i_a, &
             ',', j, ')', '=', &
             SpAerosol%scat(1:n_values, i_a, j)
           IF (l_asymmetry) THEN
             WRITE(iu_nml, '(6x, a17, a4, i3, a1, i3, a1, t48, a1, ' // &
               '(t50, 2(1pe12.5, ", ")))') &
               'AEROSOL_ASYMMETRY', '(1, ', i_a, &
               ',', j, ')', '=', &
               SpAerosol%phf_fnc(1:n_values, 1, i_a, j)
           ELSE
             DO k=1, SpAerosol%n_aerosol_phf_term(i_a)
               WRITE(iu_nml, '(6x, a17, a4, i3, a1, i3, a1, i3, a1, ' // &
                 't48, a1, (t50, 2(1pe12.5, ", ")))') &
                 'AEROSOL_PHASE_FNC', '(1, ', k, ',', i_a, &
                 ',', j, ')', '=', &
                 SpAerosol%phf_fnc(1:n_values, k, i_a, j)
             ENDDO
           ENDIF
        ENDDO
!
      ENDIF
!
    ENDDO
!
!
!
  END SUBROUTINE nml_write_block_11_int
!
!
!
  SUBROUTINE nml_write_block_12_int(SpBasic, SpIce)
!
!
!
    TYPE  (StrSpecBasic), Intent(IN) :: SpBasic
    TYPE  (StrSpecIce), Intent(IN) :: SpIce
!
!
!
!   Local variables.
    INTEGER :: highest_type
!     Type present with the highest number
    INTEGER :: n_phf_term_used
!     Number of terms in the phase function to written to
!     the output namelist: this allows us to write out just
!     the asymmetry for use in older versions of the model
    INTEGER :: n_parameter
!     Number of parameters
    INTEGER :: i_b
!     Loop variable (over bands)
    INTEGER :: i_i
!     Loop variable
    INTEGER :: i
!     Loop variable

!   Functions called:
    INTEGER, EXTERNAL :: set_n_cloud_parameter


!   Find the highest number indexing the type actually present and
!   write data only as far as that type. This helps to prevent some
!   obscure errors when reading namelists.
    highest_type=0
    DO i_i=1, Spectrum%Dim%nd_ice_type
      IF (SpIce%l_ice_type(i_i)) highest_type = i_i
    ENDDO
!
    WRITE(iu_nml, '(2x, a13, t38, a1, t40, a7)') &
      'L_PRESENT(12)', '=', '.TRUE.,'
!
    DO i_i=1, highest_type
!
      IF ( SpIce%l_ice_type(i_i) .AND. &
           ( (SpIce%i_ice_parm(i_i) == IP_slingo_schrecker_ice) .OR. &
             (SpIce%i_ice_parm(i_i) == IP_ice_adt) .OR. &
             (SpIce%i_ice_parm(i_i) == IP_ice_fu_solar) .OR. &
             (SpIce%i_ice_parm(i_i) == IP_ice_fu_ir) .OR. &
             (SpIce%i_ice_parm(i_i) == IP_slingo_schr_ice_phf) .OR. &
             (SpIce%i_ice_parm(i_i) == IP_ice_fu_phf) .OR. &
             (SpIce%i_ice_parm(i_i) == IP_ice_adt_10) ) ) THEN
!
!
        WRITE(iu_nml, '(3x, a11, a1, i3, a1, t38, a1, t40, a7)') &
          'L_ICE_TYPE', '(', i_i, ')', '=', '.TRUE.,'
        WRITE(iu_nml, '(3x, a22, a1, i3, a1, 1x, a1, 1x, t35, i3, a1)') &
          'I_ICE_PARAMETRIZATION', '(', i_i, ')', '=', &
          SpIce%i_ice_parm(i_i), ','
!
!       The range of validity of the parametrization will
!       be written out only if it is not set to zero.
!       these variables will be recognised by the UM only
!       at version 4.4 and above: this test should ensure
!       consistency at earlier releases.
        IF (SpIce%parm_max_dim(i_i) > 0.0) THEN
          WRITE(iu_nml, &
            '(3x, a17, a1, i3, a1, t38, a1, t40, 1pe16.9, a1)') &
            'ICE_PARM_MIN_DIM', '(', i_i, ')', '=', &
            SpIce%parm_min_dim(i_i), ','
          WRITE(iu_nml, &
            '(3x, a17, a1, i3, a1, t38, a1, t40, 1pe16.9, a1)') &
            'ICE_PARM_MAX_DIM', '(', i_i, ')', '=', &
            SpIce%parm_max_dim(i_i), ','
        ENDIF
!
        IF (l_asymmetry) THEN
          n_phf_term_used=1
        ELSE
          n_phf_term_used=SpIce%n_phf(i_i)
          WRITE(iu_nml, &
            '(3x, a15, a1, i3, a1, t38, a1, t40, i5, a1)') &
            'N_ICE_PHF_TERM', '(', i_i, ')', '=', n_phf_term_used, ','
        ENDIF
!       Calculate the number of parameters for the scheme.
        n_parameter = set_n_cloud_parameter( &
          SpIce%i_ice_parm(i_i), ip_clcmp_st_ice, n_phf_term_used)
!
!       Write out the scattering parameters in each band.
        DO i_b=1, SpBasic%n_band
          WRITE(iu_nml, '(6x, a19, a4, i3, a1, i3, ' // &
            ' a1, t43, a1, (t45, 2(1pe12.5, ", ")))') &
            'ICE_PARAMETER_LIST', '(1, ', i_b, ',', i_i, ')', '=', &
            SpIce%parm_list(1: n_parameter, i_b, i_i)
        ENDDO
!
      ELSE
!
        WRITE(iu_nml, '(3x, a11, a1, i3, a1, t38, a1, t40, a8)') &
          'L_ICE_TYPE', '(', i_i, ')', '=', '.FALSE.,'
!
      ENDIF
!
    ENDDO
!
!
!
  END SUBROUTINE nml_write_block_12_int
!
!
!
  SUBROUTINE nml_write_block_14_int(SpBasic)
!
!
!
    TYPE  (StrSpecBasic), Intent(IN) :: SpBasic
!
!   Local variables
    INTEGER :: i
!     Loop variable
!
!
!
    WRITE(iu_nml, '(2x, a13, t38, a1, t40, a7)') &
      'L_PRESENT(14)', '=', '.TRUE.,'
!
    DO i=1, SpBasic%n_band
      WRITE(iu_nml, '(3x, a14, a1, i3, a1, 1x, a1, 1x, i3, a1)') &
        'N_BAND_EXCLUDE', '(', i, ')', '=', &
        SpBasic%n_band_exclude(i), ','
      IF (SpBasic%n_band_exclude(i) > 0) THEN
        WRITE(iu_nml, &
          '((6x, a13, a1, 2x, a1, a2, i3, a1, 1x, a1, 1x, 2(t40, i3, ", ")))') &
          'INDEX_EXCLUDE', '(', '1', ', ', i, ')', '=', &
          SpBasic%index_exclude(1:SpBasic%n_band_exclude(i), i) 
      ENDIF
    ENDDO
!
!
!
  END SUBROUTINE nml_write_block_14_int
!
!
!
END SUBROUTINE out_nml
