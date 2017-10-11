{ fetchgit, writeScript, openssh, stdenv, socat }: args: derivation ((fetchgit args).drvAttrs // rec {
  passAsFile = [ "known_hosts" ];
  known_hosts = if (builtins.tryEval <ssh-known-hosts>).success
    then builtins.readFile <ssh-known-hosts>
    else builtins.readFile ~/.ssh/known_hosts;
  SSH_AUTH_SOCK = if (builtins.tryEval <ssh-auth-sock>).success
    then builtins.toString <ssh-auth-sock>
    else builtins.getEnv "SSH_AUTH_SOCK";
  GIT_SSH = writeScript "fetchgit-ssh" ''
    #! ${stdenv.shell}
    conf=$(mktemp)
    echo "UserKnownHostsFile = $known_hostsPath" > $conf
    exec -a ssh ${openssh}/bin/ssh -F $conf "$@"
  '';
})
