extern crate i3ipc;
extern crate quickrandr;
extern crate virt;
#[macro_use]
extern crate clap;
extern crate indicatif;

use std::path::PathBuf;
use std::{thread, time};
use std::process::Command;
use indicatif::{ProgressBar, ProgressStyle};
use virt::connect::Connect;
use virt::domain::Domain;


fn main() {
    let cli = clap_app!(myapp =>
        (version: "0.2")
        (author: "lae <lae@lae.is")
        (about: "Disables a display while a libvirt domain (virtual machine) is active.")
        (@arg DISPLAY: +required "Display ID from XRandR to disable.")
        (@arg DOMAIN: +required "Libvirt domain to watch for shutdown before reactivating screen.")
    ).get_matches();

    let display_id = cli.value_of("DISPLAY").unwrap();
    let domain = cli.value_of("DOMAIN").unwrap();

    let check_interval = time::Duration::new(1, 0);

    let spinner = start_spinner(format!("Waiting for domain \"{}\" to become active.", domain));
    while !domain_is_online(domain) {
        thread::sleep(check_interval);
    }
    spinner.finish();

    let mut connection = i3ipc::I3Connection::connect().unwrap();
    let ws_reply = connection.get_workspaces().unwrap();

    let config_path = PathBuf::from(r"/tmp/currentlayout.json");
    println!("Saving current display configuration to {:?}.", config_path);
    quickrandr::cmd_save(&config_path, false);

    println!("Disabling display ID {}.", display_id);
    Command::new("xrandr").arg("--output").arg(format!("{}", display_id))
          .arg("--off").status().expect("Failed to turn off screen.");

    let spinner = start_spinner(format!("Waiting for domain \"{}\" to go offline.", domain));
    while domain_is_online(domain) {
        thread::sleep(check_interval);
    }
    spinner.finish();

    let spinner = start_spinner("Restoring display configuration.");
    quickrandr::cmd_auto(&config_path, None, false);
    for workspace in &ws_reply.workspaces {
        spinner.println(format!("{:?}", workspace));
        if workspace.output == display_id {
            let cmd = format!("[workspace={}] move workspace to output {}", workspace.name, display_id);
            let _ = connection.run_command(&cmd);
            spinner.println(format!("workspace {} move back to display {}.", workspace.name, display_id));
        }
        if workspace.focused {
            let cmd = format!("workspace {}", workspace.name);
            let _ = connection.run_command(&cmd);
            spinner.println(format!("workspace {} was refocused.", workspace.name));
        }
    }
    spinner.finish();
}

fn domain_is_online<I: Into<String>>(domain: I) -> bool {
    let mut online = false;
    if let Ok(mut c) = Connect::open("qemu:///system") {
        if let Ok(mut d) = Domain::lookup_by_name(&c, &domain.into()) {
            online = match d.is_active() {
                Ok(a) => a,
                Err(_) => { panic!("Failed to check domain!") }
            };
            let _ = d.free();
        }
        let _ = c.close();
    }

    online
}

fn start_spinner<I: Into<String>>(message: I) -> ProgressBar {
    let style = ProgressStyle::default_spinner()
        .tick_chars("◯◎⦿ ")
        .template("{msg} {spinner}");
    let spinner = ProgressBar::new_spinner();
    spinner.set_style(style);
    spinner.enable_steady_tick(200);
    spinner.set_message(&message.into());

    spinner
}
