require 'formula'

class Dealii < Formula

  homepage "http://www.dealii.org"
  url "https://github.com/dealii/dealii.git", :branch => "dealii-8.1"
  version "8.1"
  head do
    url "https://github.com/dealii/dealii.git", :branch => "master"
    version "8.2"
  end

  # modify devel to use
  # local repository
  # (must exist)
  devel do
    url "/Users/davydden/libs-sources/deal.ii/davydden", :using => :git
    version "8.2-devel"
  end
  # alternatively, install deal.II manually
  # to /usr/local/Cellar/dealii/devel
  # and run "brew link dealii"

  option "with-bundled-boost", "Use deal.II bundeled boost"

  depends_on "cmake"        => :build
  depends_on :mpi           => [:cc, :cxx, :f90, :recommended]
  depends_on "boost"        => :recommended
  if build.with? 'mpi'
    depends_on "hdf5"         => [:recommended, "enable-parallel"]
    depends_on "arpack"       => [:recommended, "with-mpi"]
  else
    depends_on "hdf5"         => :recommended
    depends_on "arpack"       => :recommended
  end
  depends_on "mumps"        => :recommended
  depends_on "metis"        => :recommended 
  depends_on "p4est"        => :recommended
  # Optional dependencies, enforce that they are built with `--with-XXX` options.
  depends_on "petsc"        => [:optional, "with-superlu_dist", "with-metis", "with-parmetis", "with-scalapack", "with-mumps"]
  depends_on "slepc"        => [:optional, "with-arpack"]
  depends_on "trilinos"     => [:optional, "with-boost" "with-netcdf" "without-tests" "remove-warnings" "with-release" "with-fortran"]

  def install
    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DDEAL_II_COMPONENT_COMPAT_FILES=OFF
    ]
    # constrain Cmake to look for libraries in homebrew's prefix
    args << "-DCMAKE_PREFIX_PATH=#{HOMEBREW_PREFIX}"

    if build.with? 'mpi'
      args << "-DCMAKE_C_COMPILER=#{HOMEBREW_PREFIX}/bin/mpicc"
      args << "-DCMAKE_CXX_COMPILER=#{HOMEBREW_PREFIX}/bin/mpicxx"
      args << "-DCMAKE_Fortran_COMPILER=#{HOMEBREW_PREFIX}/bin/mpif90"
    end

    if build.with? "bundled-boost"
      args << "-DDEAL_II_FORCE_BUNDLED_BOOST=ON" 
    else
      args << "-DDEAL_II_FORCE_BUNDLED_BOOST=OFF" 
    end

    args << "-DDEAL_II_WITH_HDF5=OFF"  if build.without? "hdf5"
    args << "-DDEAL_II_WITH_MUMPS=OFF" if build.without? "mumps"
    args << "-DDEAL_II_WITH_METIS=OFF" if build.without? "metis"
    args << "-DDEAL_II_WITH_ARPACK=OFF"if build.without? "arpack"
    args << "-DDEAL_II_WITH_P4EST=OFF" if build.without? "p4est"
    args << "-DDEAL_II_WITH_GSL=OFF"   if build.without? "gsl"

    if build.with? "petsc"
      args << "-DDEAL_II_WITH_PETSC=ON" 
    else
      args << "-DDEAL_II_WITH_PETSC=OFF" 
    end

    if build.with? "slepc"
      args << "-DDEAL_II_WITH_SLEPC=ON" 
    else
      args << "-DDEAL_II_WITH_SLEPC=OFF" 
    end

    if build.with? "trilinos"
      args << "-DDEAL_II_WITH_TRILINOS=ON" 
    else
      args << "-DDEAL_II_WITH_TRILINOS=OFF" 
    end

    mkdir 'build' do
      loc = "../"
      if build.stable? then
        loc = "../deal.II"
      end
      system "cmake", *args, loc
      system "make"
      system "make install"
    end

  end
end
