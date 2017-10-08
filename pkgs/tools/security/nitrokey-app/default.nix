{ stdenv, cmake, fetchgit, hidapi, libusb1, pkgconfig, qt5 }:

stdenv.mkDerivation rec {
  name = "nitrokey-app";
  version = "1.2-beta.2";

  # We use fetchgit instead of fetchFromGitHub because of necessary git submodules
  src = fetchgit {
    url = "https://github.com/KaiHa/nitrokey-app.git";
    rev = "refs/heads/fix-misleading-indentation";
    sha256 = "0hhcy9gs4hsigqghnyzrpsxivzn5y8wdn85ac3qqm6h4z38899pr";
  };

  buildInputs = [
    hidapi
    libusb1
    qt5.qtbase
    qt5.qttranslations
  ];
  nativeBuildInputs = [
    cmake
    pkgconfig
  ];
  cmakeFlags = "-DHAVE_LIBAPPINDICATOR=NO";

  meta = with stdenv.lib; {
    description      = "Provides extra functionality for the Nitrokey Pro and Storage";
    longDescription  = ''
       The nitrokey-app provides a QT system tray widget with wich you can
       access the extra functionality of a Nitrokey Storage or Nitrokey Pro.
       See https://www.nitrokey.com/ for more information.
    '';
    homepage         = https://github.com/Nitrokey/nitrokey-app;
    repositories.git = https://github.com/Nitrokey/nitrokey-app.git;
    license          = licenses.gpl3;
    maintainers      = with maintainers; [ kaiha fpletz ];
  };
}
