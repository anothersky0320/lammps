! -------------------------------------------------------------------------
!   LAMMPS - Large-scale Atomic/Molecular Massively Parallel Simulator
!   https://www.lammps.org/ Sandia National Laboratories
!   Steve Plimpton, sjplimp@sandia.gov
!
!   Copyright (2003) Sandia Corporation.  Under the terms of Contract
!   DE-AC04-94AL85000 with Sandia Corporation, the U.S. Government retains
!   certain rights in this software.  This software is distributed under
!   the GNU General Public License.
!
!   See the README file in the top-level LAMMPS directory.
! -------------------------------------------------------------------------
!
! Fortran interface to the LAMMPS library implemented as a Fortran 2003
! style module that wraps the C-style library interface in library.cpp
! and library.h using the ISO_C_BINDING module of the Fortran compiler.
!
! Based on the LAMMPS Fortran 2003 module contributed by:
!   Karl D. Hammond <hammondkd@missouri.edu>
!   University of Missouri, 2012-2020
!
! The Fortran module tries to follow the API of the C library interface
! closely, but like the Python wrapper it employs an object-oriented
! approach.  To accommodate the object-oriented approach, all exported
! subroutines and functions have to be implemented in Fortran and
! call the interfaced C-style functions with adapted calling conventions
! as needed.  The C library interface functions retain their names
! starting with "lammps_", while the Fortran versions start with "lmp_".
!
MODULE LIBLAMMPS

  USE, INTRINSIC :: ISO_C_BINDING, ONLY: c_ptr, c_null_ptr, C_ASSOCIATED, &
    C_LOC, c_int, c_int64_t, c_char, c_null_char, c_double, c_size_t, &
    C_F_POINTER

  IMPLICIT NONE
  PRIVATE
  PUBLIC :: lammps, ASSIGNMENT(=)

  ! Data type constants for extracting data from global, atom, compute, and fix
  !
  ! Must be kept in sync with the equivalent declarations in
  ! src/library.h and python/lammps/constants.py
  !
  ! These are NOT part of the API (the part the user sees)
  INTEGER(c_int), PARAMETER :: &
    LAMMPS_INT = 0, &         ! 32-bit integer (array)
    LAMMPS_INT_2D = 1, &      ! two-dimensional 32-bit integer array
    LAMMPS_DOUBLE = 2, &      ! 64-bit double (array)
    LAMMPS_DOUBLE_2D = 3, &   ! two-dimensional 64-bit double array
    LAMMPS_INT64 = 4, &       ! 64-bit integer (array)
    LAMMPS_INT64_2D = 5, &    ! two-dimensional 64-bit integer array
    LAMMPS_STRING = 6, &      ! C-String
    LMP_STYLE_GLOBAL = 0, &   ! request global compute/fix/etc. data
    LMP_STYLE_ATOM = 1, &     ! request per-atom compute/fix/etc. data
    LMP_STYLE_LOCAL = 2, &    ! request local compute/fix/etc. data
    LMP_TYPE_SCALAR = 0, &    ! request scalar
    LMP_TYPE_VECTOR = 1, &    ! request vector
    LMP_TYPE_ARRAY = 2, &     ! request array
    LMP_SIZE_VECTOR = 3, &    ! request size of vector
    LMP_SIZE_ROWS = 4, &      ! request rows (actually columns)
    LMP_SIZE_COLS = 5, &      ! request colums (actually rows)
    LMP_ERROR_WARNING = 0, &  ! call Error::warning()
    LMP_ERROR_ONE = 1, &      ! call Error::one() (from this MPI rank)
    LMP_ERROR_ALL = 2, &      ! call Error::all() (from all MPI ranks)
    LMP_ERROR_WORLD = 4, &    ! error on comm->world
    LMP_ERROR_UNIVERSE = 8, & ! error on comm->universe
    LMP_VAR_EQUAL = 0, &      ! equal-style variables (and compatible)
    LMP_VAR_ATOM = 1, &       ! atom-style variables
    LMP_VAR_VECTOR = 2, &     ! vector variables
    LMP_VAR_STRING = 3        ! string variables (everything else)

  ! "Constants" to use with extract_compute and friends
  TYPE lammps_style
    INTEGER(c_int) :: global, atom, local
  END TYPE lammps_style

  TYPE lammps_type
    INTEGER(c_int) :: scalar, vector, array
  END TYPE lammps_type

  TYPE lammps
    TYPE(c_ptr) :: handle = c_null_ptr
    TYPE(lammps_style) :: style
    TYPE(lammps_type) :: type
  CONTAINS
    PROCEDURE :: close                  => lmp_close
    PROCEDURE :: error                  => lmp_error
    PROCEDURE :: file                   => lmp_file
    PROCEDURE :: command                => lmp_command
    PROCEDURE :: commands_list          => lmp_commands_list
    PROCEDURE :: commands_string        => lmp_commands_string
    PROCEDURE :: get_natoms             => lmp_get_natoms
    PROCEDURE :: get_thermo             => lmp_get_thermo
    PROCEDURE :: extract_box            => lmp_extract_box
    PROCEDURE :: reset_box              => lmp_reset_box
    PROCEDURE :: memory_usage           => lmp_memory_usage
    PROCEDURE :: get_mpi_comm           => lmp_get_mpi_comm
    PROCEDURE :: extract_setting        => lmp_extract_setting
    PROCEDURE :: extract_global         => lmp_extract_global
    PROCEDURE :: extract_atom           => lmp_extract_atom
    PROCEDURE :: extract_compute        => lmp_extract_compute
    PROCEDURE :: extract_fix            => lmp_extract_fix
    PROCEDURE :: extract_variable       => lmp_extract_variable
    PROCEDURE :: set_variable           => lmp_set_variable
    PROCEDURE, PRIVATE :: lmp_gather_atoms_int
    PROCEDURE, PRIVATE :: lmp_gather_atoms_double
    GENERIC   :: gather_atoms           => lmp_gather_atoms_int, &
                                           lmp_gather_atoms_double
    PROCEDURE, PRIVATE :: lmp_gather_atoms_concat_int
    PROCEDURE, PRIVATE :: lmp_gather_atoms_concat_double
    GENERIC   :: gather_atoms_concat    => lmp_gather_atoms_concat_int, &
                                           lmp_gather_atoms_concat_double
    PROCEDURE, PRIVATE :: lmp_gather_atoms_subset_int
    PROCEDURE, PRIVATE :: lmp_gather_atoms_subset_double
    GENERIC   :: gather_atoms_subset    => lmp_gather_atoms_subset_int, &
                                           lmp_gather_atoms_subset_double
    PROCEDURE, PRIVATE :: lmp_scatter_atoms_int
    PROCEDURE, PRIVATE :: lmp_scatter_atoms_double
    GENERIC   :: scatter_atoms          => lmp_scatter_atoms_int, &
                                           lmp_scatter_atoms_double
!
    PROCEDURE, PRIVATE :: lmp_scatter_atoms_subset_int
    PROCEDURE, PRIVATE :: lmp_scatter_atoms_subset_double
    GENERIC   :: scatter_atoms_subset   => lmp_scatter_atoms_subset_int, &
                                           lmp_scatter_atoms_subset_double
    PROCEDURE :: version                => lmp_version
    PROCEDURE,NOPASS :: get_os_info     => lmp_get_os_info
    PROCEDURE,NOPASS :: config_has_mpi_support => lmp_config_has_mpi_support
    PROCEDURE,NOPASS :: config_has_gzip_support => lmp_config_has_gzip_support
    PROCEDURE,NOPASS :: config_has_png_support => lmp_config_has_png_support
    PROCEDURE,NOPASS :: config_has_jpeg_support => lmp_config_has_jpeg_support
    PROCEDURE,NOPASS :: config_has_ffmpeg_support &
      => lmp_config_has_ffmpeg_support
    PROCEDURE,NOPASS :: config_has_exceptions => lmp_config_has_exceptions
    PROCEDURE,NOPASS :: config_has_package => lmp_config_has_package
    PROCEDURE,NOPASS :: config_package_count => lammps_config_package_count
    PROCEDURE,NOPASS :: config_package_name => lmp_config_package_name
    PROCEDURE,NOPASS :: installed_packages => lmp_installed_packages
!
    PROCEDURE :: flush_buffers          => lmp_flush_buffers
    PROCEDURE :: is_running             => lmp_is_running
    PROCEDURE :: force_timeout          => lmp_force_timeout
    PROCEDURE :: has_error              => lmp_has_error
    PROCEDURE :: get_last_error_message => lmp_get_last_error_message
  END TYPE lammps

  INTERFACE lammps
    MODULE PROCEDURE lmp_open
  END INTERFACE lammps

  ! Constants to use in working with lammps_data
  ENUM, BIND(C)
    ENUMERATOR :: DATA_INT, DATA_INT_1D, DATA_INT_2D
    ENUMERATOR :: DATA_INT64, DATA_INT64_1D, DATA_INT64_2D
    ENUMERATOR :: DATA_DOUBLE, DATA_DOUBLE_1D, DATA_DOUBLE_2D
    ENUMERATOR :: DATA_STRING
  END ENUM

  ! Base class for receiving LAMMPS data (to reduce code duplication)
  TYPE lammps_data_baseclass
    INTEGER(c_int) :: datatype = -1_c_int
    ! in case we need to call the Error class in an assignment
    CLASS(lammps), POINTER, PRIVATE :: lammps_instance => NULL()
  END TYPE lammps_data_baseclass

  ! Derived type for receiving LAMMPS data (in lieu of the ability to type cast
  ! pointers). Used for extract_compute, extract_atom
  TYPE, EXTENDS(lammps_data_baseclass) :: lammps_data
    INTEGER(c_int), POINTER :: i32 => NULL()
    INTEGER(c_int), DIMENSION(:), POINTER :: i32_vec => NULL()
    INTEGER(c_int64_t), POINTER :: i64 => NULL()
    INTEGER(c_int64_t), DIMENSION(:), POINTER :: i64_vec => NULL()
    REAL(c_double), POINTER :: r64 => NULL()
    REAL(c_double), DIMENSION(:), POINTER :: r64_vec => NULL()
    REAL(c_double), DIMENSION(:,:), POINTER :: r64_mat => NULL()
    CHARACTER(LEN=:), ALLOCATABLE :: str
  END TYPE lammps_data

  ! Derived type for holding LAMMPS fix data
  ! Done this way because fix global data are not pointers, but computed
  ! on-the-fly, whereas per-atom and local data are pointers to the actual
  ! array. Doing it this way saves the user from having to explicitly
  ! deallocate all of the pointers.
  TYPE, EXTENDS(lammps_data_baseclass) :: lammps_fix_data
    REAL(c_double) :: r64
    REAL(c_double), DIMENSION(:), POINTER :: r64_vec => NULL()
    REAL(c_double), DIMENSION(:,:), POINTER :: r64_mat => NULL()
  END TYPE lammps_fix_data

  ! Derived type for holding LAMMPS variable data
  ! Done this way because extract_variable calculates variable values, it does
  ! not return pointers to LAMMPS data.
  TYPE, EXTENDS(lammps_data_baseclass) :: lammps_variable_data
    REAL(c_double) :: r64
    REAL(c_double), DIMENSION(:), ALLOCATABLE :: r64_vec
    CHARACTER(LEN=:), ALLOCATABLE :: str
  END TYPE lammps_variable_data

  ! This overloads the assignment operator (=) so that assignments of the
  ! form
  !    nlocal = extract_global('nlocal')
  ! which are of the form "pointer to double = type(lammps_data)" result in
  ! re-associating the pointer on the left with the appropriate piece of
  ! LAMMPS data (after checking type-kind-rank compatibility)
  INTERFACE ASSIGNMENT(=)
    MODULE PROCEDURE assign_int_to_lammps_data, assign_int64_to_lammps_data, &
      assign_intvec_to_lammps_data, assign_int64vec_to_lammps_data, &
      assign_double_to_lammps_data, assign_doublevec_to_lammps_data, &
      assign_doublemat_to_lammps_data, &
      assign_string_to_lammps_data
    ! We handle fix data (slightly) differently
    MODULE PROCEDURE assign_double_to_lammps_fix_data, &
      assign_doublevec_to_lammps_fix_data, &
      assign_doublemat_to_lammps_fix_data
    ! Variables, too
    MODULE PROCEDURE assign_double_to_lammps_variable_data, &
      assign_doublevec_to_lammps_variable_data, &
      assign_string_to_lammps_variable_data
  END INTERFACE

  ! interface definitions for calling functions in library.cpp
  INTERFACE
    FUNCTION lammps_open(argc, argv, comm) BIND(C,name='lammps_open_fortran')
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      INTEGER(c_int), VALUE, INTENT(IN)     :: argc, comm
      TYPE(c_ptr), DIMENSION(*), INTENT(IN) :: argv
      TYPE(c_ptr)                           :: lammps_open
    END FUNCTION lammps_open

    FUNCTION lammps_open_no_mpi(argc, argv, handle) BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      INTEGER(c_int), VALUE, INTENT(IN)     :: argc
      TYPE(c_ptr), DIMENSION(*), INTENT(IN) :: argv
      TYPE(c_ptr), VALUE, INTENT(IN)        :: handle
      TYPE(c_ptr)                           :: lammps_open_no_mpi
    END FUNCTION lammps_open_no_mpi

    SUBROUTINE lammps_close(handle) BIND(C)
      IMPORT :: c_ptr
      IMPLICIT NONE
      TYPE(c_ptr), VALUE :: handle
    END SUBROUTINE lammps_close

    SUBROUTINE lammps_mpi_init() BIND(C)
    END SUBROUTINE lammps_mpi_init

    SUBROUTINE lammps_mpi_finalize() BIND(C)
    END SUBROUTINE lammps_mpi_finalize

    SUBROUTINE lammps_kokkos_finalize() BIND(C)
    END SUBROUTINE lammps_kokkos_finalize

    SUBROUTINE lammps_error(handle, error_type, error_text) BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      TYPE(c_ptr), VALUE :: handle
      INTEGER(c_int), VALUE :: error_type
      TYPE(c_ptr), VALUE :: error_text
    END SUBROUTINE lammps_error

    SUBROUTINE lammps_file(handle, filename) BIND(C)
      IMPORT :: c_ptr
      IMPLICIT NONE
      TYPE(c_ptr), VALUE :: handle
      TYPE(c_ptr), VALUE :: filename
    END SUBROUTINE lammps_file

    SUBROUTINE lammps_command(handle, cmd) BIND(C)
      IMPORT :: c_ptr
      IMPLICIT NONE
      TYPE(c_ptr), INTENT(IN), VALUE :: handle
      TYPE(c_ptr), INTENT(IN), VALUE :: cmd
    END SUBROUTINE lammps_command

    SUBROUTINE lammps_commands_list(handle, ncmd, cmds) BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      TYPE(c_ptr), INTENT(IN), VALUE        :: handle
      INTEGER(c_int), INTENT(IN), VALUE     :: ncmd
      TYPE(c_ptr), DIMENSION(*), INTENT(IN) :: cmds
    END SUBROUTINE lammps_commands_list

    SUBROUTINE lammps_commands_string(handle, str) BIND(C)
      IMPORT :: c_ptr
      IMPLICIT NONE
      TYPE(c_ptr), INTENT(IN), VALUE :: handle
      TYPE(c_ptr), INTENT(IN), VALUE :: str
    END SUBROUTINE lammps_commands_string

    FUNCTION lammps_get_natoms(handle) BIND(C)
      IMPORT :: c_ptr, c_double
      IMPLICIT NONE
      TYPE(c_ptr), INTENT(IN), VALUE :: handle
      REAL(c_double) :: lammps_get_natoms
    END FUNCTION lammps_get_natoms

    FUNCTION lammps_get_thermo(handle,name) BIND(C)
      IMPORT :: c_ptr, c_double
      IMPLICIT NONE
      REAL(c_double) :: lammps_get_thermo
      TYPE(c_ptr), INTENT(IN), VALUE :: handle
      TYPE(c_ptr), INTENT(IN), VALUE :: name
    END FUNCTION lammps_get_thermo

    SUBROUTINE lammps_extract_box(handle,boxlo,boxhi,xy,yz,xz,pflags, &
        boxflag) BIND(C)
      IMPORT :: c_ptr, c_double, c_int
      IMPLICIT NONE
      TYPE(c_ptr), INTENT(IN), VALUE :: handle, boxlo, boxhi, xy, yz, xz, &
        pflags, boxflag
    END SUBROUTINE lammps_extract_box

    SUBROUTINE lammps_reset_box(handle,boxlo,boxhi,xy,yz,xz) BIND(C)
      IMPORT :: c_ptr, c_double
      IMPLICIT NONE
      TYPE(c_ptr), INTENT(IN), VALUE :: handle
      REAL(c_double), DIMENSION(3), INTENT(IN) :: boxlo, boxhi
      REAL(c_double), INTENT(IN), VALUE :: xy, yz, xz
    END SUBROUTINE lammps_reset_box

    SUBROUTINE lammps_memory_usage(handle,meminfo) BIND(C)
      IMPORT :: c_ptr, c_double
      IMPLICIT NONE
      TYPE(c_ptr), INTENT(IN), VALUE :: handle
      REAL(c_double), DIMENSION(*), INTENT(OUT) :: meminfo
    END SUBROUTINE lammps_memory_usage

    FUNCTION lammps_get_mpi_comm(handle) BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      TYPE(c_ptr), INTENT(IN), VALUE :: handle
      INTEGER(c_int) :: lammps_get_mpi_comm
    END FUNCTION lammps_get_mpi_comm

    FUNCTION lammps_extract_setting(handle,keyword) BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      TYPE(c_ptr), INTENT(IN), VALUE :: handle, keyword
      INTEGER(c_int) :: lammps_extract_setting
    END FUNCTION lammps_extract_setting

    FUNCTION lammps_extract_global_datatype(handle,name) BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      TYPE(c_ptr), INTENT(IN), VALUE :: handle, name
      INTEGER(c_int) :: lammps_extract_global_datatype
    END FUNCTION lammps_extract_global_datatype

    FUNCTION c_strlen(str) BIND(C,name='strlen')
      IMPORT :: c_ptr, c_size_t
      IMPLICIT NONE
      TYPE(c_ptr), INTENT(IN), VALUE :: str
      INTEGER(c_size_t) :: c_strlen
    END FUNCTION c_strlen

    FUNCTION lammps_extract_global(handle, name) BIND(C)
      IMPORT :: c_ptr
      IMPLICIT NONE
      TYPE(c_ptr), INTENT(IN), VALUE :: handle, name
      TYPE(c_ptr) :: lammps_extract_global
    END FUNCTION lammps_extract_global

    FUNCTION lammps_extract_atom_datatype(handle, name) BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      TYPE(c_ptr), INTENT(IN), VALUE :: handle, name
      INTEGER(c_int) :: lammps_extract_atom_datatype
    END FUNCTION lammps_extract_atom_datatype

    FUNCTION lammps_extract_atom(handle, name) BIND(C)
      IMPORT :: c_ptr
      IMPLICIT NONE
      TYPE(c_ptr), INTENT(IN), VALUE :: handle, name
      TYPE(c_ptr) :: lammps_extract_atom
    END FUNCTION lammps_extract_atom

    FUNCTION lammps_extract_compute(handle, id, style, type) BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      TYPE(c_ptr), INTENT(IN), VALUE :: handle, id
      INTEGER(c_int), INTENT(IN), VALUE :: style, type
      TYPE(c_ptr) :: lammps_extract_compute
    END FUNCTION lammps_extract_compute

    FUNCTION lammps_extract_fix(handle, id, style, type, nrow, ncol) BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      TYPE(c_ptr), INTENT(IN), VALUE :: handle, id
      INTEGER(c_int), INTENT(IN), VALUE :: style, type, nrow, ncol
      TYPE(c_ptr) :: lammps_extract_fix
    END FUNCTION lammps_extract_fix

    FUNCTION lammps_extract_variable_datatype(handle,name) BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      TYPE(c_ptr), INTENT(IN), VALUE :: handle, name
      INTEGER(c_int) :: lammps_extract_variable_datatype
    END FUNCTION lammps_extract_variable_datatype

    FUNCTION lammps_extract_variable(handle, name, group) BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      TYPE(c_ptr), INTENT(IN), VALUE :: handle, name, group
      TYPE(c_ptr) :: lammps_extract_variable
    END FUNCTION lammps_extract_variable

    FUNCTION lammps_set_variable(handle, name, str) BIND(C)
      IMPORT :: c_int, c_ptr
      IMPLICIT NONE
      TYPE(c_ptr), VALUE :: handle, name, str
      INTEGER(c_int) :: lammps_set_variable
    END FUNCTION lammps_set_variable

    SUBROUTINE lammps_gather_atoms(handle, name, type, count, data) BIND(C)
      IMPORT :: c_int, c_ptr
      IMPLICIT NONE
      TYPE(c_ptr), VALUE :: handle, name, data
      INTEGER(c_int), VALUE :: type, count
    END SUBROUTINE lammps_gather_atoms

    SUBROUTINE lammps_gather_atoms_concat(handle, name, type, count, data) &
    BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      TYPE(c_ptr), VALUE :: handle, name, data
      INTEGER(c_int), VALUE :: type, count
    END SUBROUTINE lammps_gather_atoms_concat

    SUBROUTINE lammps_gather_atoms_subset(handle, name, type, count, ndata, &
        ids, data) BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      TYPE(c_ptr), VALUE :: handle, name, ids, data
      INTEGER(c_int), VALUE :: type, count, ndata
    END SUBROUTINE lammps_gather_atoms_subset

    SUBROUTINE lammps_scatter_atoms(handle, name, type, count, data) BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      TYPE(c_ptr), VALUE :: handle, name, data
      INTEGER(c_int), VALUE :: type, count
    END SUBROUTINE lammps_scatter_atoms

    SUBROUTINE lammps_scatter_atoms_subset(handle, name, type, count, &
        ndata, ids, data) BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      TYPE(c_ptr), VALUE :: handle, name, ids, data
      INTEGER(c_int), VALUE :: count, ndata, type
    END SUBROUTINE lammps_scatter_atoms_subset

    !SUBROUTINE lammps_gather_bonds

    !SUBROUTINE lammps_gather

    !SUBROUTINE lammps_gather_concat

    !SUBROUTINE lammps_gather_subset

    !SUBROUTINE lammps_scatter_subset

    !(generic / id, type, and image are special) / requires LAMMPS_BIGBIG
    !INTEGER(c_int) FUNCTION lammps_create_atoms

    !INTEGER(c_int) FUNCTION lammps_find_pair_neighlist

    !INTEGER(c_int) FUNCTION lammps_find_fix_neighlist

    !INTEGER(c_int) FUNCTION lammps_find_compute_neighlist

    !INTEGER(c_int) FUNCTION lammps_neighlist_num_elements

    !SUBROUTINE lammps_neighlist_element_neighbors

    FUNCTION lammps_version(handle) BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      TYPE(c_ptr), VALUE :: handle
      INTEGER(c_int) :: lammps_version
    END FUNCTION lammps_version

    SUBROUTINE lammps_get_os_info(buffer, buf_size) BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      TYPE(c_ptr), VALUE :: buffer
      INTEGER(c_int), VALUE :: buf_size
    END SUBROUTINE lammps_get_os_info

    FUNCTION lammps_config_has_mpi_support() BIND(C)
      IMPORT :: c_int
      IMPLICIT NONE
      INTEGER(c_int) :: lammps_config_has_mpi_support
    END FUNCTION lammps_config_has_mpi_support

    FUNCTION lammps_config_has_gzip_support() BIND(C)
      IMPORT :: c_int
      IMPLICIT NONE
      INTEGER(c_int) :: lammps_config_has_gzip_support
    END FUNCTION lammps_config_has_gzip_support

    FUNCTION lammps_config_has_png_support() BIND(C)
      IMPORT :: c_int
      IMPLICIT NONE
      INTEGER(c_int) :: lammps_config_has_png_support
    END FUNCTION lammps_config_has_png_support

    FUNCTION lammps_config_has_jpeg_support() BIND(C)
      IMPORT :: c_int
      IMPLICIT NONE
      INTEGER(c_int) :: lammps_config_has_jpeg_support
    END FUNCTION lammps_config_has_jpeg_support

    FUNCTION lammps_config_has_ffmpeg_support() BIND(C)
      IMPORT :: c_int
      IMPLICIT NONE
      INTEGER(c_int) :: lammps_config_has_ffmpeg_support
    END FUNCTION lammps_config_has_ffmpeg_support

    FUNCTION lammps_config_has_exceptions() BIND(C)
      IMPORT :: c_int
      IMPLICIT NONE
      INTEGER(c_int) :: lammps_config_has_exceptions
    END FUNCTION lammps_config_has_exceptions

    FUNCTION lammps_config_has_package(name) BIND(C)
      IMPORT :: c_int, c_ptr
      IMPLICIT NONE
      TYPE(c_ptr), VALUE :: name
      INTEGER(c_int) :: lammps_config_has_package
    END FUNCTION lammps_config_has_package

    FUNCTION lammps_config_package_count() BIND(C)
      IMPORT :: c_int
      IMPLICIT NONE
      INTEGER(c_int) :: lammps_config_package_count
    END FUNCTION lammps_config_package_count

    FUNCTION lammps_config_package_name(idx, buffer, buf_size) BIND(C)
      IMPORT :: c_int, c_ptr
      IMPLICIT NONE
      INTEGER(c_int) :: lammps_config_package_name
      INTEGER(c_int), VALUE :: idx, buf_size
      TYPE(c_ptr), VALUE :: buffer
    END FUNCTION lammps_config_package_name

    !LOGICAL FUNCTION lammps_config_accelerator
    !LOGICAL FUNCTION lammps_has_gpu_device
    !SUBROUTINE lammps_get_gpu_device

    !LOGICAL FUNCTION lammps_has_id
    !INTEGER(c_int) FUNCTION lammps_id_count
    !SUBROUTINE lammps_id_name

    !INTEGER(c_int) FUNCTION lammps_plugin_count
    !SUBROUTINE lammps_plugin_name

    !Both of these use LAMMPS_BIGBIG
    !INTEGER(LAMMPS_imageint) FUNCTION lammps_encode_image_flags
    !SUBROUTINE lammps_decode_image_flags

    !SUBROUTINE lammps_set_fix_external_callback ! may have trouble....
    !FUNCTION lammps_fix_external_get_force() ! returns real(c_double)(:)

    !SUBROUTINE lammps_fix_external_set_energy_global
    !SUBROUTINE lammps_fix_external_set_energy_peratom
    !SUBROUTINE lammps_fix_external_set_virial_global
    !SUBROUTINE lammps_fix_external_set_virial_peratom
    !SUBROUTINE lammps_fix_external_set_vector_length
    !SUBROUTINE lammps_fix_external_set_vector

    SUBROUTINE lammps_flush_buffers(handle) BIND(C)
      IMPORT :: c_ptr
      IMPLICIT NONE
      TYPE(c_ptr), VALUE :: handle
    END SUBROUTINE lammps_flush_buffers

    FUNCTION lammps_malloc(size) BIND(C, name='malloc')
      IMPORT :: c_ptr, c_size_t
      IMPLICIT NONE
      INTEGER(c_size_t), VALUE :: size
      TYPE(c_ptr) :: lammps_malloc
    END FUNCTION lammps_malloc

    SUBROUTINE lammps_free(ptr) BIND(C)
      IMPORT :: c_ptr
      IMPLICIT NONE
      TYPE(c_ptr), VALUE :: ptr
    END SUBROUTINE lammps_free

    INTEGER(c_int) FUNCTION lammps_is_running(handle) BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      TYPE(c_ptr), VALUE :: handle
    END FUNCTION lammps_is_running

    SUBROUTINE lammps_force_timeout(handle) BIND(C)
      IMPORT :: c_ptr
      IMPLICIT NONE
      TYPE(c_ptr), VALUE :: handle
    END SUBROUTINE lammps_force_timeout

    INTEGER(c_int) FUNCTION lammps_has_error(handle) BIND(C)
      IMPORT :: c_ptr, c_int
      IMPLICIT NONE
      TYPE(c_ptr), VALUE :: handle
    END FUNCTION lammps_has_error

    INTEGER(c_int) FUNCTION lammps_get_last_error_message &
        (handle, buffer, buf_size) BIND(C)
      IMPORT :: c_ptr, c_int, c_char
      IMPLICIT NONE
      TYPE(c_ptr), VALUE :: handle, buffer
      INTEGER(c_int), VALUE :: buf_size
    END FUNCTION lammps_get_last_error_message

  END INTERFACE

CONTAINS
  ! Fortran wrappers and helper functions.

  ! Constructor for the LAMMPS class.
  ! Combined wrapper around lammps_open_fortran() and lammps_open_no_mpi()
  TYPE(lammps) FUNCTION lmp_open(args, comm)
    INTEGER, INTENT(IN), OPTIONAL :: comm
    CHARACTER(LEN=*), INTENT(IN), OPTIONAL :: args(:)
    TYPE(c_ptr), ALLOCATABLE     :: argv(:)
    INTEGER(c_int)               :: i, c_comm, argc

    IF (PRESENT(args)) THEN
        ! convert fortran argument list to c style
        argc = SIZE(args)
        ALLOCATE(argv(argc))
        DO i=1, argc
           argv(i) = f2c_string(args(i))
        END DO
    ELSE
        argc = 1
        ALLOCATE(argv(1))
        argv(1) = f2c_string("liblammps")
    ENDIF

    IF (PRESENT(comm)) THEN
        c_comm = comm
        lmp_open%handle = lammps_open(argc, argv, c_comm)
    ELSE
        lmp_open%handle = lammps_open_no_mpi(argc, argv, c_null_ptr)
    END IF

    ! Clean up allocated memory
    DO i=1, argc
        CALL lammps_free(argv(i))
    END DO
    DEALLOCATE(argv)

    ! Assign style and type members so lmp_open%style%global and such work
    lmp_open%style%global = LMP_STYLE_GLOBAL
    lmp_open%style%atom = LMP_STYLE_ATOM
    lmp_open%style%local = LMP_STYLE_LOCAL
    lmp_open%type%scalar = LMP_TYPE_SCALAR
    lmp_open%type%vector = LMP_TYPE_VECTOR
    lmp_open%type%array = LMP_TYPE_ARRAY
  END FUNCTION lmp_open

  ! Combined Fortran wrapper around lammps_close() and lammps_mpi_finalize()
  SUBROUTINE lmp_close(self, finalize)
    CLASS(lammps), INTENT(IN) :: self
    LOGICAL, INTENT(IN), OPTIONAL :: finalize

    CALL lammps_close(self%handle)

    IF (PRESENT(finalize)) THEN
        IF (finalize) THEN
            CALL lammps_kokkos_finalize()
            CALL lammps_mpi_finalize()
        END IF
    END IF
  END SUBROUTINE lmp_close

  ! equivalent function to lammps_error()
  SUBROUTINE lmp_error(self, error_type, error_text)
    CLASS(lammps) :: self
    INTEGER :: error_type
    CHARACTER(len=*) :: error_text
    TYPE(c_ptr) :: str

    str = f2c_string(error_text)
    CALL lammps_error(self%handle, error_type, str)
    CALL lammps_free(str)
  END SUBROUTINE lmp_error

  ! equivalent function to lammps_file()
  SUBROUTINE lmp_file(self, filename)
    CLASS(lammps), INTENT(IN) :: self
    CHARACTER(len=*) :: filename
    TYPE(c_ptr) :: str

    str = f2c_string(filename)
    CALL lammps_file(self%handle, str)
    CALL lammps_free(str)
  END SUBROUTINE lmp_file

  ! equivalent function to lammps_command()
  SUBROUTINE lmp_command(self, cmd)
    CLASS(lammps), INTENT(IN) :: self
    CHARACTER(len=*) :: cmd
    TYPE(c_ptr) :: str

    str = f2c_string(cmd)
    CALL lammps_command(self%handle, str)
    CALL lammps_free(str)
  END SUBROUTINE lmp_command

  ! equivalent function to lammps_commands_list()
  SUBROUTINE lmp_commands_list(self, cmds)
    CLASS(lammps), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN), OPTIONAL :: cmds(:)
    TYPE(c_ptr), ALLOCATABLE     :: cmdv(:)
    INTEGER :: i, ncmd

    ! convert command list to c style
    ncmd = SIZE(cmds)
    ALLOCATE(cmdv(ncmd))
    DO i=1, ncmd
        cmdv(i) = f2c_string(cmds(i))
    END DO

    CALL lammps_commands_list(self%handle, ncmd, cmdv)

    ! Clean up allocated memory
    DO i=1, ncmd
        CALL lammps_free(cmdv(i))
    END DO
    DEALLOCATE(cmdv)
  END SUBROUTINE lmp_commands_list

  ! equivalent function to lammps_commands_string()
  SUBROUTINE lmp_commands_string(self, str)
    CLASS(lammps), INTENT(IN) :: self
    CHARACTER(len=*) :: str
    TYPE(c_ptr) :: tmp

    tmp = f2c_string(str)
    CALL lammps_commands_string(self%handle, tmp)
    CALL lammps_free(tmp)
  END SUBROUTINE lmp_commands_string

  ! equivalent function to lammps_get_natoms
  REAL(c_double) FUNCTION lmp_get_natoms(self)
    CLASS(lammps) :: self

    lmp_get_natoms = lammps_get_natoms(self%handle)
  END FUNCTION lmp_get_natoms

  ! equivalent function to lammps_get_thermo
  REAL(c_double) FUNCTION lmp_get_thermo(self,name)
    CLASS(lammps), INTENT(IN) :: self
    CHARACTER(LEN=*) :: name
    TYPE(c_ptr) :: Cname

    Cname = f2c_string(name)
    lmp_get_thermo = lammps_get_thermo(self%handle, Cname)
    CALL lammps_free(Cname)
  END FUNCTION lmp_get_thermo

  ! equivalent subroutine to lammps_extract_box
  SUBROUTINE lmp_extract_box(self, boxlo, boxhi, xy, yz, xz, pflags, boxflag)
    CLASS(lammps), INTENT(IN) :: self
    REAL(c_double), INTENT(OUT), TARGET, OPTIONAL :: boxlo(3), boxhi(3)
    REAL(c_double), INTENT(OUT), TARGET, OPTIONAL :: xy, yz, xz
    LOGICAL, INTENT(OUT), OPTIONAL :: pflags(3), boxflag
    INTEGER(c_int), TARGET :: c_pflags(3), c_boxflag
    TYPE(c_ptr) :: ptr(7)

    ptr = c_null_ptr
    IF (PRESENT(boxlo)) ptr(1) = C_LOC(boxlo(1))
    IF (PRESENT(boxhi)) ptr(2) = C_LOC(boxhi(1))
    IF (PRESENT(xy)) ptr(3) = C_LOC(xy)
    IF (PRESENT(yz)) ptr(4) = C_LOC(yz)
    IF (PRESENT(xz)) ptr(5) = C_LOC(xz)
    IF (PRESENT(pflags)) ptr(6) = C_LOC(c_pflags(1))
    IF (PRESENT(boxflag)) ptr(7) = C_LOC(c_boxflag)
    CALL lammps_extract_box(self%handle, ptr(1), ptr(2), ptr(3), ptr(4), &
      ptr(5), ptr(6), ptr(7))
    IF (PRESENT(pflags)) pflags = (c_pflags /= 0_c_int)
    IF (PRESENT(boxflag)) boxflag = (c_boxflag /= 0_c_int)
  END SUBROUTINE lmp_extract_box

  ! equivalent function to lammps_reset_box
  SUBROUTINE lmp_reset_box(self, boxlo, boxhi, xy, yz, xz)
    CLASS(lammps), INTENT(IN) :: self
    REAL(c_double), INTENT(IN) :: boxlo(3), boxhi(3), xy, yz, xz

    CALL lammps_reset_box(self%handle, boxlo, boxhi, xy, yz, xz)
  END SUBROUTINE lmp_reset_box

  ! equivalent function to lammps_memory_usage
  SUBROUTINE lmp_memory_usage(self,meminfo)
    CLASS(lammps), INTENT(IN) :: self
    INTEGER, PARAMETER :: MEMINFO_ELEM = 3
    REAL(c_double), DIMENSION(MEMINFO_ELEM), INTENT(OUT) :: meminfo

    CALL lammps_memory_usage(self%handle,meminfo)
  END SUBROUTINE lmp_memory_usage

  ! equivalent function to lammps_get_mpi_comm
  INTEGER FUNCTION lmp_get_mpi_comm(self)
    CLASS(lammps), INTENT(IN) :: self

    lmp_get_mpi_comm = lammps_get_mpi_comm(self%handle)
  END FUNCTION lmp_get_mpi_comm

  ! equivalent function to lammps_extract_setting
  INTEGER(c_int) FUNCTION lmp_extract_setting(self, keyword)
    CLASS(lammps), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: keyword
    TYPE(c_ptr) :: Ckeyword

    Ckeyword = f2c_string(keyword)
    lmp_extract_setting = lammps_extract_setting(self%handle, Ckeyword)
    CALL lammps_free(Ckeyword)
  END FUNCTION lmp_extract_setting

  ! equivalent function to lammps_extract_global
  ! the assignment is actually overloaded so as to bind the pointers to
  ! lammps data based on the information available from LAMMPS
  FUNCTION lmp_extract_global(self, name) RESULT(global_data)
    CLASS(lammps), INTENT(IN), TARGET :: self
    CHARACTER(LEN=*), INTENT(IN) :: name
    TYPE(lammps_data) :: global_data

    INTEGER(c_int) :: datatype
    TYPE(c_ptr) :: Cname, Cptr
    INTEGER(c_size_t) :: length, i
    CHARACTER(KIND=c_char, LEN=1), DIMENSION(:), POINTER :: Fptr

    ! Determine vector length
    ! FIXME Is there a way to get the length of the vector from C rather
    ! than defining it here AND in the Python API?
    SELECT CASE (name)
      CASE ('boxlo','boxhi','sublo','subhi','sublo_lambda','subhi_lambda', &
            'periodicity')
        length = 3
      CASE DEFAULT
        length = 1
      ! string cases are overridden later
    END SELECT

    Cname = f2c_string(name)
    datatype = lammps_extract_global_datatype(self%handle, Cname)
      ! above could be c_null_ptr in place of self%handle...doesn't matter
    Cptr = lammps_extract_global(self%handle, Cname)
    CALL lammps_free(Cname)

    global_data%lammps_instance => self
    SELECT CASE (datatype)
      CASE (LAMMPS_INT)
        IF (length == 1) THEN
          global_data%datatype = DATA_INT
          CALL C_F_POINTER(Cptr, global_data%i32)
        ELSE
          global_data%datatype = DATA_INT_1D
          CALL C_F_POINTER(Cptr, global_data%i32_vec, [length])
        END IF
      CASE (LAMMPS_INT64)
        IF (length == 1) THEN
          global_data%datatype = DATA_INT64
          CALL C_F_POINTER(Cptr, global_data%i64)
        ELSE
          global_data%datatype = DATA_INT64_1D
          CALL C_F_POINTER(Cptr, global_data%i64_vec, [length])
        END IF
      CASE (LAMMPS_DOUBLE)
        IF (length == 1) THEN
          global_data%datatype = DATA_DOUBLE
          CALL C_F_POINTER(Cptr, global_data%r64)
        ELSE
          global_data%datatype = DATA_DOUBLE_1D
          CALL C_F_POINTER(Cptr, global_data%r64_vec, [length])
        END IF
      CASE (LAMMPS_STRING)
        global_data%datatype = DATA_STRING
        length = c_strlen(Cptr)
        CALL C_F_POINTER(Cptr, Fptr, [length])
        ALLOCATE(CHARACTER(LEN=length) :: global_data%str)
        DO i = 1, length
          global_data%str(i:i) = Fptr(i)
        END DO
      CASE DEFAULT
        CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
          'Unknown pointer type in extract_global')
    END SELECT
  END FUNCTION

  ! equivalent function to lammps_extract_atom
  ! the assignment is actually overloaded so as to bind the pointers to
  ! lammps data based on the information available from LAMMPS
  FUNCTION lmp_extract_atom(self, name) RESULT(peratom_data)
    CLASS(lammps), INTENT(IN), TARGET :: self
    CHARACTER(LEN=*), INTENT(IN) :: name
    TYPE(lammps_data) :: peratom_data

    INTEGER(c_int) :: datatype
    TYPE(c_ptr) :: Cname, Cptr
    INTEGER(c_int) :: ntypes, nmax
    INTEGER :: nrows, ncols
    REAL(c_double), DIMENSION(:), POINTER :: dummy
    TYPE(c_ptr), DIMENSION(:), POINTER :: Catomptr
    CHARACTER(LEN=:), ALLOCATABLE :: error_msg

    nmax = lmp_extract_setting(self, 'nmax')
    ntypes = lmp_extract_setting(self, 'ntypes')
    Cname = f2c_string(name)
    datatype = lammps_extract_atom_datatype(self%handle, Cname)
    Cptr = lammps_extract_atom(self%handle, Cname)
    CALL lammps_free(Cname)

    SELECT CASE (name)
      CASE ('mass')
        ncols = ntypes + 1
        nrows = 1
      CASE ('x','v','f','mu','omega','torque','angmom')
        ncols = nmax
        nrows = 3
      CASE DEFAULT
        ncols = nmax
        nrows = 1
    END SELECT

    peratom_data%lammps_instance => self
    SELECT CASE (datatype)
      CASE (LAMMPS_INT)
        peratom_data%datatype = DATA_INT_1D
        CALL C_F_POINTER(Cptr, peratom_data%i32_vec, [ncols])
      CASE (LAMMPS_INT64)
        peratom_data%datatype = DATA_INT64_1D
        CALL C_F_POINTER(Cptr, peratom_data%i64_vec, [ncols])
      CASE (LAMMPS_DOUBLE)
        peratom_data%datatype = DATA_DOUBLE_1D
        IF (name == 'mass') THEN
          CALL C_F_POINTER(Cptr, dummy, [ncols])
          peratom_data%r64_vec(0:) => dummy
        ELSE
          CALL C_F_POINTER(Cptr, peratom_data%r64_vec, [ncols])
        END IF
      CASE (LAMMPS_DOUBLE_2D)
        peratom_data%datatype = DATA_DOUBLE_2D
        ! First, we dereference the void** pointer to point to the void*
        CALL C_F_POINTER(Cptr, Catomptr, [ncols])
        ! Catomptr(1) now points to the first element of the array
        CALL C_F_POINTER(Catomptr(1), peratom_data%r64_mat, [nrows,ncols])
      CASE (-1)
        CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
          'per-atom property ' // name // 'not found in extract_setting')
      CASE DEFAULT
        WRITE(error_msg,'(A,I0,A)') 'return value ', datatype, &
          ' from lammps_extract_atom_datatype not known [Fortran/extract_atom]'
        CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, error_msg)
    END SELECT
  END FUNCTION lmp_extract_atom

  ! equivalent function to lammps_extract_compute
  ! the assignment operator is overloaded so as to bind the pointers to
  ! lammps data based on the information available from LAMMPS
  FUNCTION lmp_extract_compute(self, id, style, type) RESULT(compute_data)
    CLASS(lammps), INTENT(IN), TARGET :: self
    CHARACTER(LEN=*), INTENT(IN) :: id
    INTEGER(c_int), INTENT(IN) :: style, type
    TYPE(lammps_data) :: compute_data

    TYPE(c_ptr) :: Cid, Cptr, Ctemp
    INTEGER :: nrows, ncols, length
    INTEGER(c_int), POINTER :: temp
    TYPE(c_ptr), DIMENSION(:), POINTER :: Ccomputeptr

    Cid = f2c_string(id)
    Cptr = lammps_extract_compute(self%handle, Cid, style, type)

    IF (.NOT. C_ASSOCIATED(Cptr)) THEN
      CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
        'Pointer from LAMMPS is NULL [Fortran/extract_compute]')
    END IF

    ! Remember that rows and columns in C are transposed in Fortran!
    compute_data%lammps_instance => self
    SELECT CASE (type)
      CASE (LMP_TYPE_SCALAR)
        compute_data%datatype = DATA_DOUBLE
        length = 1
        nrows = 1
        ncols = 1
        CALL C_F_POINTER(Cptr, compute_data%r64)
      CASE (LMP_TYPE_VECTOR)
        compute_data%datatype = DATA_DOUBLE_1D
        IF (style == LMP_STYLE_ATOM) THEN
          length = self%extract_setting('nmax')
        ELSE
          Ctemp = lammps_extract_compute(self%handle,Cid,style,LMP_SIZE_VECTOR)
          CALL C_F_POINTER(Ctemp, temp)
          length = temp
        END IF
        CALL C_F_POINTER(Cptr, compute_data%r64_vec, [length])
      CASE (LMP_TYPE_ARRAY)
        compute_data%datatype = DATA_DOUBLE_2D
        IF (style == LMP_STYLE_ATOM) THEN
          ncols = self%extract_setting('nmax')
          Ctemp = lammps_extract_compute(self%handle,Cid,style,LMP_SIZE_COLS)
          CALL C_F_POINTER(Ctemp, temp)
          nrows = temp
        ELSE
          Ctemp = lammps_extract_compute(self%handle,Cid,style,LMP_SIZE_ROWS)
          CALL C_F_POINTER(Ctemp, temp)
          ncols = temp
          Ctemp = lammps_extract_compute(self%handle,Cid,style,LMP_SIZE_COLS)
          CALL C_F_POINTER(Ctemp, temp)
          nrows = temp
        END IF
        ! First, we dereference the void** pointer to point to a void* pointer
        CALL C_F_POINTER(Cptr, Ccomputeptr, [ncols])
        ! Ccomputeptr(1) now points to the first element of the array
        CALL C_F_POINTER(Ccomputeptr(1), compute_data%r64_mat, [nrows, ncols])
      CASE DEFAULT
        CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
          'unknown type value passed to extract_compute [Fortran API]')
    END SELECT
    CALL lammps_free(Cid)
  END FUNCTION lmp_extract_compute

  FUNCTION lmp_extract_fix(self, id, style, type, nrow, ncol) RESULT(fix_data)
    CLASS(lammps), INTENT(IN), TARGET :: self
    CHARACTER(LEN=*), INTENT(IN) :: id
    INTEGER(c_int), INTENT(IN) :: style, type
    INTEGER(c_int), INTENT(IN), OPTIONAL :: nrow, ncol
    TYPE(lammps_fix_data) :: fix_data

    TYPE(c_ptr) :: Cid, Cptr, Ctemp
    TYPE(c_ptr), DIMENSION(:), POINTER :: Cfixptr
    INTEGER(c_int) :: Cnrow, Cncol
    REAL(c_double), POINTER :: Fptr
    INTEGER :: nrows, ncols
    INTEGER(c_int), POINTER :: temp

    ! We transpose ncol and nrow so the array appears to be transposed for
    ! global data, as it would be if we could access the C++ array directly
    Cnrow = -1
    Cncol = -1
    IF (PRESENT(nrow)) THEN
      IF (.NOT. PRESENT(ncol)) THEN
        ! Presumably the argument that's there is the vector length
        Cnrow = nrow - 1_c_int
        Cncol = -1_c_int
      ELSE
        ! Otherwise, the array is transposed, so...reverse the indices
        Cncol = nrow - 1_c_int
      END IF
    END IF

    IF (PRESENT(ncol)) Cnrow = ncol - 1_c_int

    Cid = f2c_string(id)
    Cptr = lammps_extract_fix(self%handle, Cid, style, type, Cnrow, Cncol)
    IF (.NOT. C_ASSOCIATED(Cptr)) THEN
      CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
        'Pointer from LAMMPS is NULL for fix id "' // id &
        // '" [Fortran/extract_fix]')
    END IF

    fix_data%lammps_instance => self
    SELECT CASE (style)
      CASE (LMP_STYLE_GLOBAL)
        fix_data%datatype = DATA_DOUBLE
        CALL C_F_POINTER(Cptr, Fptr)
        fix_data%r64 = Fptr
        CALL lammps_free(Cptr)
      CASE (LMP_STYLE_ATOM, LMP_STYLE_LOCAL)
        SELECT CASE (type)
          CASE (LMP_TYPE_SCALAR)
            CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
              'There is no such thing as a per-atom or local scalar&
              & [Fortran/extract_fix]')
          CASE (LMP_TYPE_VECTOR)
            fix_data%datatype = DATA_DOUBLE_1D
            IF (STYLE == LMP_STYLE_ATOM) THEN
              nrows = self%extract_setting('nmax')
            ELSE
              Ctemp = lammps_extract_fix(self%handle, Cid, style, &
                  LMP_SIZE_VECTOR, 0_c_int,0_c_int)
              CALL C_F_POINTER(Ctemp, temp)
              nrows = temp
            END IF
            CALL C_F_POINTER(Cptr, fix_data%r64_vec, [nrows])
          CASE (LMP_TYPE_ARRAY)
            fix_data%datatype = DATA_DOUBLE_2D
            IF (STYLE == LMP_STYLE_ATOM) THEN
              ! Fortran array is transposed relative to C
              ncols = self%extract_setting('nmax')
              Ctemp = lammps_extract_fix(self%handle, Cid, style, &
                  LMP_SIZE_COLS, 0_c_int,0_c_int)
              CALL C_F_POINTER(Ctemp, temp)
              nrows = temp
            ELSE
              ! Fortran array is transposed relative to C
              Ctemp = lammps_extract_fix(self%handle, Cid, style, &
                  LMP_SIZE_COLS, 0_c_int,0_c_int)
              CALL C_F_POINTER(Ctemp, temp)
              nrows = temp
              Ctemp = lammps_extract_fix(self%handle, Cid, style, &
                  LMP_SIZE_ROWS, 0_c_int,0_c_int)
              CALL C_F_POINTER(Ctemp, temp)
              ncols = temp
            END IF
            ! First, we dereference the void** to point to a void* pointer
            CALL C_F_POINTER(Cptr, Cfixptr, [ncols])
            ! Cfixptr(1) now points to the first element of the array
            CALL C_F_POINTER(Cfixptr(1), fix_data%r64_mat, [nrows, ncols])
          CASE DEFAULT
            CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
              'unknown type value passed to extract_fix [Fortran API]')
        END SELECT
      CASE DEFAULT
        CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
          'unknown style value passed to extract_fix [Fortran API]')
    END SELECT
    CALL lammps_free(Cid)
  END FUNCTION lmp_extract_fix

  ! equivalent function to lammps_extract_variable
  FUNCTION lmp_extract_variable(self, name, group) RESULT(variable_data)
    CLASS(lammps), INTENT(IN), TARGET :: self
    CHARACTER(LEN=*), INTENT(IN) :: name
    CHARACTER(LEN=*), INTENT(IN), OPTIONAL :: group
    TYPE(lammps_variable_data) :: variable_data

    TYPE(c_ptr) :: Cptr, Cname, Cgroup, Cveclength
    INTEGER(c_size_t) :: length, i
    CHARACTER(KIND=c_char, LEN=1), DIMENSION(:), POINTER :: Cstring
    INTEGER(c_int) :: datatype
    REAL(c_double), POINTER :: double => NULL()
    REAL(c_double), DIMENSION(:), POINTER :: double_vec => NULL()
    INTEGER(c_int), POINTER :: Clength => NULL()

    Cname = f2c_string(name)
    IF (PRESENT(group)) THEN
      Cgroup = f2c_string(group)
    ELSE
      Cgroup = c_null_ptr
    END IF
    datatype = lammps_extract_variable_datatype(self%handle, Cname)
    Cptr = lammps_extract_variable(self%handle, Cname, Cgroup)
    CALL lammps_free(Cname)
    CALL lammps_free(Cgroup)

    variable_data%lammps_instance => self
    SELECT CASE (datatype)
      CASE (LMP_VAR_EQUAL)
        variable_data%datatype = DATA_DOUBLE
        CALL C_F_POINTER(Cptr, double)
        variable_data%r64 = double
        CALL lammps_free(Cptr)
      CASE (LMP_VAR_ATOM)
        variable_data%datatype = DATA_DOUBLE_1D
        length = lmp_extract_setting(self, 'nlocal')
        CALL C_F_POINTER(Cptr, double_vec, [length])
        IF (ALLOCATED(variable_data%r64_vec)) DEALLOCATE(variable_data%r64_vec)
        ALLOCATE(variable_data%r64_vec(length))
        variable_data%r64_vec = double_vec
        CALL lammps_free(Cptr)
      CASE (LMP_VAR_VECTOR)
        variable_data%datatype = DATA_DOUBLE_1D
        Cgroup = f2c_string('LMP_SIZE_VECTOR') ! must match library.cpp
        Cname = f2c_string(name)
        Cveclength = lammps_extract_variable(self%handle, Cname, Cgroup)
        CALL C_F_POINTER(Cveclength, Clength)
        length = Clength
        CALL lammps_free(Cgroup)
        CALL lammps_free(Cname)
        CALL lammps_free(Cveclength)
        CALL C_F_POINTER(Cptr, double_vec, [length])
        IF (ALLOCATED(variable_data%r64_vec)) &
          DEALLOCATE(variable_data%r64_vec)
        ALLOCATE(variable_data%r64_vec(length))
        variable_data%r64_vec = double_vec
        ! DO NOT deallocate the C pointer
      CASE (LMP_VAR_STRING)
        variable_data%datatype = DATA_STRING
        length = c_strlen(Cptr)
        CALL C_F_POINTER(Cptr, Cstring, [length])
        ALLOCATE(CHARACTER(LEN=length) :: variable_data%str)
        DO i = 1, length
          variable_data%str(i:i) = Cstring(i)
        END DO
        ! DO NOT deallocate the C pointer
      CASE (-1)
        CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
          'Variable "' // TRIM(name) // &
          '" not found [Fortran/extract_variable]')
      CASE DEFAULT
        CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
          'Unknown variable type returned from &
          &lammps_extract_variable_datatype [Fortran/extract_variable]')
    END SELECT
  END FUNCTION lmp_extract_variable

  ! equivalent function to lammps_set_variable
  SUBROUTINE lmp_set_variable(self, name, str)
    CLASS(lammps), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: name, str
    INTEGER :: err
    TYPE(c_ptr) :: Cstr, Cname

    Cstr = f2c_string(str)
    Cname = f2c_string(name)
    err = lammps_set_variable(self%handle, Cname, Cstr)
    CALL lammps_free(Cname)
    CALL lammps_free(Cstr)
    IF (err /= 0) THEN
      CALL lmp_error(self, LMP_ERROR_WARNING + LMP_ERROR_WORLD, &
        'WARNING: unable to set string variable "' // name &
        // '" [Fortran/set_variable]')
    END IF
  END SUBROUTINE lmp_set_variable

  ! equivalent function to lammps_gather_atoms (for integers)
  SUBROUTINE lmp_gather_atoms_int(self, name, count, data)
    CLASS(lammps), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: name
    INTEGER(c_int), INTENT(IN) :: count
    INTEGER(c_int), DIMENSION(:), ALLOCATABLE, TARGET, INTENT(OUT) :: data
    TYPE(c_ptr) :: Cdata, Cname
    INTEGER(c_int) :: natoms
    INTEGER(c_int), PARAMETER :: Ctype = 0_c_int
    REAL(c_double) :: dnatoms
    CHARACTER(LEN=100) :: error_msg

    IF (count /= 1 .AND. count /= 3) THEN
      CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, 'gather_atoms&
        & requires "count" to be 1 or 3 [Fortran/gather_atoms]')
    END IF

    dnatoms = lmp_get_natoms(self)
    IF (dnatoms > HUGE(1_c_int)) THEN
      WRITE(error_msg,'(A,1X,I0,1X,A)') &
        'Cannot use library function gather_atoms with more than', &
        HUGE(0_c_int), 'atoms [Fortran/gather_atoms]'
      CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, error_msg)
    END IF
    natoms = NINT(dnatoms, c_int)

    Cname = f2c_string(name)
    IF (ALLOCATED(data)) DEALLOCATE(data)
    ALLOCATE(data(natoms*count))
    Cdata = C_LOC(data(1))
    CALL lammps_gather_atoms(self%handle, Cname, Ctype, count, Cdata)
    CALL lammps_free(Cname)
  END SUBROUTINE lmp_gather_atoms_int

  ! equivalent function to lammps_gather_atoms (for doubles)
  SUBROUTINE lmp_gather_atoms_double(self, name, count, data)
    CLASS(lammps), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: name
    INTEGER(c_int), INTENT(IN) :: count
    REAL(c_double), DIMENSION(:), ALLOCATABLE, TARGET, INTENT(OUT) :: data
    TYPE(c_ptr) :: Cdata, Cname
    INTEGER(c_int) :: natoms
    INTEGER(c_int), PARAMETER :: Ctype = 1_c_int
    REAL(c_double) :: dnatoms
    CHARACTER(LEN=100) :: error_msg

    IF (count /= 1 .AND. count /= 3) THEN
      CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, 'gather_atoms&
        & requires "count" to be 1 or 3 [Fortran/gather_atoms]')
    END IF

    dnatoms = lmp_get_natoms(self)
    IF (dnatoms > HUGE(1_c_int)) THEN
      WRITE(error_msg,'(A,1X,I0,1X,A)') &
        'Cannot use library function gather_atoms with more than', &
        HUGE(0_c_int), 'atoms [Fortran/gather_atoms]'
      CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, error_msg)
    END IF
    natoms = NINT(dnatoms, c_int)

    Cname = f2c_string(name)
    IF (ALLOCATED(data)) DEALLOCATE(data)
    ALLOCATE(data(natoms*count))
    Cdata = C_LOC(data(1))
    CALL lammps_gather_atoms(self%handle, Cname, Ctype, count, Cdata)
    CALL lammps_free(Cname)
  END SUBROUTINE lmp_gather_atoms_double

  ! equivalent function to lammps_gather_atoms_concat (for integers)
  SUBROUTINE lmp_gather_atoms_concat_int(self, name, count, data)
    CLASS(lammps), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: name
    INTEGER(c_int), INTENT(IN) :: count
    INTEGER(c_int), DIMENSION(:), ALLOCATABLE, TARGET, INTENT(OUT) :: data
    TYPE(c_ptr) :: Cdata, Cname
    INTEGER(c_int) :: natoms
    INTEGER(c_int), PARAMETER :: Ctype = 0_c_int
    REAL(c_double) :: dnatoms
    CHARACTER(LEN=100) :: error_msg

    IF (count /= 1 .AND. count /= 3) THEN
      CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
        'gather_atoms_concat requires "count" to be 1 or 3 &
        &[Fortran/gather_atoms_concat]')
    END IF

    dnatoms = lmp_get_natoms(self)
    IF (dnatoms > HUGE(1_c_int)) THEN
      WRITE(error_msg,'(A,1X,I0,1X,A)') &
        'Cannot use library function gather_atoms_concat with more than', &
        HUGE(0_c_int), 'atoms [Fortran/gather_atoms_concat]'
      CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, error_msg)
    END IF
    natoms = NINT(dnatoms, c_int)

    Cname = f2c_string(name)
    IF (ALLOCATED(data)) DEALLOCATE(data)
    ALLOCATE(data(natoms*count))
    Cdata = C_LOC(data(1))
    CALL lammps_gather_atoms_concat(self%handle, Cname, Ctype, count, Cdata)
    CALL lammps_free(Cname)
  END SUBROUTINE lmp_gather_atoms_concat_int

  ! equivalent function to lammps_gather_atoms_concat (for doubles)
  SUBROUTINE lmp_gather_atoms_concat_double(self, name, count, data)
    CLASS(lammps), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: name
    INTEGER(c_int), INTENT(IN) :: count
    REAL(c_double), DIMENSION(:), ALLOCATABLE, TARGET, INTENT(OUT) :: data
    TYPE(c_ptr) :: Cdata, Cname
    INTEGER(c_int) :: natoms
    INTEGER(c_int), PARAMETER :: Ctype = 1_c_int
    REAL(c_double) :: dnatoms
    CHARACTER(LEN=100) :: error_msg

    IF (count /= 1 .AND. count /= 3) THEN
      CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
        'gather_atoms_concat requires "count" to be 1 or 3 &
        &[Fortran/gather_atoms_concat]')
    END IF

    dnatoms = lmp_get_natoms(self)
    IF (dnatoms > HUGE(1_c_int)) THEN
      WRITE(error_msg,'(A,1X,I0,1X,A)') &
        'Cannot use library function gather_atoms_concat with more than', &
        HUGE(0_c_int), 'atoms [Fortran/gather_atoms_concat]'
      CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, error_msg)
    END IF
    natoms = NINT(dnatoms, c_int)

    Cname = f2c_string(name)
    IF (ALLOCATED(data)) DEALLOCATE(data)
    ALLOCATE(data(natoms*count))
    Cdata = C_LOC(data(1))
    CALL lammps_gather_atoms_concat(self%handle, Cname, Ctype, count, Cdata)
    CALL lammps_free(Cname)
  END SUBROUTINE lmp_gather_atoms_concat_double

  ! equivalent function to lammps_gather_atoms_subset (for integers)
  SUBROUTINE lmp_gather_atoms_subset_int(self, name, count, ids, data)
    CLASS(lammps), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: name
    INTEGER(c_int), INTENT(IN) :: count
    INTEGER(c_int), DIMENSION(:), TARGET, INTENT(IN) :: ids
    INTEGER(c_int), DIMENSION(:), ALLOCATABLE, TARGET, INTENT(OUT) :: data
    INTEGER(c_int) :: ndata
    TYPE(c_ptr) :: Cdata, Cname, Cids
    INTEGER(c_int), PARAMETER :: Ctype = 0_c_int

    IF (count /= 1 .AND. count /= 3) THEN
      CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
        'gather_atoms_subset requires "count" to be 1 or 3 &
        &[Fortran/gather_atoms]')
    END IF

    ndata = SIZE(ids, KIND=c_int)

    Cname = f2c_string(name)
    IF (ALLOCATED(data)) DEALLOCATE(data)
    ALLOCATE(data(ndata*count))
    data = -1_c_int
    Cdata = C_LOC(data(1))
    Cids = C_LOC(ids(1))
    CALL lammps_gather_atoms_subset(self%handle, Cname, Ctype, count, &
        ndata, Cids, Cdata)
    CALL lammps_free(Cname)
  END SUBROUTINE lmp_gather_atoms_subset_int

  ! equivalent function to lammps_gather_atoms_subset (for doubles)
  SUBROUTINE lmp_gather_atoms_subset_double(self, name, count, ids, data)
    CLASS(lammps), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: name
    INTEGER(c_int), INTENT(IN) :: count
    INTEGER(c_int), DIMENSION(:), TARGET, INTENT(IN) :: ids
    REAL(c_double), DIMENSION(:), ALLOCATABLE, TARGET, INTENT(OUT) :: data
    INTEGER(c_int) :: ndata
    TYPE(c_ptr) :: Cdata, Cname, Cids
    INTEGER(c_int), PARAMETER :: Ctype = 1_c_int

    IF (count /= 1 .AND. count /= 3) THEN
      CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
        'gather_atoms_subset requires "count" to be 1 or 3 &
        &[Fortran/gather_atoms]')
    END IF

    ndata = SIZE(ids, KIND=c_int)

    Cname = f2c_string(name)
    IF (ALLOCATED(data)) DEALLOCATE(data)
    ALLOCATE(data(ndata*count))
    Cdata = C_LOC(data(1))
    Cids = C_LOC(ids(1))
    CALL lammps_gather_atoms_subset(self%handle, Cname, Ctype, count, &
        ndata, Cids, Cdata)
    CALL lammps_free(Cname)
  END SUBROUTINE lmp_gather_atoms_subset_double

  ! equivalent function to lammps_scatter_atoms (for integers)
  SUBROUTINE lmp_scatter_atoms_int(self, name, data)
    CLASS(lammps), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: name
    INTEGER(c_int), DIMENSION(:), TARGET :: data
    INTEGER(c_int) :: natoms, Ccount
    INTEGER(c_int), PARAMETER :: Ctype = 0_c_int
    TYPE(c_ptr) :: Cname, Cdata
    REAL(c_double) :: dnatoms
    CHARACTER(LEN=100) :: error_msg

    dnatoms = lmp_get_natoms(self)
    IF (dnatoms > HUGE(1_c_int)) THEN
      WRITE(error_msg,'(A,1X,I0,1X,A)') &
        'Cannot use library function scatter_atoms with more than', &
        HUGE(0_c_int), 'atoms [Fortran/scatter_atoms]'
      CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, error_msg)
    END IF
    natoms = NINT(dnatoms, c_int)

    Cname = f2c_string(name)
    Cdata = C_LOC(data(1))
    Ccount = SIZE(data) / natoms

    IF (Ccount /= 1 .AND. Ccount /= 3) THEN
      CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
        'lammps_scatter_atoms requires either 1 or 3 data per atom')
    END IF
    CALL lammps_scatter_atoms(self%handle, Cname, Ctype, Ccount, Cdata)
    CALL lammps_free(Cname)
  END SUBROUTINE lmp_scatter_atoms_int

  ! equivalent function to lammps_scatter_atoms (for doubles)
  SUBROUTINE lmp_scatter_atoms_double(self, name, data)
    CLASS(lammps), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: name
    REAL(c_double), DIMENSION(:), TARGET :: data
    INTEGER(c_int) :: natoms, Ccount
    INTEGER(c_int), PARAMETER :: Ctype = 1_c_int
    TYPE(c_ptr) :: Cname, Cdata
    REAL(c_double) :: dnatoms
    CHARACTER(LEN=100) :: error_msg

    dnatoms = lmp_get_natoms(self)
    IF (dnatoms > HUGE(1_c_int)) THEN
      WRITE(error_msg,'(A,1X,I0,1X,A)') &
        'Cannot use library function scatter_atoms with more than', &
        HUGE(0_c_int), 'atoms [Fortran/scatter_atoms]'
      CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, error_msg)
    END IF
    natoms = NINT(dnatoms, c_int)

    Cname = f2c_string(name)
    Cdata = C_LOC(data(1))
    Ccount = SIZE(data) / natoms

    IF (Ccount /= 1 .AND. Ccount /= 3) THEN
      CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
        'scatter_atoms requires either 1 or 3 data per atom &
        &[Fortran/scatter_atoms]')
    END IF
    CALL lammps_scatter_atoms(self%handle, Cname, Ctype, Ccount, Cdata)
    CALL lammps_free(Cname)
  END SUBROUTINE lmp_scatter_atoms_double

  SUBROUTINE lmp_scatter_atoms_subset_int(self, name, ids, data)
    CLASS(lammps), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: name
    INTEGER(c_int), DIMENSION(:), TARGET :: ids
    INTEGER(c_int), DIMENSION(:), TARGET :: data
    INTEGER(c_int), PARAMETER :: Ctype = 0_c_int
    INTEGER(c_int) :: Cndata, Ccount
    TYPE(c_ptr) :: Cdata, Cname, Cids

    Cndata = SIZE(ids, KIND=c_int)
    Ccount = SIZE(data, KIND=c_int) / Cndata
    IF (Ccount /= 1 .AND. Ccount /= 3) THEN
      CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
        'scatter_atoms_subset requires either 1 or 3 data per atom')
    END IF

    Cname = f2c_string(name)
    Cdata = C_LOC(data(1))
    Cids = C_LOC(ids(1))
    CALL lammps_scatter_atoms_subset(self%handle, Cname, Ctype, Ccount, &
      Cndata, Cids, Cdata)
    CALL lammps_free(Cname)
  END SUBROUTINE lmp_scatter_atoms_subset_int

  SUBROUTINE lmp_scatter_atoms_subset_double(self, name, ids, data)
    CLASS(lammps), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: name
    INTEGER(c_int), DIMENSION(:), TARGET :: ids
    REAL(c_double), DIMENSION(:), TARGET :: data
    INTEGER(c_int), PARAMETER :: Ctype = 1_c_int
    INTEGER(c_int) :: Cndata, Ccount
    TYPE(c_ptr) :: Cdata, Cname, Cids

    Cndata = SIZE(ids, KIND=c_int)
    Ccount = SIZE(data, KIND=c_int) / Cndata
    IF (Ccount /= 1 .AND. Ccount /= 3) THEN
      CALL lmp_error(self, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
        'scatter_atoms_subset requires either 1 or 3 data per atom')
    END IF

    Cname = f2c_string(name)
    Cdata = C_LOC(data(1))
    Cids = C_LOC(ids(1))
    CALL lammps_scatter_atoms_subset(self%handle, Cname, Ctype, Ccount, &
      Cndata, Cids, Cdata)
    CALL lammps_free(Cname)
  END SUBROUTINE lmp_scatter_atoms_subset_double

  ! equivalent function to lammps_version
  INTEGER FUNCTION lmp_version(self)
    CLASS(lammps), INTENT(IN) :: self

    lmp_version = lammps_version(self%handle)
  END FUNCTION lmp_version

  ! equivalent function to lammps_get_os_info
  SUBROUTINE lmp_get_os_info(buffer)
    CHARACTER(LEN=*) :: buffer
    INTEGER(c_int) :: buf_size
    CHARACTER(LEN=1,KIND=c_char), DIMENSION(LEN(buffer)), TARGET :: Cbuffer
    TYPE(c_ptr) :: ptr
    INTEGER :: i

    buffer = ' '
    ptr = C_LOC(Cbuffer(1))
    buf_size = LEN(buffer)
    CALL lammps_get_os_info(ptr, buf_size)
    DO i=1,buf_size
      IF (Cbuffer(i) == c_null_char) EXIT
      buffer(i:i) = Cbuffer(i)
    END DO
  END SUBROUTINE lmp_get_os_info

  ! equivalent function to lammps_config_has_mpi_support
  LOGICAL FUNCTION lmp_config_has_mpi_support()
    INTEGER(c_int) :: has_mpi_support

    has_mpi_support = lammps_config_has_mpi_support()
    lmp_config_has_mpi_support = (has_mpi_support /= 0_c_int)
  END FUNCTION lmp_config_has_mpi_support

  ! equivalent function to lammps_config_has_gzip_support
  LOGICAL FUNCTION lmp_config_has_gzip_support()
    INTEGER(c_int) :: has_gzip_support

    has_gzip_support = lammps_config_has_gzip_support()
    lmp_config_has_gzip_support = (has_gzip_support /= 0_c_int)
  END FUNCTION lmp_config_has_gzip_support

  ! equivalent function to lammps_config_has_png_support
  LOGICAL FUNCTION lmp_config_has_png_support()
    INTEGER(c_int) :: has_png_support

    has_png_support = lammps_config_has_png_support()
    lmp_config_has_png_support = (has_png_support /= 0_c_int)
  END FUNCTION lmp_config_has_png_support

  ! equivalent function to lammps_config_has_jpeg_support
  LOGICAL FUNCTION lmp_config_has_jpeg_support()
    INTEGER(c_int) :: has_jpeg_support

    has_jpeg_support = lammps_config_has_jpeg_support()
    lmp_config_has_jpeg_support = (has_jpeg_support /= 0_c_int)
  END FUNCTION lmp_config_has_jpeg_support

  ! equivalent function to lammps_config_has_ffmpeg_support
  LOGICAL FUNCTION lmp_config_has_ffmpeg_support()
    INTEGER(c_int) :: has_ffmpeg_support

    has_ffmpeg_support = lammps_config_has_ffmpeg_support()
    lmp_config_has_ffmpeg_support = (has_ffmpeg_support /= 0_c_int)
  END FUNCTION lmp_config_has_ffmpeg_support

  ! equivalent function to lammps_config_has_exceptions
  LOGICAL FUNCTION lmp_config_has_exceptions()
    INTEGER(c_int) :: has_exceptions

    has_exceptions = lammps_config_has_exceptions()
    lmp_config_has_exceptions = (has_exceptions /= 0_c_int)
  END FUNCTION lmp_config_has_exceptions

  ! equivalent function to lammps_config_has_package
  LOGICAL FUNCTION lmp_config_has_package(name)
    CHARACTER(LEN=*), INTENT(IN) :: name
    INTEGER(c_int) :: has_package
    TYPE(c_ptr) :: Cname

    Cname = f2c_string(name)
    has_package = lammps_config_has_package(Cname)
    lmp_config_has_package = (has_package /= 0_c_int)
    CALL lammps_free(Cname)
  END FUNCTION lmp_config_has_package

  ! equivalent subroutine to lammps_config_package_name
  SUBROUTINE lmp_config_package_name(idx, buffer)
    INTEGER, INTENT(IN) :: idx
    CHARACTER(LEN=*), INTENT(OUT) :: buffer
    INTEGER(c_int) :: Cidx, Csuccess
    TYPE(c_ptr) :: Cptr
    CHARACTER(LEN=1,KIND=c_char), TARGET :: Cbuffer(LEN(buffer)+1)
    INTEGER(c_size_t) :: i, strlen

    Cidx = idx - 1
    Cptr = C_LOC(Cbuffer(1))
    Csuccess = lammps_config_package_name(Cidx, Cptr, LEN(buffer)+1)
    buffer = ' '
    IF (Csuccess /= 0_c_int) THEN
      strlen = c_strlen(Cptr)
      DO i = 1, strlen
        buffer(i:i) = Cbuffer(i)
      END DO
    END IF
  END SUBROUTINE lmp_config_package_name

  ! equivalent function to Python routine .installed_packages()
  SUBROUTINE lmp_installed_packages(package, length)
    CHARACTER(LEN=:), DIMENSION(:), ALLOCATABLE, INTENT(OUT) :: package
    INTEGER, INTENT(IN), OPTIONAL :: length
    INTEGER, PARAMETER :: MAX_BUFFER_LENGTH = 31
    INTEGER :: i, npackage, buf_length

    IF (PRESENT(length)) THEN
      buf_length = length
    ELSE
      buf_length = MAX_BUFFER_LENGTH
    END IF

    IF (ALLOCATED(package)) DEALLOCATE(package)
    npackage = lammps_config_package_count()
    ALLOCATE(CHARACTER(LEN=MAX_BUFFER_LENGTH) :: package(npackage))
    DO i=1, npackage
      CALL lmp_config_package_name(i, package(i))
    END DO
  END SUBROUTINE lmp_installed_packages

  ! equivalent function to lammps_flush_buffers
  SUBROUTINE lmp_flush_buffers(self)
    CLASS(lammps), INTENT(IN) :: self

    CALL lammps_flush_buffers(self%handle)
  END SUBROUTINE lmp_flush_buffers

  ! equivalent function to lammps_is_running
  LOGICAL FUNCTION lmp_is_running(self)
    CLASS(lammps), INTENT(IN) :: self

    lmp_is_running = (lammps_is_running(self%handle) /= 0_c_int)
  END FUNCTION lmp_is_running

  ! equivalent function to lammps_force_timeout
  SUBROUTINE lmp_force_timeout(self)
    CLASS(lammps), INTENT(IN) :: self

    CALL lammps_force_timeout(self%handle)
  END SUBROUTINE

  ! equivalent function to lammps_has_error
  LOGICAL FUNCTION lmp_has_error(self)
    CLASS(lammps), INTENT(IN) :: self
    INTEGER(c_int) :: has_error

    has_error = lammps_has_error(self%handle)
    lmp_has_error = (has_error /= 0_c_int)
  END FUNCTION lmp_has_error

  ! equivalent function to lammps_get_last_error_message
  SUBROUTINE lmp_get_last_error_message(self, buffer, status)
    CLASS(lammps), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(OUT) :: buffer
    INTEGER, INTENT(OUT), OPTIONAL :: status
    INTEGER(c_int) :: buflen, Cstatus
    INTEGER(c_size_t) :: i, length
    TYPE(c_ptr) :: Cptr
    CHARACTER(LEN=1, KIND=c_char), POINTER :: c_string(:)

    buffer = ' '
    IF (lmp_has_error(self)) THEN
      buflen = LEN(buffer)
      length = buflen
      Cptr = lammps_malloc(length)
      Cstatus = lammps_get_last_error_message(self%handle, Cptr, buflen)
      CALL C_F_POINTER(Cptr, c_string, [1])
      DO i=1, length
        buffer(i:i) = c_string(i)
        IF (c_string(i) == c_null_char) EXIT
      END DO
      IF (PRESENT(status)) THEN
        status = Cstatus
      END IF
      CALL lammps_free(Cptr)
    ELSE
      buffer = ' '
      IF (PRESENT(status)) THEN
        status = 0
      END IF
    END IF
  END SUBROUTINE lmp_get_last_error_message

  ! ----------------------------------------------------------------------
  ! functions to assign user-space pointers to LAMMPS data
  ! ----------------------------------------------------------------------
  SUBROUTINE assign_int_to_lammps_data(lhs, rhs)
    INTEGER(c_int), INTENT(OUT), POINTER :: lhs
    CLASS(lammps_data), INTENT(IN) :: rhs

    IF (rhs%datatype == DATA_INT) THEN
      lhs => rhs%i32
    ELSE
      CALL assignment_error(rhs, 'scalar int')
    END IF
  END SUBROUTINE assign_int_to_lammps_data

  SUBROUTINE assign_int64_to_lammps_data(lhs, rhs)
    INTEGER(c_int64_t), INTENT(OUT), POINTER :: lhs
    CLASS(lammps_data), INTENT(IN) :: rhs

    IF (rhs%datatype == DATA_INT64) THEN
      lhs => rhs%i64
    ELSE
      CALL assignment_error(rhs, 'scalar long int')
    END IF
  END SUBROUTINE assign_int64_to_lammps_data

  SUBROUTINE assign_intvec_to_lammps_data(lhs, rhs)
    INTEGER(c_int), DIMENSION(:), INTENT(OUT), POINTER :: lhs
    CLASS(lammps_data), INTENT(IN) :: rhs

    IF (rhs%datatype == DATA_INT_1D) THEN
      lhs => rhs%i32_vec
    ELSE
      CALL assignment_error(rhs, 'vector of ints')
    END IF
  END SUBROUTINE assign_intvec_to_lammps_data

  SUBROUTINE assign_int64vec_to_lammps_data(lhs, rhs)
    INTEGER(c_int64_t), DIMENSION(:), INTENT(OUT), POINTER :: lhs
    CLASS(lammps_data), INTENT(IN) :: rhs

    IF (rhs%datatype == DATA_INT64_1D) THEN
      lhs => rhs%i64_vec
    ELSE
      CALL assignment_error(rhs, 'vector of long ints')
    END IF
  END SUBROUTINE assign_int64vec_to_lammps_data

  SUBROUTINE assign_double_to_lammps_data(lhs, rhs)
    REAL(c_double), INTENT(OUT), POINTER :: lhs
    CLASS(lammps_data), INTENT(IN) :: rhs

    IF (rhs%datatype == DATA_DOUBLE) THEN
      lhs => rhs%r64
    ELSE
      CALL assignment_error(rhs, 'scalar double')
    END IF
  END SUBROUTINE assign_double_to_lammps_data

  SUBROUTINE assign_doublevec_to_lammps_data(lhs, rhs)
    REAL(c_double), DIMENSION(:), INTENT(OUT), POINTER :: lhs
    CLASS(lammps_data), INTENT(IN) :: rhs

    IF (rhs%datatype == DATA_DOUBLE_1D) THEN
      lhs => rhs%r64_vec
    ELSE
      CALL assignment_error(rhs, 'vector of doubles')
    END IF
  END SUBROUTINE assign_doublevec_to_lammps_data

  SUBROUTINE assign_doublemat_to_lammps_data(lhs, rhs)
    REAL(c_double), DIMENSION(:,:), INTENT(OUT), POINTER :: lhs
    CLASS(lammps_data), INTENT(IN) :: rhs

    IF (rhs%datatype == DATA_DOUBLE_2D) THEN
      lhs => rhs%r64_mat
    ELSE
      CALL assignment_error(rhs, 'matrix of doubles')
    END IF
  END SUBROUTINE assign_doublemat_to_lammps_data

  SUBROUTINE assign_string_to_lammps_data(lhs, rhs)
    CHARACTER(LEN=*), INTENT(OUT) :: lhs
    CLASS(lammps_data), INTENT(IN) :: rhs

    IF (rhs%datatype == DATA_STRING) THEN
      lhs = rhs%str
      IF (LEN_TRIM(rhs%str) > LEN(lhs)) THEN
        CALL lmp_error(rhs%lammps_instance, LMP_ERROR_WARNING, &
          'String provided by user required truncation [Fortran API]')
      END IF
    ELSE
      CALL assignment_error(rhs, 'string')
    END IF
  END SUBROUTINE assign_string_to_lammps_data

  ! ----------------------------------------------------------------------
  ! functions to assign user-space pointers to LAMMPS *fix* data
  ! ----------------------------------------------------------------------
  SUBROUTINE assign_double_to_lammps_fix_data(lhs, rhs)
    REAL(c_double), INTENT(OUT) :: lhs
    CLASS(lammps_fix_data), INTENT(IN) :: rhs

    IF (rhs%datatype == DATA_DOUBLE) THEN
      lhs = rhs%r64
    ELSE
      CALL assignment_error(rhs, 'scalar double')
    END IF
  END SUBROUTINE assign_double_to_lammps_fix_data

  SUBROUTINE assign_doublevec_to_lammps_fix_data(lhs, rhs)
    REAL(c_double), DIMENSION(:), INTENT(OUT), POINTER :: lhs
    CLASS(lammps_fix_data), INTENT(IN) :: rhs

    IF (rhs%datatype == DATA_DOUBLE_1D) THEN
      lhs => rhs%r64_vec
    ELSE
      CALL assignment_error(rhs, 'vector of doubles')
    END IF
  END SUBROUTINE assign_doublevec_to_lammps_fix_data

  SUBROUTINE assign_doublemat_to_lammps_fix_data(lhs, rhs)
    REAL(c_double), DIMENSION(:,:), INTENT(OUT), POINTER :: lhs
    CLASS(lammps_fix_data), INTENT(IN) :: rhs

    IF (rhs%datatype == DATA_DOUBLE_2D) THEN
      lhs => rhs%r64_mat
    ELSE
      CALL assignment_error(rhs, 'matrix of doubles')
    END IF
  END SUBROUTINE assign_doublemat_to_lammps_fix_data

  ! ----------------------------------------------------------------------
  ! functions to assign user-space pointers to LAMMPS *variable* data
  ! ----------------------------------------------------------------------
  SUBROUTINE assign_double_to_lammps_variable_data(lhs, rhs)
    REAL(c_double), INTENT(OUT) :: lhs
    CLASS(lammps_variable_data), INTENT(IN) :: rhs

    IF (rhs%datatype == DATA_DOUBLE) THEN
      lhs = rhs%r64
    ELSE
      CALL assignment_error(rhs, 'scalar double')
    END IF
  END SUBROUTINE assign_double_to_lammps_variable_data

  SUBROUTINE assign_doublevec_to_lammps_variable_data(lhs, rhs)
    REAL(c_double), DIMENSION(:), ALLOCATABLE, INTENT(OUT) :: lhs
    CLASS(lammps_variable_data), INTENT(IN) :: rhs

    IF (rhs%datatype == DATA_DOUBLE_1D) THEN
      IF (ALLOCATED(lhs)) DEALLOCATE(lhs)
      ALLOCATE(lhs(SIZE(rhs%r64_vec)))
      lhs = rhs%r64_vec
    ELSE
      CALL assignment_error(rhs, 'vector of doubles')
    END IF
  END SUBROUTINE assign_doublevec_to_lammps_variable_data

  SUBROUTINE assign_string_to_lammps_variable_data(lhs, rhs)
    CHARACTER(LEN=*), INTENT(OUT) :: lhs
    CLASS(lammps_variable_data), INTENT(IN) :: rhs

    IF (rhs%datatype == DATA_STRING) THEN
      lhs = rhs%str
      IF (LEN_TRIM(rhs%str) > LEN(lhs)) THEN
        CALL lmp_error(rhs%lammps_instance, LMP_ERROR_WARNING, &
          'String provided by user required truncation [Fortran API]')
      END IF
    ELSE
      CALL assignment_error(rhs, 'string')
    END IF
  END SUBROUTINE assign_string_to_lammps_variable_data

  ! ----------------------------------------------------------------------
  ! Generic function to catch all errors in assignments of LAMMPS data to
  ! user-space variables/pointers
  ! ----------------------------------------------------------------------
  SUBROUTINE assignment_error(type1, str2)
    CLASS(lammps_data_baseclass), INTENT(IN) :: type1
    CHARACTER(LEN=*), INTENT(IN) :: str2
    CHARACTER(LEN=:), ALLOCATABLE :: str1

    SELECT CASE(type1%datatype)
      CASE(DATA_INT)
        str1 = 'scalar int'
      CASE(DATA_INT_1D)
        str1 = 'vector of ints'
      CASE(DATA_INT_2D)
        str1 = 'matrix of ints'
      CASE(DATA_INT64)
        str1 = 'scalar long int'
      CASE(DATA_INT64_1D)
        str1 = 'vector of long ints'
      CASE(DATA_INT64_2D)
        str1 = 'matrix of long ints'
      CASE(DATA_DOUBLE)
        str1 = 'scalar double'
      CASE(DATA_DOUBLE_1D)
        str1 = 'vector of doubles'
      CASE(DATA_DOUBLE_2D)
        str1 = 'matrix of doubles'
      CASE(DATA_STRING)
        str1 = 'string'
      CASE DEFAULT
        str1 = 'that type'
    END SELECT
    CALL lmp_error(type1%lammps_instance, LMP_ERROR_ALL + LMP_ERROR_WORLD, &
      'cannot associate ' // str1 // ' with ' // str2 // ' [Fortran API]')
  END SUBROUTINE assignment_error

  ! ----------------------------------------------------------------------
  ! local helper functions
  ! copy fortran string to zero terminated c string
  ! ----------------------------------------------------------------------
  FUNCTION f2c_string(f_string) RESULT(ptr)
    CHARACTER(LEN=*), INTENT(IN)           :: f_string
    CHARACTER(LEN=1, KIND=c_char), POINTER :: c_string(:)
    TYPE(c_ptr) :: ptr
    INTEGER(c_size_t) :: i, n

    n = LEN_TRIM(f_string)
    ptr = lammps_malloc(n+1)
    CALL C_F_POINTER(ptr, c_string, [1])
    DO i=1, n
        c_string(i) = f_string(i:i)
    END DO
    c_string(n+1) = c_null_char
  END FUNCTION f2c_string
END MODULE LIBLAMMPS

! vim: ts=2 sts=2 sw=2 et
