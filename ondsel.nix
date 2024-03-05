{ lib
, fmt
, stdenv
, fetchFromGitHub
, cmake
, doxygen
, ninja
, gitpython
, boost
, coin3d
, eigen
, gfortran
, gts
, hdf5
, libGLU
, libXmu
, libf2c
, libredwg
, libspnav
, matplotlib
, medfile
, mpi
, ode
, opencascade-occt
, pivy
, pkg-config
, ply
, pycollada
, pyside2
, pyside2-tools
, python
, pyyaml
, qtbase
, qttools
, qtwebengine
, qtx11extras
, qtxmlpatterns
, scipy
, shiboken2
, soqt
  # , spaceNavSupport ? stdenv.isLinux
, swig
, vtk
, wrapQtAppsHook
, wrapGAppsHook
, xercesc
, zlib
, yaml-cpp


}: stdenv.mkDerivation (finalAttrs: {
  pname = "ondsel";
  version = "2024.1.0";

  src = fetchFromGitHub {
    owner = "Ondsel-Development";
    repo = "FreeCAD";
    rev = finalAttrs.version;
    hash = "sha256-1Xyj2ta9ukBzP/Be0qivm0nv4/s4GGPwV+O3Ukd/5mE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    gfortran
    ninja
    pkg-config
    pyside2-tools
    wrapGAppsHook
    wrapQtAppsHook
    yaml-cpp
  ];

  buildInputs = [
    gitpython # for addon manager
    boost
    coin3d
    doxygen
    eigen
    fmt
    gts
    hdf5
    libGLU
    libXmu
    libf2c
    matplotlib
    medfile
    mpi
    ode
    opencascade-occt
    pivy
    ply # for openSCAD file support
    pycollada
    pyside2
    pyside2-tools
    python
    pyyaml # (at least for) PyrateWorkbench
    yaml-cpp
    qtbase
    qttools
    qtwebengine
    qtxmlpatterns
    scipy
    shiboken2
    soqt
    swig
    vtk
    xercesc
    zlib
    libspnav
    qtx11extras
  ];

  patches = [
    ./0001-NIXOS-don-t-ignore-PYTHONPATH.patch
  ];

  postPatch = ''
    substituteInPlace src/3rdParty/OndselSolver/OndselSolver.pc.in \
      --replace-fail "\''${exec_prefix}/@CMAKE_INSTALL_LIBDIR@" "@CMAKE_INSTALL_FULL_LIBDIR@" \
      --replace-fail "\''${prefix}/@CMAKE_INSTALL_INCLUDEDIR@" "@CMAKE_INSTALL_FULL_INCLUDEDIR@"
  '';

  cmakeFlags = [
    "-Wno-dev" # turns off warnings which otherwise makes it hard to see what is going on
    "-DINSTALL_TO_SITEPACKAGES=OFF" # https://github.com/FreeCAD/FreeCAD/pull/11885
    "-DBUILD_FLAT_MESH:BOOL=ON"
    "-DBUILD_QT5=ON"
    "-DSHIBOKEN_INCLUDE_DIR=${shiboken2}/include"
    "-DSHIBOKEN_LIBRARY=Shiboken2::libshiboken"
    ("-DPYSIDE_INCLUDE_DIR=${pyside2}/include"
      + ";${pyside2}/include/PySide2/QtCore"
      + ";${pyside2}/include/PySide2/QtWidgets"
      + ";${pyside2}/include/PySide2/QtGui"
    )
    "-DPYSIDE_LIBRARY=PySide2::pyside2"
  ];

  # This should work on both x86_64, and i686 linux
  preBuild = ''
    export NIX_LDFLAGS="-L${gfortran.cc}/lib64 -L${gfortran.cc}/lib $NIX_LDFLAGS";
  '';

  preConfigure = ''
    qtWrapperArgs+=(--prefix PYTHONPATH : "$PYTHONPATH")
  '';

  qtWrapperArgs = [
    "--set COIN_GL_NO_CURRENT_CONTEXT_CHECK 1"
    "--prefix PATH : ${libredwg}/bin"
    "--set QT_QPA_PLATFORM xcb"
  ];

  postFixup = ''
    mv $out/share/doc $out
    ln -s $out/bin/FreeCAD $out/bin/freecad
    ln -s $out/bin/FreeCADCmd $out/bin/freecadcmd
  '';

})
