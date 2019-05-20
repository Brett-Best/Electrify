# Installation

1. Copy `Electrify.service` to `~/.config/systemd/user/Electrify.service`
2. Run `sudo loginctl enable-linger pi`
3. Run `systemctl --user enable Electrify` 
5. Run `systemctl --user start Electrify`