# homebase

An always-on Claude Code server on a Raspberry Pi 5. Start and manage coding
projects from your phone or computer from anywhere, using Claude Code
**Remote Control**, and wake your PC remotely over a direct Ethernet cable.

```
   Phone / laptop (anywhere)
        │   Claude app (Remote Control) · Tailscale · Pi Connect
        ▼
   School WiFi ──── Pi (homebase) ══ Ethernet cable ══ PC
                    always-on Claude        (Wake-on-LAN only)
```

What the installer sets up:

- **Always-on Claude session** in `~/projects` (systemd + tmux), restarted
  automatically if it exits and started at every boot.
- **`homebase` command** for status, projects, waking the PC, backups and updates.
- **`~/projects/CLAUDE.md`**: rules that keep Claude's projects organized and
  stop it from breaking the system.
- **Self-healing**: a network watchdog repairs stuck WiFi, and a hardware
  watchdog reboots the Pi if it freezes.
- **microSD protection**: logs and swap in RAM to reduce card wear.
- **Direct PC cable** configured so it works without a router.
- **Tailscale** for private remote access without router settings.

---

## 1. Flash the microSD card

1. On your PC, install **Raspberry Pi Imager** (raspberrypi.com/software).
2. Choose **Raspberry Pi 5** → **Raspberry Pi OS (other) → Raspberry Pi OS Lite (64-bit)** → your microSD card.
3. In the customization settings:
   - Hostname: `homebase`
   - Username and password: write them down
   - WiFi: network name (exact spelling) and password; country `US`
   - Time zone: your zone (e.g. `America/Chicago`)
   - SSH: enabled, with password authentication
   - Raspberry Pi Connect: enabled (backup way in from any browser)
4. Write the card, put it in the Pi (slot on the underside), connect the
   Ethernet cable from the Pi to the PC, and plug in the power.
   First boot takes 3–5 minutes and restarts once.

## 2. First login

On the PC, in PowerShell:

```
ssh yourname@homebase.local
```

The password doesn't show while you type; that's normal.

**If `homebase.local` isn't found or times out:** on a fresh install the Pi's
Ethernet port keeps waiting for a router that isn't there. Open
**connect.raspberrypi.com → your Pi → Remote shell** and run:

```
nmcli device status                      # note the eth0 CONNECTION name, e.g. netplan-eth0
sudo nmcli connection modify netplan-eth0 ipv4.method link-local ipv6.method link-local
sudo nmcli connection up netplan-eth0
```

(The installer makes this change too, but you need a way in to run it.)

## 3. Update the Pi and install Claude Code

```
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y git
sudo reboot
```

Reconnect, then:

```
curl -fsSL https://claude.ai/install.sh | bash
exit
```

Reconnect again, then log in:

```
claude
```

Choose **Claude account with subscription**, open the link it prints on your
PC, sign in, paste the code back, then type `/exit`.

Test Remote Control once by hand, so any first-time questions get answered:

```
mkdir -p ~/projects && cd ~/projects
claude remote-control
```

Check that the session shows up in the Claude app on your phone, then press
**Ctrl+C**.

## 4. Install homebase

```
git clone https://github.com/alexanderr2808/homebase ~/homebase
~/homebase/install.sh
```

It asks for your password for system changes. It's safe to run again at any
time; steps already done are skipped.

Set your git identity so Claude can commit:

```
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

## 5. Tailscale

The installer installs Tailscale. Log in:

```
sudo tailscale up
```

Open the link and sign in. Then:

- Install Tailscale on your **phone** and **PC** with the same account.
- At **login.tailscale.com/admin/machines**, open the ⋯ menu next to the Pi
  and the PC and choose **Disable key expiry**. Otherwise you get locked out
  every 180 days.

From anywhere, `ssh yourname@homebase` now works over Tailscale (on a phone,
use an SSH app such as Termius).

## 6. PC setup (Wake-on-LAN and remote desktop)

**Remote desktop:** install **RustDesk** (or Chrome Remote Desktop) on the PC
and phone.

**Wake-on-LAN through the cable:**

1. **BIOS/UEFI** (press Del or F2 while the PC starts): enable *Wake on LAN*
   (may be called *Power On by PCI-E* or *Resume by LAN*), and disable
   *ErP / EuP / Deep Sleep*. Optional: set *Restore on AC Power Loss →
   Power On* so the PC starts after a power cut.
2. **Windows → Device Manager → Network adapters → your Ethernet adapter
   (Intel I225-V) → Properties:**
   - *Power Management*: tick "Allow this device to wake the computer" and
     "Only allow a magic packet to wake the computer".
   - *Advanced*: set *Wake on Magic Packet* to Enabled.
3. **Turn off Fast Startup:** Control Panel → Power Options → *Choose what the
   power buttons do* → *Change settings that are currently unavailable* →
   untick *Turn on fast startup*.
4. In PowerShell run `Get-NetAdapter` and copy the **MacAddress** of the
   **Ethernet** row. On the Pi:

   ```
   homebase config PC_MAC AA-BB-CC-DD-EE-FF
   ```

5. Test it: shut the PC down, then on the Pi run `homebase wake pc`.

**Remote desktop at the sign-in screen:** install RustDesk with **Install**
(not "Run without installing") so it runs as a Windows service, and set a
**permanent password** in its Security settings. You can then type your
Windows PIN or password remotely after waking the PC.

### Optional: sign in to Windows automatically

So that `homebase wake pc` boots straight to the desktop. The trade-off:
anyone who turns the PC on is signed straight into your account.

1. **Settings → Accounts → Sign-in options**: turn off *"For improved
   security, only allow Windows Hello sign-in for Microsoft accounts on this
   device"*. Otherwise Windows hides automatic sign-in.
2. Download **Autologon** from Microsoft Sysinternals
   (learn.microsoft.com/sysinternals/downloads/autologon), unzip it and run
   **Autologon64.exe**. Accept the license.
3. *Username* and *Domain* are filled in already. Enter your account
   **password** (for a Microsoft account, the account password, not your
   PIN) and click **Enable**. Autologon stores it encrypted.
4. Restart the PC to check it reaches the desktop without a sign-in screen.

To turn it off, run Autologon again and click **Disable**.

**Optional, sign in then lock:** startup apps run, but the screen stays
locked. Task Scheduler → *Create Task* → *Triggers*: **At log on** (your
user), delayed 30 seconds → *Actions*: start program `rundll32.exe` with
arguments `user32.dll,LockWorkStation`.

## 7. Check everything

```
homebase doctor
```

---

## Everyday use

| Command | What it does |
|---|---|
| `homebase status` | Session, WiFi, internet, Tailscale, cable, disk, memory, temperature |
| `homebase doctor` | Checks the whole setup and says how to fix each problem |
| `homebase start` / `stop` / `restart` | Control the always-on Claude session |
| `homebase attach` | See the session's terminal (leave with **Ctrl+B, then D**) |
| `homebase logs` | Recent session output (`-f` to follow system logs) |
| `homebase new <name>` | New project folder with git and a README |
| `homebase list` | List projects and when each last changed |
| `homebase wake pc` | Wake the PC over the cable |
| `homebase update` | Get the latest homebase and re-run the installer (`--system` also updates Raspberry Pi OS) |
| `homebase backup` | Copy the whole system to a spare microSD card |
| `homebase config` | Show settings, or change one: `homebase config KEY VALUE` |

Day to day: open the Claude app → Claude Code → the **homebase** session, and
ask it to create or work on a project.

## Before you travel

- [ ] `homebase doctor` passes
- [ ] Tailscale key expiry disabled for the Pi and the PC
- [ ] Test from outside: turn off WiFi on your phone and, on cellular data,
      open the Claude session, `ssh` in via Tailscale, wake the PC and
      remote into it
- [ ] Pi Connect works (connect.raspberrypi.com), as a backup way in
- [ ] All projects pushed to GitHub
- [ ] A fresh `homebase backup` on the spare card
- [ ] Optional: someone nearby who can unplug and replug the Pi if needed
- [ ] If you're away over a school break: check whether campus WiFi and power stay on

## Troubleshooting

**The session doesn't show in the Claude app:** `homebase status`, then
`homebase logs`. If Claude is asking a question, `homebase attach` lets you
answer it (leave with Ctrl+B, then D).

**Can't reach the Pi at all:** try Pi Connect in a browser, then Tailscale. If
neither works the Pi is probably offline; it reconnects by itself when the WiFi
returns. The network watchdog also retries WiFi every few minutes and reboots
the Pi after 30 minutes offline (at most once every 6 hours).

**The school WiFi password changed:** the Pi can't get online until it knows
the new one. Connect over the cable (`ssh yourname@homebase.local`) or plug in
a monitor and keyboard, then run `sudo nmtui` → *Edit a connection* → the WiFi
network → update the password.

**`homebase wake pc` does nothing:** check that the Ethernet lights on both
ends are on while the PC is off, re-check the BIOS and Windows settings in
step 6 (Windows updates sometimes turn Fast Startup back on), and confirm
`homebase config` shows the PC's *Ethernet* MAC address, not the WiFi one.

**Restarting the Pi:** use `sudo reboot`, or press the Pi's power button once
to shut down cleanly. Pull the plug only if it's completely frozen, since
unplugging during writes can corrupt the microSD card.

## Backups

The microSD card can fail without warning, so:

- **Projects:** push to GitHub. Claude is told to do this.
- **The whole system:** put a spare microSD card in a USB card reader, plug it
  into the Pi and run `homebase backup` to see the steps. If the main card
  dies, put in the spare and the Pi boots as before.

## Later: moving to an SSD

homebase runs fine from microSD. If you add an NVMe SSD later (with an M.2 HAT
that supports your SSD's size), use `homebase backup <ssd-device>` to copy the
system onto it, then set the boot order with
`sudo raspi-config` → *Advanced Options* → *Boot Order* → *NVMe/USB Boot*.

## How it works

```
install.sh                  installer; runs modules/*.sh in order
bin/homebase                the homebase command (linked into /usr/local/bin)
lib/common.sh               shared helpers and settings
lib/run-session.sh          runs inside tmux; keeps `claude remote-control` alive
lib/netwatch.sh             network watchdog (every 2 min, as root)
modules/                    one file per install step
templates/                  systemd units, configs, projects CLAUDE.md
~/.config/homebase/config   your settings
```

The `homebase` systemd service starts a tmux session named `homebase` that
runs `claude remote-control` in `~/projects`.
