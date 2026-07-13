{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wthueb.services.mktxp;

  inherit (lib) types;

  # https://github.com/akpw/mktxp/blob/main/mktxp/cli/config/_mktxp.conf
  settingSpecs = {
    listen = {
      type = types.str;
      default = "0.0.0.0:49090";
      description = "Listen interface and port for the Prometheus metrics HTTP server.";
    };
    socket_timeout = {
      type = types.ints.unsigned;
      default = 5;
      description = "Socket connection timeout, in seconds, when talking to a router.";
    };

    initial_delay_on_failure = {
      type = types.ints.unsigned;
      default = 120;
      description = "Initial retry delay, in seconds, after a router fetch failure.";
    };
    max_delay_on_failure = {
      type = types.ints.unsigned;
      default = 900;
      description = "Maximum retry delay, in seconds, after repeated router fetch failures.";
    };
    delay_inc_div = {
      type = types.ints.unsigned;
      default = 5;
      description = "Divisor controlling how quickly the retry delay grows toward max_delay_on_failure.";
    };

    bandwidth = {
      type = types.bool;
      default = false;
      description = "Turn bandwidth (btest) metrics collection on / off.";
    };
    bandwidth_test_dns_server = {
      type = types.str;
      default = "8.8.8.8";
      description = "DNS server used for the bandwidth test connectivity check.";
    };
    bandwidth_test_interval = {
      type = types.ints.unsigned;
      default = 600;
      description = "Interval, in seconds, for collecting bandwidth metrics.";
    };
    minimal_collect_interval = {
      type = types.ints.unsigned;
      default = 5;
      description = "Minimal metric collection interval, in seconds.";
    };

    verbose_mode = {
      type = types.bool;
      default = false;
      description = "Enable verbose logging for troubleshooting.";
    };

    fetch_routers_in_parallel = {
      type = types.bool;
      default = false;
      description = "Fetch metrics from multiple routers in parallel instead of sequentially.";
    };
    max_worker_threads = {
      type = types.ints.unsigned;
      default = 5;
      description = "Maximum number of worker threads that can fetch routers (parallel fetch only).";
    };
    max_scrape_duration = {
      type = types.ints.unsigned;
      default = 30;
      description = "Maximum duration, in seconds, of an individual router's metrics collection (parallel fetch only).";
    };
    total_max_scrape_duration = {
      type = types.ints.unsigned;
      default = 90;
      description = "Maximum overall duration, in seconds, of all metrics collection (parallel fetch only).";
    };
    http_server_threads = {
      type = types.ints.unsigned;
      default = 16;
      description = "Number of worker threads for the metrics HTTP server.";
    };

    persistent_router_connection_pool = {
      type = types.bool;
      default = true;
      description = "Reuse a persistent router connection pool between scrapes.";
    };
    persistent_dhcp_cache = {
      type = types.bool;
      default = true;
      description = "Persist the DHCP cache between metric collections.";
    };
    compact_default_conf_values = {
      type = types.bool;
      default = false;
      description = "Compact mktxp.conf so only router-specific values are kept on the routers' level.";
    };
    prometheus_headers_deduplication = {
      type = types.bool;
      default = false;
      description = "Deduplicate Prometheus HELP / TYPE headers in the metrics output.";
    };

    probe_connection_pool = {
      type = types.bool;
      default = false;
      description = "Enable probe-only connection reuse keyed by module+target.";
    };
    probe_connection_pool_ttl = {
      type = types.ints.unsigned;
      default = 300;
      description = "Probe connection TTL in seconds.";
    };
    probe_connection_pool_max_size = {
      type = types.ints.unsigned;
      default = 128;
      description = "Maximum number of probe connections to keep.";
    };
  };

  # https://github.com/akpw/mktxp/blob/main/mktxp/cli/config/mktxp.conf
  routerSpecs = {
    enabled = {
      type = types.bool;
      default = true;
      description = "Turn metrics collection for this RouterOS device on / off.";
    };
    module_only = {
      type = types.bool;
      default = false;
      description = "Use this entry only as a probe module (skip /metrics collection).";
    };
    hostname = {
      type = types.str;
      default = "localhost";
      description = "RouterOS IP address or hostname.";
    };
    port = {
      type = types.port;
      default = 8728;
      description = "RouterOS API port.";
    };

    username = {
      type = types.nullOr types.str;
      default = null;
      description = ''
        RouterOS API username. Prefer {option}`credentials_file`, as values set
        here are written world-readable into the Nix store.
      '';
    };
    password = {
      type = types.nullOr types.str;
      default = null;
      description = ''
        RouterOS API password. Prefer {option}`credentials_file`, as values set
        here are written world-readable into the Nix store.
      '';
    };
    credentials_file = {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Path to a YAML file containing `username` and `password` keys.
        Takes precedence over {option}`username` /
        {option}`password` and keeps credentials out of the Nix store.
      '';
    };

    custom_labels = {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Custom labels injected into all device metrics, as comma-separated
        key:value (or key=value) pairs, e.g. `dc:london, rack=a1`.
      '';
    };

    use_ssl = {
      type = types.bool;
      default = false;
      description = "Connect via the API-SSL service.";
    };
    no_ssl_certificate = {
      type = types.bool;
      default = false;
      description = "Connect over API-SSL without requiring a router SSL certificate.";
    };
    ssl_certificate_verify = {
      type = types.bool;
      default = false;
      description = "Verify the router's SSL certificate.";
    };
    ssl_check_hostname = {
      type = types.bool;
      default = true;
      description = "Check that the hostname matches the peer certificate's hostname.";
    };
    ssl_ca_file = {
      type = types.str;
      default = "";
      description = "Path to a CA file to validate the router certificate against.";
    };
    plaintext_login = {
      type = types.bool;
      default = true;
      description = "Use plaintext login. Set to false for legacy RouterOS versions below 6.43.";
    };

    health = {
      type = types.bool;
      default = true;
      description = "System health metrics.";
    };
    installed_packages = {
      type = types.bool;
      default = true;
      description = "Installed packages metrics.";
    };
    dhcp = {
      type = types.bool;
      default = true;
      description = "DHCP general metrics.";
    };
    dhcp_lease = {
      type = types.bool;
      default = true;
      description = "DHCP lease metrics.";
    };

    connections = {
      type = types.bool;
      default = true;
      description = "IP connections metrics.";
    };
    connection_stats = {
      type = types.bool;
      default = false;
      description = "Open IP connections metrics.";
    };
    connection_stats_destinations = {
      type = types.bool;
      default = false;
      description = "Track individual destination IPs / ports (warning: high cardinality).";
    };

    interface = {
      type = types.bool;
      default = true;
      description = "Interface traffic metrics.";
    };
    routerboard = {
      type = types.bool;
      default = false;
      description = "RouterBOARD inventory / firmware metrics.";
    };
    wireguard_peers = {
      type = types.bool;
      default = false;
      description = "WireGuard peers metrics.";
    };
    bridge_vlan = {
      type = types.bool;
      default = false;
      description = "Bridge VLAN metrics.";
    };

    route = {
      type = types.bool;
      default = true;
      description = "IPv4 routes metrics.";
    };
    pool = {
      type = types.bool;
      default = true;
      description = "IPv4 pool metrics.";
    };
    firewall = {
      type = types.bool;
      default = true;
      description = "IPv4 firewall rules traffic metrics.";
    };
    neighbor = {
      type = types.bool;
      default = true;
      description = "IPv4 reachable neighbors metrics.";
    };
    address_list = {
      type = types.nullOr types.str;
      default = null;
      description = "Firewall address-list metrics: a comma-separated list of address-list names.";
    };
    dns = {
      type = types.bool;
      default = false;
      description = "DNS stats metrics.";
    };

    ipv6_route = {
      type = types.bool;
      default = false;
      description = "IPv6 routes metrics.";
    };
    ipv6_pool = {
      type = types.bool;
      default = false;
      description = "IPv6 pool metrics.";
    };
    ipv6_firewall = {
      type = types.bool;
      default = false;
      description = "IPv6 firewall rules traffic metrics.";
    };
    ipv6_neighbor = {
      type = types.bool;
      default = false;
      description = "IPv6 reachable neighbors metrics.";
    };
    ipv6_address_list = {
      type = types.nullOr types.str;
      default = null;
      description = "IPv6 firewall address-list metrics: a comma-separated list of names.";
    };

    poe = {
      type = types.bool;
      default = true;
      description = "PoE metrics.";
    };
    monitor = {
      type = types.bool;
      default = true;
      description = "Interface monitor metrics.";
    };
    netwatch = {
      type = types.bool;
      default = true;
      description = "Netwatch metrics.";
    };
    public_ip = {
      type = types.bool;
      default = true;
      description = "Public IP metrics.";
    };
    wireless = {
      type = types.bool;
      default = true;
      description = "WLAN general metrics.";
    };
    wireless_clients = {
      type = types.bool;
      default = true;
      description = "WLAN clients metrics.";
    };
    capsman = {
      type = types.bool;
      default = true;
      description = "CAPsMAN general metrics.";
    };
    capsman_clients = {
      type = types.bool;
      default = true;
      description = "CAPsMAN clients metrics.";
    };
    w60g = {
      type = types.bool;
      default = false;
      description = "W60G (60GHz) metrics.";
    };

    eoip = {
      type = types.bool;
      default = false;
      description = "EoIP status metrics.";
    };
    gre = {
      type = types.bool;
      default = false;
      description = "GRE status metrics.";
    };
    ipip = {
      type = types.bool;
      default = false;
      description = "IPIP status metrics.";
    };
    lte = {
      type = types.bool;
      default = false;
      description = "LTE signal and status metrics (requires the 'test' permission policy on RouterOS v6).";
    };
    ipsec = {
      type = types.bool;
      default = false;
      description = "IPSec active peer metrics.";
    };
    switch_port = {
      type = types.bool;
      default = false;
      description = "Switch port metrics.";
    };

    kid_control_assigned = {
      type = types.bool;
      default = false;
      description = "Kid Control metrics for connected devices with assigned users.";
    };
    kid_control_dynamic = {
      type = types.bool;
      default = false;
      description = "Kid Control metrics for all connected devices, including those without an assigned user.";
    };

    user = {
      type = types.bool;
      default = true;
      description = "Active users metrics.";
    };
    queue = {
      type = types.bool;
      default = true;
      description = "Queues metrics.";
    };

    bfd = {
      type = types.bool;
      default = false;
      description = "BFD sessions metrics.";
    };
    bgp = {
      type = types.bool;
      default = false;
      description = "BGP sessions metrics.";
    };
    routing_stats = {
      type = types.bool;
      default = false;
      description = "Routing process stats metrics.";
    };
    certificate = {
      type = types.bool;
      default = false;
      description = "Certificates metrics.";
    };

    container = {
      type = types.bool;
      default = false;
      description = "Containers metrics.";
    };

    remote_dhcp_entry = {
      type = types.nullOr types.str;
      default = null;
      description = "Name of an mktxp entry to use for remote DHCP info / resolution.";
    };
    remote_capsman_entry = {
      type = types.nullOr types.str;
      default = null;
      description = "Name of an mktxp entry to use for remote CAPsMAN info.";
    };

    interface_name_format = {
      type = types.enum [
        "name"
        "comment"
        "combined"
      ];
      default = "name";
      description = ''
        Format used for interface / resource names: `name` (e.g. `ether1`),
        `comment` (the comment if set, falling back to the name), or `combined`
        (e.g. `ether1 (Office Switch)`).
      '';
    };
    check_for_updates = {
      type = types.bool;
      default = false;
      description = "Check for available RouterOS updates.";
    };
  };

  # Build a documented option from a spec. `asDefault` keeps the spec's concrete
  # default (for the [default] section); otherwise the option becomes nullable
  # and defaults to null, meaning "inherit from [default]".
  mkSpecOption =
    asDefault: spec:
    lib.mkOption (
      {
        inherit (spec) description;
      }
      // (
        if asDefault then
          { inherit (spec) type default; }
        else
          {
            type = types.nullOr spec.type;
            default = null;
          }
      )
    );

  settingsSubmodule = types.submodule { options = lib.mapAttrs (_: mkSpecOption true) settingSpecs; };
  defaultsSubmodule = types.submodule { options = lib.mapAttrs (_: mkSpecOption true) routerSpecs; };
  routerSubmodule = types.submodule { options = lib.mapAttrs (_: mkSpecOption false) routerSpecs; };

  renderValue =
    v:
    if v == null then
      null
    else if lib.isBool v then
      (if v then "True" else "False")
    else
      toString v;

  # mktxp runs as a DynamicUser, which cannot own a sops secret ahead of time
  # (its UID is allocated at runtime). Every credentials_file is therefore handed
  # to the unit via systemd's LoadCredential: the service manager reads each file
  # as root and re-exposes it read-only under $CREDENTIALS_DIRECTORY. The rendered
  # config points at that location instead of the original (root-owned) path.
  credentialsDir = "/run/credentials/mktxp.service";
  credentialName = path: "creds-" + builtins.substring 0 12 (builtins.hashString "sha256" path);
  credentialRuntimePath = path: "${credentialsDir}/${credentialName path}";

  credentialPaths = lib.unique (
    lib.filter (p: p != null) (
      [ cfg.defaults.credentials_file ] ++ map (r: r.credentials_file) (lib.attrValues cfg.routers)
    )
  );
  loadCredentials = map (path: "${credentialName path}:${path}") credentialPaths;

  renderKeys =
    keys: vals:
    lib.concatMapStrings (
      k:
      let
        raw =
          if k == "credentials_file" && vals.${k} != null then credentialRuntimePath vals.${k} else vals.${k};
        r = renderValue raw;
      in
      lib.optionalString (r != null) "    ${k} = ${r}\n"
    ) keys;

  settingKeys = lib.attrNames settingSpecs;
  routerKeys = lib.attrNames routerSpecs;

  systemConfFile = pkgs.writeText "_mktxp.conf" ("[MKTXP]\n" + renderKeys settingKeys cfg.settings);

  routersConfFile = pkgs.writeText "mktxp.conf" (
    "[default]\n"
    + renderKeys routerKeys cfg.defaults
    + lib.concatStrings (
      lib.mapAttrsToList (name: r: "\n[${name}]\n" + renderKeys routerKeys r) cfg.routers
    )
  );

  hasCredentials =
    r:
    r.credentials_file != null
    || r.username != null
    || cfg.defaults.credentials_file != null
    || cfg.defaults.username != null;
in
{
  options.wthueb.services.mktxp = {
    enable = lib.mkEnableOption "mktxp, the Mikrotik RouterOS Prometheus exporter";

    package = lib.mkPackageOption pkgs "mktxp" { };

    settings = lib.mkOption {
      type = settingsSubmodule;
      default = { };
      description = "The [MKTXP] system-level configuration section (the exporter daemon itself).";
    };

    defaults = lib.mkOption {
      type = defaultsSubmodule;
      default = { };
      description = ''
        Settings shared by every router (the [default] section of mktxp.conf).
        Each per-router entry in {option}`wthueb.services.mktxp.routers` overrides these.
      '';
    };

    routers = lib.mkOption {
      type = types.attrsOf routerSubmodule;
      default = { };
      description = ''
        RouterOS devices to collect metrics from. The attribute name is the
        entry name. Any option left unset inherits its value from
        {option}`wthueb.services.mktxp.defaults`.
      '';
      example = lib.literalExpression ''
        {
          "Sample-Router".hostname = "192.168.88.1";
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.routers != { };
        message = "wthueb.services.mktxp.enable is set but no routers are defined in wthueb.services.mktxp.routers.";
      }
      {
        assertion = lib.all hasCredentials (lib.attrValues cfg.routers);
        message = ''
          Every wthueb.services.mktxp router needs credentials: set credentials_file (or
          username/password) either on the router or on wthueb.services.mktxp.defaults.
        '';
      }
    ];

    environment.systemPackages = [ cfg.package ];

    systemd.services.mktxp = {
      description = "mktxp - Mikrotik RouterOS Prometheus exporter";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      path = [ pkgs.coreutils ];
      preStart = ''
        install -m 0644 ${routersConfFile} /run/mktxp/mktxp.conf
        install -m 0644 ${systemConfFile}  /run/mktxp/_mktxp.conf
      '';

      serviceConfig = {
        DynamicUser = true;
        LoadCredential = loadCredentials;
        RuntimeDirectory = "mktxp";
        ExecStart = "${lib.getExe cfg.package} --cfg-dir /run/mktxp export";
        Restart = "on-failure";
        RestartSec = 10;

        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
      };
    };
  };
}
