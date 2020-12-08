{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.jigasi;
in
{
  options.services.jigasi = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable the Jitsi SIP gateway (jigasi).
      '';
    };

    sipUser = mkOption {
      type = types.str;
      example = "00491231234567";
      description = ''
        The user id of the SIP user.
      '';
    };

    sipPassword = mkOption {
      type = types.str;
      example = "c2VjcmV0";
      description = ''
        The password of the SIP user (base64 encoded).
      '';
    };

    sipServer = mkOption {
      type = types.str;
      example = "sip.example.com";
      description = ''
        The SIP server.
      '';
    };

    defaultRoom = mkOption {
      type = types.str;
      default = "siptest";
      example = "myroom";
      description = ''
        The default room that will be joined if no special header is included
        in SIP invite.
      '';
    };

    componentSecret = mkOption {
      type = types.str;
      example = "secret";
      description = ''
        The component secret.
      '';
    };

    prosodyUser = mkOption {
      type = types.str;
      example = "hans";
      default = "jigasi";
      description = ''
        The username for the Prosody authentication.
      '';
    };

    prosodyPassword = mkOption {
      type = types.str;
      example = "secret";
      description = ''
        The password for the Prosody authentication.
      '';
    };

  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.jigasi ];
    networking.firewall.allowedTCPPorts = [ 5060 ];
    networking.firewall.allowedUDPPortRanges = [ {from = 10000; to = 20000;} ];
    networking.firewall.allowedUDPPorts = [ 5060 ];

    systemd.services.jigasi = {
      description = "Jitsi SIP Gateway";
      after = [ "network.target" "jicofo.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.jigasi}/bin/jigasi --domain=${config.services.jitsi-meet.hostName} --subdomain=callcontrol --secret=\"${cfg.componentSecret}\" --configdir=/etc/jitsi --configdirname=jigasi --min-port=10000 --max-port=20000";
        Restart = "on-failure";
        TasksMax = 65000;
        LimitNPROC = 65000;
        LimitNOFILE = 65000;
      };
    };

    services.jitsi-meet.config.hosts.call_control = "callcontrol.${config.services.jitsi-meet.hostName}";
    services.prosody.extraConfig = ''
      Component "callcontrol.${config.services.jitsi-meet.hostName}"
          component_secret = "${cfg.componentSecret}"
    '';

    environment.etc."jitsi/jigasi/sip-communicator.properties".text = ''
      # Name of default JVB room that will be joined if no special header is included
      # in SIP invite
      org.jitsi.jigasi.DEFAULT_JVB_ROOM_NAME=${cfg.defaultRoom}@conference.${config.services.jitsi-meet.hostName}

      net.java.sip.communicator.impl.protocol.SingleCallInProgressPolicy.enabled=false

      # Needed with some SIP providers (e.g. easybell)
      org.jitsi.impl.neomedia.transform.csrc.CsrcTransformEngine.DISCARD_CONTRIBUTING_SOURCES=true

      # Should be enabled when using translator mode
      #net.java.sip.communicator.impl.neomedia.audioSystem.audiosilence.captureDevice_list=["AudioSilenceCaptureDevice:noTransferData"]

      # Adjust opus encoder complexity
      net.java.sip.communicator.impl.neomedia.codec.audio.opus.encoder.COMPLEXITY=10

      # Disables packet logging
      net.java.sip.communicator.packetlogging.PACKET_LOGGING_ENABLED=true

      net.java.sip.communicator.impl.protocol.sip.acc1403273890647=acc1403273890647
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.ACCOUNT_UID=SIP\:${cfg.sipUser}
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.PASSWORD=${cfg.sipPassword}
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.PROTOCOL_NAME=SIP
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.SERVER_ADDRESS=${cfg.sipServer}
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.USER_ID=${cfg.sipUser}
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.KEEP_ALIVE_INTERVAL=25
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.KEEP_ALIVE_METHOD=OPTIONS
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.VOICEMAIL_ENABLED=false
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.AMR-WB/16000=750
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.G722/8000=700
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.GSM/8000=0
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.H263-1998/90000=0
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.H264/90000=0
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.PCMA/8000=600
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.PCMU/8000=650
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.SILK/12000=0
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.SILK/16000=0
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.SILK/24000=0
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.SILK/8000=0
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.VP8/90000=0
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.iLBC/8000=10
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.opus/48000=1000
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.red/90000=0
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.speex/16000=0
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.speex/32000=0
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.speex/8000=0
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.telephone-event/8000=1
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.Encodings.ulpfec/90000=0
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.OVERRIDE_ENCODINGS=true
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.DEFAULT_ENCRYPTION=false

      # If an authenticated (hidden) domain is used to connect to a conference,
      # PREVENT_AUTH_LOGIN will prevent the SIP participant from being seen as a
      # hidden participant in the conference
      #net.java.sip.communicator.impl.protocol.sip.acc1403273890647.PREVENT_AUTH_LOGIN=FALSE

      # Used when incoming calls are used in multidomain environment, used to detect subdomains
      # used for constructing callResource and eventually contacting jicofo
      net.java.sip.communicator.impl.protocol.sip.acc1403273890647.DOMAIN_BASE=${config.services.jitsi-meet.hostName}

      # the pattern to be used as bosh url when using bosh in multidomain environment
      #net.java.sip.communicator.impl.protocol.sip.acc1403273890647.BOSH_URL_PATTERN=https://{host}{subdomain}/http-bind?room={roomName}

      # can be enabled to disable audio mixing and use translator, jigasi will act as jvb, just forward every ssrc stream it receives.
      #net.java.sip.communicator.impl.protocol.sip.acc1403273890647.USE_TRANSLATOR_IN_CONFERENCE=true

      # We can use the prefix org.jitsi.jigasi.xmpp.acc to override any of the
      # properties that will be used for creating xmpp account for communication.

      # The following two props assume we are using jigasi on the same machine as
      # the xmpp server.
      org.jitsi.jigasi.xmpp.acc.IS_SERVER_OVERRIDDEN=true
      org.jitsi.jigasi.xmpp.acc.SERVER_ADDRESS=127.0.0.1
      org.jitsi.jigasi.xmpp.acc.VIDEO_CALLING_DISABLED=true
      org.jitsi.jigasi.xmpp.acc.JINGLE_NODES_ENABLED=false
      org.jitsi.jigasi.xmpp.acc.AUTO_DISCOVER_STUN=false
      org.jitsi.jigasi.xmpp.acc.IM_DISABLED=true
      org.jitsi.jigasi.xmpp.acc.SERVER_STORED_INFO_DISABLED=true
      org.jitsi.jigasi.xmpp.acc.IS_FILE_TRANSFER_DISABLED=true
      # Or you can use bosh for the connection establishment by specifing the URL to use.
      # org.jitsi.jigasi.xmpp.acc.BOSH_URL_PATTERN=https://server.com/http-bind?room={roomName}

      #Used when outgoing calls are used in multidomain environment, used to detect subdomains
      #org.jitsi.jigasi.xmpp.acc.DOMAIN_BASE=${config.services.jitsi-meet.hostName}
      #org.jitsi.jigasi.xmpp.acc.BOSH_URL_PATTERN=https://{host}{subdomain}/http-bind?room={roomName}

      # can be enabled to disable audio mixing and use translator, jigasi will act as jvb, just forward every ssrc stream it receives.
      #org.jitsi.jigasi.xmpp.acc.USE_TRANSLATOR_IN_CONFERENCE=true

      # If you want jigasi to perform authenticated login instead of anonymous login
      # to the XMPP server, you can set the following properties.
      org.jitsi.jigasi.xmpp.acc.USER_ID=${cfg.prosodyUser}@${config.services.jitsi-meet.hostName}
      org.jitsi.jigasi.xmpp.acc.PASS=${cfg.prosodyPassword}
      org.jitsi.jigasi.xmpp.acc.ANONYMOUS_AUTH=false

      # If you want to use the SIP user part of the incoming/outgoing call SIP URI
      # you can set the following property to true.
      # org.jitsi.jigasi.USE_SIP_USER_AS_XMPP_RESOURCE=true

      # Activate this property if you are using self-signed certificates or other
      # type of non-trusted certicates. In this mode your service trust in the
      # remote certificates always.
      net.java.sip.communicator.service.gui.ALWAYS_TRUST_MODE_ENABLED=true

      # Enable this property to be able to shutdown gracefully jigasi using
      # a rest command
      # org.jitsi.jigasi.ENABLE_REST_SHUTDOWN=true

      # Options regarding Transcription. Read the README for a detailed description
      # about each property

      #org.jitsi.jigasi.ENABLE_TRANSCRIPTION=false
      #org.jitsi.jigasi.ENABLE_SIP=true

      # whether to use the more expensive, but better performing
      # "video" model when doing transcription
      # org.jitsi.jigasi.transcription.USE_VIDEO_MODEL = false

      # delivering final transcript
      # org.jitsi.jigasi.transcription.DIRECTORY=/var/lib/jigasi/transcripts
      # org.jitsi.jigasi.transcription.BASE_URL=http://localhost/
      # org.jitsi.jigasi.transcription.jetty.port=-1
      # org.jitsi.jigasi.transcription.ADVERTISE_URL=false

      # save formats
      # org.jitsi.jigasi.transcription.SAVE_JSON=false
      # org.jitsi.jigasi.transcription.SAVE_TXT=true

      # send formats
      # org.jitsi.jigasi.transcription.SEND_JSON=true
      # org.jitsi.jigasi.transcription.SEND_TXT=false

      # translation
      # org.jitsi.jigasi.transcription.ENABLE_TRANSLATION=false

      # record audio. Currently only wav format is supported
      # org.jitsi.jigasi.transcription.RECORD_AUDIO=false
      # org.jitsi.jigasi.transcription.RECORD_AUDIO_FORMAT=wav

      # execute one or more scripts when a transcript or recording is saved
      # org.jitsi.jigasi.transcription.EXECUTE_SCRIPTS=true
      # org.jitsi.jigasi.transcription.SCRIPTS_TO_EXECUTE_LIST_SEPARATOR=","
      # org.jitsi.jigasi.transcription.SCRIPTS_TO_EXECUTE_LIST=script/example_handle_transcript_directory.sh

      # filter out silent audio
      #org.jitsi.jigasi.transcription.FILTER_SILENCE = false

      # properties for optionally sending statistics to a DataDog server
      #org.jitsi.ddclient.prefix=jitsi.jigasi
      #org.jitsi.ddclient.host=localhost
      #org.jitsi.ddclient.port=8125

      # sip health checking
      # Enables sip health checking by specifying a number/uri to call
      # the target just needs to auto-connect the call play some audio,
      # the call must be established for less than 10 seconds
      # org.jitsi.jigasi.HEALTH_CHECK_SIP_URI=healthcheck
      #
      # The interval between healthcheck calls, by default is 5 minutes
      # org.jitsi.jigasi.HEALTH_CHECK_INTERVAL=300000
      #
      # The timeout of healthcheck, if there was no successful health check for
      # 10 minutes (default value) we consider jigasi unhealthy
      # org.jitsi.jigasi.HEALTH_CHECK_TIMEOUT=600000

      # Enabled or disable the notification when max occupants limit is reached
      # org.jitsi.jigasi.NOTIFY_MAX_OCCUPANTS=false
    '';

    environment.etc."jitsi/jigasi/logging.properties".text = ''
      handlers= java.util.logging.ConsoleHandler
      #handlers= java.util.logging.ConsoleHandler, com.agafua.syslog.SyslogHandler
      #handlers= java.util.logging.ConsoleHandler, io.sentry.jul.SentryHandler

      java.util.logging.ConsoleHandler.level = ALL
      java.util.logging.ConsoleHandler.formatter = net.java.sip.communicator.util.ScLogFormatter

      .level=INFO
      net.sf.level=SEVERE
      net.java.sip.communicator.plugin.reconnectplugin.level=FINE
      org.ice4j.level=SEVERE
      org.jitsi.impl.neomedia.level=SEVERE
      net.java.sip.communicator.impl.protocol.sip.level=SEVERE

      # Do not worry about missing strings
      net.java.sip.communicator.service.resources.AbstractResourcesService.level=SEVERE

      # Does not print roster warning on account removals
      org.jivesoftware.smack.roster.Roster.level=SEVERE

      #net.java.sip.communicator.service.protocol.level=ALL

      # Syslog (uncomment handler to use)
      com.agafua.syslog.SyslogHandler.transport = udp
      com.agafua.syslog.SyslogHandler.facility = local0
      com.agafua.syslog.SyslogHandler.port = 514
      com.agafua.syslog.SyslogHandler.hostname = localhost

      # Sentry (uncomment handler to use)
      io.sentry.jul.SentryHandler.level=WARNING
    '';
  };
}
