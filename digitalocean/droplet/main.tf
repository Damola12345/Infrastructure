## DOK

# Create a Vpc in the fra1 region
module "vpc" {
  source      = "terraform-do-modules/vpc/digitalocean"
  name        = "dam-vpc"
  environment = "dev"
  region      = "fra1"
  ip_range    = "10.10.0.0/16"
}

provider "digitalocean" {
  token = ""
}

# Create a new Web Droplet in the fra1 region
resource "digitalocean_droplet" "vm" {
  image    = "ubuntu-22-04-x64"
  name     = "dam-dev-vm"
  region   = "fra1"
  size     = "s-1vcpu-1gb"
  vpc_uuid = module.vpc.id
  ssh_keys = [""]

}

# Create firewall for Droplet in the fra1 region
resource "digitalocean_firewall" "testcloud" {
  name = "dam-dev-fw"

  droplet_ids = [digitalocean_droplet.vm.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "8000"
    source_addresses = ["", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}