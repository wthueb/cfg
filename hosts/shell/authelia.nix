{
  self,
  config,
  lib,
  ...
}:
let
  instance = config.services.authelia.instances.main;
  domain = "wi1.xyz";
  baseUrl = "https://${domain}";
  secretPath = name: config.sops.secrets."authelia/${name}".path;
  tailnet = "tiffany-vega.ts.net";
  clients = [
    {
      client_id = "synology-dsm";
      public = false;
      authorization_policy = "one_factor";
      redirect_uris = [ "https://jdr.${domain}" ];
      scopes = [
        "openid"
        "profile"
        "groups"
        "email"
      ];
      pre_configured_consent_duration = "1 month";
      response_types = [ "code" ];
      grant_types = [ "authorization_code" ];
      access_token_signed_response_alg = "none";
      userinfo_signed_response_alg = "none";
      token_endpoint_auth_method = "client_secret_post";
    }
    {
      client_id = "homarr";
      public = false;
      authorization_policy = "one_factor";
      redirect_uris = [ "${baseUrl}/api/auth/callback/oidc" ];
      scopes = [
        "openid"
        "email"
        "profile"
        "groups"
      ];
      pre_configured_consent_duration = "1 month";
      userinfo_signed_response_alg = "none";
      consent_mode = "implicit";
    }
    {
      client_id = "autobrr";
      public = false;
      authorization_policy = "one_factor";
      redirect_uris = [ "${baseUrl}/autobrr/api/auth/oidc/callback" ];
      scopes = [
        "openid"
        "email"
        "profile"
      ];
      pre_configured_consent_duration = "1 month";
    }
    {
      client_id = "qui";
      public = false;
      authorization_policy = "one_factor";
      redirect_uris = [ "${baseUrl}/qui/api/auth/oidc/callback" ];
      scopes = [
        "openid"
        "email"
        "profile"
      ];
      pre_configured_consent_duration = "1 month";
    }
    {
      client_id = "grafana";
      public = false;
      authorization_policy = "one_factor";
      redirect_uris = [
        "${self.nixosConfigurations.ida.config.services.grafana.settings.server.root_url}/login/generic_oauth"
      ];
      scopes = [
        "openid"
        "email"
        "profile"
        "groups"
      ];
      pre_configured_consent_duration = "1 month";
      response_types = [ "code" ];
      grant_types = [ "authorization_code" ];
      require_pkce = true;
      pkce_challenge_method = "S256";
      access_token_signed_response_alg = "RS256";
      userinfo_signed_response_alg = "none";
      token_endpoint_auth_method = "client_secret_basic";
      claims_policy = "grafana";
    }
    {
      client_id = "proxmox";
      public = false;
      authorization_policy = "one_factor";
      redirect_uris = [
        "https://ms01-a.${tailnet}:8006"
        "https://ms01-a:8006"
        "https://ms01-b.${tailnet}:8006"
        "https://ms01-b:8006"
      ];
      scopes = [
        "openid"
        "profile"
        "email"
        "groups"
      ];
      pre_configured_consent_duration = "1 month";
      response_types = [ "code" ];
      grant_types = [ "authorization_code" ];
      require_pkce = true;
      pkce_challenge_method = "S256";
      access_token_signed_response_alg = "none";
      userinfo_signed_response_alg = "none";
      token_endpoint_auth_method = "client_secret_basic";
    }
    {
      client_id = "pbs";
      public = false;
      authorization_policy = "one_factor";
      redirect_uris = [
        "https://pbs.${tailnet}:8007"
        "https://pbs:8007"
      ];
      scopes = [
        "openid"
        "profile"
        "email"
        "groups"
      ];
      pre_configured_consent_duration = "1 month";
      response_types = [ "code" ];
      grant_types = [ "authorization_code" ];
      require_pkce = true;
      pkce_challenge_method = "S256";
      access_token_signed_response_alg = "none";
      userinfo_signed_response_alg = "none";
      token_endpoint_auth_method = "client_secret_basic";
    }
    {
      client_id = "homeassistant";
      public = false;
      authorization_policy = "one_factor";
      pre_configured_consent_duration = "1 month";
      require_pkce = true;
      pkce_challenge_method = "S256";
      redirect_uris = [ "https://home.${domain}/auth/oidc/callback" ];
      token_endpoint_auth_method = "client_secret_post";
    }
  ];
  secretNames = [
    "jwt-secret"
    "session-secret"
    "storage-encryption-key"
    "smtp-password"
    "oidc-hmac-secret"
    "oidc-issuer-private-key"
  ]
  ++ map (client: "client-${client.client_id}") clients;
in
{
  services.authelia.instances.main = {
    enable = true;
    secrets = {
      jwtSecretFile = secretPath "jwt-secret";
      sessionSecretFile = secretPath "session-secret";
      storageEncryptionKeyFile = secretPath "storage-encryption-key";
      oidcHmacSecretFile = secretPath "oidc-hmac-secret";
      oidcIssuerPrivateKeyFile = secretPath "oidc-issuer-private-key";
    };
    environmentVariables.AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = secretPath "smtp-password";
    settingsFiles = [ config.sops.templates."authelia-clients.yml".path ];
    settings = {
      theme = "dark";
      telemetry.metrics = {
        enabled = true;
        address = "tcp://0.0.0.0:9959/metrics";
      };
      default_2fa_method = "webauthn";
      server = {
        address = "tcp://127.0.0.1:9091/";
        disable_healthcheck = false;
        endpoints.authz.forward-auth.implementation = "ForwardAuth";
        headers.csp_template = "default-src 'self'; style-src 'self' 'nonce-\${NONCE}' 'sha256-47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=' 'unsafe-inline' theme-park.dev raw.githubusercontent.com use.fontawesome.com; img-src 'self' theme-park.dev raw.githubusercontent.com data:; script-src 'self' 'nonce-\${NONCE}'; object-src 'none'; form-action 'self'; frame-ancestors 'self'; font-src use.fontawesome.com; base-uri 'self';";
      };
      log = {
        level = "debug";
        format = "json";
      };
      totp.disable = true;
      webauthn = {
        disable = false;
        enable_passkey_login = true;
        display_name = "Authelia";
      };
      duo_api.disable = true;
      identity_validation.reset_password = {
        jwt_lifespan = "5 minutes";
        jwt_algorithm = "HS256";
      };
      authentication_backend.file = {
        path = "/var/lib/authelia-main/users_database.yml";
        watch = true;
        search = {
          email = false;
          case_insensitive = false;
        };
        password = {
          algorithm = "argon2";
          argon2 = {
            variant = "argon2id";
            iterations = 3;
            memory = 65536;
            parallelism = 4;
            key_length = 32;
            salt_length = 16;
          };
        };
      };
      password_policy.zxcvbn = {
        enabled = true;
        min_score = 3;
      };
      privacy_policy.enabled = false;
      access_control = {
        default_policy = "one_factor";
        rules = [ ];
      };
      session = {
        name = "authelia_session";
        same_site = "lax";
        inactivity = "15m";
        expiration = "24h";
        remember_me = "6M";
        cookies = [
          {
            inherit domain;
            authelia_url = "https://auth.${domain}";
            default_redirection_url = baseUrl;
          }
        ];
        redis = {
          host = config.services.redis.servers.authelia.bind;
          port = config.services.redis.servers.authelia.port;
        };
      };
      regulation = {
        modes = [ "user" ];
        max_retries = 5;
        find_time = "2 minutes";
        ban_time = "5 minutes";
      };
      storage.local.path = "/var/lib/authelia-main/db.sqlite3";
      notifier = {
        disable_startup_check = false;
        smtp = {
          address = "smtp://mail.smtp2go.com:2525";
          timeout = "5 seconds";
          username = "auth.wi1.xyz";
          sender = "auth@wi1.xyz";
          subject = "[wi1.xyz] {title}";
        };
      };
      identity_providers.oidc = {
        enable_client_debug_messages = false;
        authorization_policies.policy_name = {
          default_policy = "one_factor";
          rules = [
            {
              policy = "deny";
              subject = "group:services";
              networks = [ "192.168.1.0/24" ];
            }
          ];
        };
        lifespans = {
          access_token = "1 hour";
          authorize_code = "1 minute";
          id_token = "1 hour";
          refresh_token = "90 minutes";
        };
        cors = {
          endpoints = [
            "authorization"
            "pushed-authorization-request"
            "token"
            "revocation"
            "introspection"
            "userinfo"
          ];
          allowed_origins = [ baseUrl ];
          allowed_origins_from_client_redirect_uris = false;
        };
        claims_policies.grafana.id_token = [
          "email"
          "name"
          "groups"
          "preferred_username"
        ];
      };
    };
  };

  wthueb.exporters.scrapeTargets = [
    {
      job = "authelia";
      port = 9959;
    }
  ];

  services.prometheus.exporters.redis = {
    enable = true;
    extraFlags = [
      "--redis.addr=redis://${config.services.redis.servers.authelia.bind}:${toString config.services.redis.servers.authelia.port}"
    ];
  };

  services.redis.servers.authelia = {
    enable = true;
    bind = "127.0.0.1";
    port = 6379;
    save = [
      [
        60
        1
      ]
    ];
  };

  systemd.services.authelia-main = {
    requires = [ "redis-authelia.service" ];
    after = [ "redis-authelia.service" ];
  };

  sops.secrets = lib.genAttrs (map (name: "authelia/${name}") secretNames) (_: {
    sopsFile = ./secrets-authelia.yaml;
    owner = instance.user;
    group = instance.group;
    mode = "0400";
    restartUnits = [ "authelia-main.service" ];
  });

  sops.templates."authelia-clients.yml" = {
    content = builtins.toJSON {
      identity_providers.oidc.clients = map (
        client:
        client
        // {
          client_secret = config.sops.placeholder."authelia/client-${client.client_id}";
        }
      ) clients;
    };
    owner = instance.user;
    group = instance.group;
    mode = "0400";
    restartUnits = [ "authelia-main.service" ];
  };
}
