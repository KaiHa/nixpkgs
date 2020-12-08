{ pkgs, stdenv, fetchurl, bash, dpkg, gtk2-x11, jre, xorg }:

let
  pname = "jigasi";
  version = "1.1-126-g6df3db2";
  src = fetchurl {
    url = "https://download.jitsi.org/stable/${pname}_${version}-1_amd64.deb";
    sha256 = "1zwj5yj239g2k75pmzdbikvrfjpwy766nlx1jakkzv689qnl4pr7";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  dontBuild = true;

  unpackCmd = "${dpkg}/bin/dpkg-deb -x $src debcontents";

  installPhase = ''
    substituteInPlace usr/share/jigasi/jigasi.sh \
      --replace "exec java" "exec ${jre}/bin/java" \
      --replace 'libs="$SCRIPT_DIR/lib"' "libs=\"$out/share/jigasi/lib:${gtk2-x11}/lib:${xorg.libXScrnSaver}/lib"\"
    substituteInPlace lib/systemd/system/jigasi.service \
      --replace "/bin/bash" "${bash}/bin/bash" \
      --replace "/usr/share/jigasi/jigasi.sh" "$out/share/jigasi/jigasi.sh"


    mkdir -p $out/{share,bin}
    mv usr/share/* $out/share/
    mv lib $out/
    ln -s $out/share/jigasi/jigasi.sh $out/bin/jigasi
  '';

  meta = with stdenv.lib; {
    description = "A server side SIP gateway used in Jitsi Meet";
    longDescription = ''
      JItsi GAteway to SIp is a server side gateway to SIP used in Jitsi Meet.
    '';
    homepage = "https://github.com/jitsi/jigasi";
    license = licenses.asl20;
    maintainers = teams.jitsi.members;
    platforms = platforms.linux;
  };
}
