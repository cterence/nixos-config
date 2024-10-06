{
  programs.awscli = {
    enable = true;
    # .aws/config file
    settings = {
      "default" = {
        region = "eu-west-3";
        output = "json";
      };
      "profile default" = {
        sso_start_url = "https://terencech.awsapps.com/start";
        sso_region = "eu-west-3";
        sso_account_name = "terence";
        sso_account_id = "964066691632";
        sso_role_name = "AdministratorAccess";
        region = "eu-west-3";
      };
    };
  };
}
