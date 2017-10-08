{ stdenv, cmake, fetchgit, hidapi, libusb1, pkgconfig, qt5 }:

stdenv.mkDerivation rec {
  name = "nitrokey-app";
  version = "1.2-beta.2";

  # We use fetchgit instead of fetchFromGitHub because of necessary git submodules
  src = fetchgit {
    url = "https://github.com/Nitrokey/nitrokey-app.git";
    rev = "refs/tags/v${version}";
    sha256 = "0rana999qn7yicq7ims18qbklajg5f2s6k91xqhy7q6y0fn2rznh";
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
