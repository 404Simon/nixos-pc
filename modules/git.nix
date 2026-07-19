{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  programs.git = {
    enable = true;

    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
      format = "ssh";
    };

    settings = {

      user = {
        name = "404Simon";
        email = "s.wi@mail.de";
      };

      core = {
        editor = "nvim";
      };
      pull = {
        rebase = true;
      };
      init = {
        defaultBranch = "main";
      };
      tag = {
        gpgSign = true;
      };
    };
  };
  programs.lazygit.enable = true;
  programs.gh.enable = true;
  programs.gh.extensions = [
    pkgs-unstable.gh-dash
  ];
  programs.gh-dash.enable = true;
  programs.gh-dash.package = pkgs-unstable.gh-dash;
  programs.gh-dash.settings = {
    prSections = [
      {
        title = "My Repos";
        filters = "is:open user:@me";
      }
      {
        title = "My Pull Requests";
        filters = "is:open author:@me";
      }
      {
        title = "Needs My Review";
        filters = "is:open review-requested:@me";
      }
      {
        title = "Involved";
        filters = "is:open involves:@me -author:@me";
      }
    ];
  };
}
