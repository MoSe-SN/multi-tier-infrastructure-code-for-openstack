# Creating SSH keys
resource "openstack_compute_keypair_v2" "adm_keypair" {
  name = "adm-keypair"
}

resource "openstack_compute_keypair_v2" "app_keypair_1" {
  name = "app-keypair-1"
}

resource "openstack_compute_keypair_v2" "app_keypair_2" {
  name = "app-keypair-2"
}

resource "openstack_compute_keypair_v2" "db_keypair_1" {
  name = "db-keypair-1"
}

resource "openstack_compute_keypair_v2" "db_keypair_2" {
  name = "db-keypair-2"
}