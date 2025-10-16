{ config, pkgs, ... }:

{
  home = {
    packages = with pkgs; [ nssTools ];
    activation.installHomelabClientCert = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      CERT_FILE="/run/secrets/homelab-client-cert"
      NSSDB_DIR="$HOME/.pki/nssdb"
      PKCS12_PASS="/run/secrets/homelab-client-cert-password"

      if [ -f "$CERT_FILE" ]; then
        # Create and initialize NSS database
        mkdir -p "$NSSDB_DIR"

        if [ ! -f "$NSSDB_DIR/cert9.db" ]; then
          ${pkgs.nssTools}/bin/certutil -N -d sql:"$NSSDB_DIR" --empty-password
        fi

        # Remove old certificate
        ${pkgs.nssTools}/bin/certutil -D -d sql:"$NSSDB_DIR" -n "mtls-client" 2>/dev/null || true
        ${pkgs.nssTools}/bin/certutil -D -d sql:"$NSSDB_DIR" -n "terence.cloud homelab certificate (client auth)" 2>/dev/null || true

        # Import certificate
        ${pkgs.nssTools}/bin/pk12util -i "$CERT_FILE" \
          -d sql:"$NSSDB_DIR" \
          -w "$PKCS12_PASS" \
          -n "terence.cloud homelab certificate (client auth)"

        # Set permissions
        chmod 700 "$NSSDB_DIR"
        chmod 600 "$NSSDB_DIR"/*

        echo "Certificate installed to $NSSDB_DIR"
      fi

      # Install to Firefox profiles
      FIREFOX_DIR="$HOME/.mozilla/firefox"

      if [ -d "$FIREFOX_DIR" ] && [ -f "$CERT_FILE" ]; then
        for profile in "$FIREFOX_DIR"/*.default*; do
          if [ -d "$profile" ]; then
            echo "Installing certificate to Firefox profile: $(basename "$profile")"

            if [ ! -f "$profile/cert9.db" ]; then
              ${pkgs.nssTools}/bin/certutil -N -d sql:"$profile" --empty-password
            fi

            ${pkgs.nssTools}/bin/certutil -D -d sql:"$profile" -n "mtls-client" 2>/dev/null || true
            ${pkgs.nssTools}/bin/certutil -D -d sql:"$profile" -n "terence.cloud homelab certificate (client auth)" 2>/dev/null || true

            ${pkgs.nssTools}/bin/pk12util -i "$CERT_FILE" \
              -d sql:"$profile" \
              -w "$PKCS12_PASS" \
              -n "terence.cloud homelab certificate (client auth)" 2>/dev/null || true
          fi
        done
      fi
    '';
  };
}
