{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  home.packages = [
    pkgs-unstable.ironbar
  ];

  xdg.configFile."ironbar/config.toml".text = ''
    position = "top"
    height = 20
    name = "top"

    [[start]]
    type = "workspaces"

    [[center]]
    type = "music"
    player_type = "mpd"
    host = "/home/simon/.mpd/socket"

    [start.icons]
    play = ""
    pause = ""

    [[end]]
    type = "battery"
    format = "{percentage}%"

    [end.thresholds]
    warning = 20
    critical = 5

    [[end]]
    type = "bluetooth"
    icon_size = 32

    [end.format]
    not_found = ""
    disabled = " Off"
    enabled = " On"
    connected = " {device_alias}"
    connected_battery = " {device_alias} • {device_battery_percent}%"

    [end.popup]
    max_height.devices = 5
    header = " Enable Bluetooth"
    disabled = "{adapter_status}"

    [end.popup.device]
    header = "{device_alias}"
    header_battery = "{device_alias}"
    footer = "{device_status}"
    footer_battery = "{device_status} • Battery {device_battery_percent}%"

    [end.adapter_status]
    not_found = "No Bluetooth adapters found"
    enabled = "Bluetooth enabled"
    enabling = "Enabling Bluetooth..."
    disabled = "Bluetooth disabled"
    disabling = "Disabling Bluetooth..."

    [end.device_status]
    connected = "Connected"
    connecting = "Connecting..."
    disconnected = "Disconnect"
    disconnecting = "Disconnecting..."

    [[end]]
    type = "volume"

    [[end]]
    type = "tray"

    [[end]]
    type = "clock"

    [[end]]
    type = "notifications"
  '';

  xdg.configFile."ironbar/style.css".text = ''
    :root {
        --color-dark-primary: #1c1c1c;
        --color-dark-secondary: #2d2d2d;
        --color-white: #fff;
        --color-active: #6699cc;
        --color-urgent: #8f0a0a;

        --margin-lg: 1em;
        --margin-sm: 0.5em;
    }

    * {
        border-radius: 0;
        border: none;
        box-shadow: none;
        background-image: none;
        font-family: "JetBrainsMono Nerd Font";
    }

    #bar, popover, popover contents, calendar {
        background-color: var(--color-dark-primary);
    }

    box, button, label {
        background-color: #0000;
        color: var(--color-white);
    }

    button {
        padding-left: var(--margin-sm);
        padding-right: var(--margin-sm);
    }

    button:hover, button:active {
        background-color: var(--color-dark-secondary);
    }

    #end > * + * {
        margin-left: var(--margin-lg);
    }

    #end > *:last-child {
        padding-right: var(--margin-lg);
    }

    .sysinfo > * + * {
        margin-left: var(--margin-sm);
    }

    .clock {
        font-weight: bold;
    }

    .popup-clock .calendar-clock {
        font-size: 2.0em;
    }

    .popup-clock .calendar .today {
        background-color: var(--color-active);
    }

    .workspaces .item.visible {
        box-shadow: inset 0 -1px var(--color-white);
    }

    .workspaces .item.focused {
        box-shadow: inset 0 -1px var(--color-active);
        background-color: var(--color-dark-secondary);
    }

    .workspaces .item.urgent {
        background-color: var(--color-urgent);
    }

    /* Volume Widget */
    .volume {
        padding-left: var(--margin-sm);
        padding-right: var(--margin-sm);
    }

    .volume:hover {
        background-color: var(--color-dark-secondary);
    }

    .popup-volume {
        padding: var(--margin-lg);
        background-color: var(--color-dark-primary);
    }

    .popup-volume .device-box {
        padding: var(--margin-sm);
        background-color: var(--color-dark-secondary);
        border-radius: 4px;
        margin-bottom: var(--margin-sm);
    }

    .popup-volume .device-box .device-selector {
        padding: var(--margin-sm);
        margin-bottom: var(--margin-sm);
        background-color: var(--color-dark-primary);
    }

    .popup-volume .device-box .device-selector:hover {
        background-color: var(--color-dark-secondary);
    }

    .popup-volume .device-box .slider {
        margin: var(--margin-sm) 0;
        min-width: 20;
    }

    .popup-volume .device-box .slider trough {
        background-color: rgba(255, 255, 255, 0.1);
        min-height: 4px;
        min-width: 5px;
    }

    .popup-volume .device-box .slider highlight {
        background-color: var(--color-active);
        min-height: 4px;
    }

    .popup-volume .device-box .btn-mute {
        margin-top: var(--margin-sm);
    }

    .popup-volume .device-box .btn-mute:hover {
        background-color: var(--color-dark-primary);
    }

    .popup-volume .apps-box {
        margin-top: var(--margin-sm);
    }

    .popup-volume .apps-box .app-box {
        padding: var(--margin-sm);
        background-color: var(--color-dark-secondary);
        border-radius: 4px;
        margin-bottom: var(--margin-sm);
    }

    .popup-volume .apps-box .app-box .title {
        font-weight: bold;
        margin-bottom: var(--margin-sm);
    }

    .popup-volume .apps-box .app-box .slider {
        margin: var(--margin-sm) 0;
    }

    .popup-volume .apps-box .app-box .slider trough {
        background-color: rgba(255, 255, 255, 0.1);
        min-height: 4px;
    }

    .popup-volume .apps-box .app-box .slider highlight {
        background-color: var(--color-active);
    }

    .popup-volume .apps-box .app-box .btn-mute {
        margin-top: var(--margin-sm);
    }

    .popup-volume .apps-box .app-box .btn-mute:hover {
        background-color: var(--color-dark-primary);
    }

    /* Music Widget */
    .music .slider trough {
        background-color: rgba(255, 255, 255, 0.1);
        min-height: 4px;
        min-width: 5px;
    }

    .music .slider highlight {
        background-color: var(--color-active);
        min-height: 4px;
    }
  '';
}
