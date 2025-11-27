! *****************************COPYRIGHT*******************************
! (C) Crown copyright Met Office. All rights reserved.
! For further details please refer to the file COPYRIGHT.txt
! which you should have received as part of this distribution.
! *****************************COPYRIGHT*******************************
!
!+ Program to convert a spectral file to a namelist.
!
PROGRAM spec_nml
!
! Description:
!   This program converts a spectral file to a namelist for
!   use in the Unified Model.
!
! Method:
!   A spectral file is read using the standard format and 
!   simply written out.
!
! Code Description:
!   Fortran 90
!
! Modules used:
  USE dimensions_spec_ucf
  USE def_std_io_icf
  USE error_pcf
  USE def_spectrum
!
!
  IMPLICIT NONE
!
!
!
  CHARACTER  (LEN=80) :: file_spectral
!   Name of spectral file
  TYPE (StrSpecData) :: Spectrum
!   Spectral data
!
  INTEGER :: ierr = i_normal
!   Error flag
  LOGICAL :: l_interactive
!   Flag for interactive operation
  LOGICAL :: l_asymmetry
!   Flag to write asymmetries
  CHARACTER  (LEN=1) :: char_tf
!   Character response flag
!
! External functions:
  LOGICAL, EXTERNAL :: set_interactive
!   Function to set the flag for interactive operation
!
!- End of header


! Set the flag for interactive operation
  l_interactive=set_interactive()

! Read in the spectral file.
  WRITE(iu_stdout, '(/a)') &
     'Enter name of file to be converted to namelist.'
  READ(iu_stdin, '(a)') file_spectral
  CALL read_spectrum(file_spectral, Spectrum)

  WRITE(iu_stdout, '(/a)') &
    'Enter "T" to write asymmetries to the output file'
  READ(iu_stdin, '(a)') char_tf
  l_asymmetry = ( (char_tf == 'T') .OR. (char_tf == 't') )

  CALL out_nml(Spectrum, l_asymmetry, l_interactive, ierr)

END PROGRAM spec_nml
