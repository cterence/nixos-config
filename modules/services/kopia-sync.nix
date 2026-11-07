{ inputs, ... }:
{
  flake.aspects.kopia-sync.homeManager =
    {
      pkgs,
      config,
      ...
    }:
    {
      sops.secrets = {
        b2-velero-backup-tch-key-id = {
          mode = "0440";
          sopsFile = "${inputs.secrets}/shared.yaml";
        };
        b2-velero-backup-tch-key = {
          mode = "0440";
          sopsFile = "${inputs.secrets}/shared.yaml";
        };
        garage-velero-access-key = {
          mode = "0440";
          sopsFile = "${inputs.secrets}/shared.yaml";
        };
        garage-velero-secret-key = {
          mode = "0440";
          sopsFile = "${inputs.secrets}/shared.yaml";
        };
        kopia-password = {
          mode = "0440";
          sopsFile = "${inputs.secrets}/shared.yaml";
        };
      };

      systemd.user.services.kopia-sync-backblaze = {
        Unit = {
          Description = "Sync remote Kopia repositories to filesystem repositories";
        };
        Service = {
          ExecStart = "${pkgs.writeShellScript "kopia-sync-backblaze" ''
            #!/run/current-system/sw/bin/bash

            set -eu

            # Configuration
            BUCKET="velero-backup-tch"
            PATH_PREFIX="v2/kopia/"
            ENDPOINT="https://s3.eu-central-003.backblazeb2.com"
            LOCAL_BASE_DIR="/mnt/elements/kopia-sync/repositories"
            B2_KEY_ID="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.b2-velero-backup-tch-key-id.path})"
            B2_KEY="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.b2-velero-backup-tch-key.path})"
            KOPIA_PASSWORD="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.kopia-password.path})"

            # Ensure the local base directory exists
            ${pkgs.coreutils}/bin/mkdir -p "$LOCAL_BASE_DIR"

            export AWS_ACCESS_KEY_ID=$B2_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$B2_KEY

            # List all directories (repositories) in the bucket
            echo "Listing repositories in bucket..."
            REPOSITORIES=$(${pkgs.awscli2}/bin/aws s3 ls "$BUCKET/$PATH_PREFIX" --endpoint-url "$ENDPOINT" | ${pkgs.gawk}/bin/awk '/PRE/ {print $2}' | ${pkgs.gnused}/bin/sed 's:/$::')

            unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

            # Process each directory
            for REPO in $REPOSITORIES; do
                echo "Processing repository: $REPO"

                # Define paths
                REPO_REMOTE_PATH="s3://$BUCKET/$PATH_PREFIX$REPO"
                REPO_LOCAL_PATH="$LOCAL_BASE_DIR/$REPO"

                # Ensure the local repository directory exists
                ${pkgs.coreutils}/bin/mkdir -p "$REPO_LOCAL_PATH"

                # Connect Kopia to the repository
                echo "Connecting Kopia to repository: $REPO_REMOTE_PATH"
                ${pkgs.kopia}/bin/kopia repository connect b2 \
                    --bucket="$BUCKET" \
                    --key-id="$B2_KEY_ID" \
                    --key="$B2_KEY" \
                    --password="$KOPIA_PASSWORD" \
                    --prefix="$PATH_PREFIX$REPO/" \
                    --no-check-for-updates

                # Sync repository to local filesystem
                echo "Syncing repository: $REPO_REMOTE_PATH to $REPO_LOCAL_PATH"
                ${pkgs.kopia}/bin/kopia repository sync-to filesystem \
                    --path="$REPO_LOCAL_PATH" \
                    --parallel="32" \
                    --delete

                # Disconnect Kopia from the repository to avoid conflicts
                echo "Disconnecting repository: $REPO_REMOTE_PATH"
                ${pkgs.kopia}/bin/kopia repository disconnect

            done

            echo "All repositories processed."
          ''}";
        };
      };

      systemd.user.services.kopia-sync-garage = {
        Unit = {
          Description = "Sync remote Kopia repositories to filesystem repositories";
        };
        Service = {
          ExecStart = "${pkgs.writeShellScript "kopia-sync-garage" ''
            #!/run/current-system/sw/bin/bash

            set -eu

            # Configuration
            BUCKET="velero"
            PATH_PREFIX="v1/kopia/"
            ENDPOINT_DOMAIN="garage.snow-delta.ts.net:3900"
            ENDPOINT_URL="http://$ENDPOINT_DOMAIN"
            REGION="us-east-1"
            LOCAL_BASE_DIR="/mnt/elements/kopia-sync-garage/repositories"
            GARAGE_KEY_ID="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.garage-velero-access-key.path})"
            GARAGE_KEY="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.garage-velero-secret-key.path})"
            KOPIA_PASSWORD="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.kopia-password.path})"

            # Ensure the local base directory exists
            ${pkgs.coreutils}/bin/mkdir -p "$LOCAL_BASE_DIR"

            export AWS_ACCESS_KEY_ID=$GARAGE_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$GARAGE_KEY

            # List all directories (repositories) in the bucket
            echo "Listing repositories in bucket..."
            REPOSITORIES=$(${pkgs.awscli2}/bin/aws s3 ls "$BUCKET/$PATH_PREFIX" --endpoint-url "$ENDPOINT_URL" | ${pkgs.gawk}/bin/awk '/PRE/ {print $2}' | ${pkgs.gnused}/bin/sed 's:/$::')

            unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

            # Process each directory
            for REPO in $REPOSITORIES; do
                echo "Processing repository: $REPO"

                # Define paths
                REPO_REMOTE_PATH="s3://$BUCKET/$PATH_PREFIX$REPO"
                REPO_LOCAL_PATH="$LOCAL_BASE_DIR/$REPO"

                # Ensure the local repository directory exists
                ${pkgs.coreutils}/bin/mkdir -p "$REPO_LOCAL_PATH"

                # Connect Kopia to the repository
                echo "Connecting Kopia to repository: $REPO_REMOTE_PATH"
                ${pkgs.kopia}/bin/kopia repository connect s3 \
                    --bucket="$BUCKET" \
                    --password="$KOPIA_PASSWORD" \
                    --disable-tls \
                    --region $REGION \
                    --access-key="$GARAGE_KEY_ID" \
                    --secret-access-key="$GARAGE_KEY" \
                    --endpoint $ENDPOINT_DOMAIN \
                    --prefix="$PATH_PREFIX$REPO/" \
                    --no-check-for-updates

                # Sync repository to local filesystem
                echo "Syncing repository: $REPO_REMOTE_PATH to $REPO_LOCAL_PATH"
                ${pkgs.kopia}/bin/kopia repository sync-to filesystem \
                    --path="$REPO_LOCAL_PATH" \
                    --parallel="32" \
                    --delete

                # Disconnect Kopia from the repository to avoid conflicts
                echo "Disconnecting repository: $REPO_REMOTE_PATH"
                ${pkgs.kopia}/bin/kopia repository disconnect

            done

            echo "All repositories processed."
          ''}";
        };
      };
    };
}
