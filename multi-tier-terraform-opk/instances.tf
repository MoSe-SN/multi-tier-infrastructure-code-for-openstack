# ---------- Creating admin instance ---------- #
resource "openstack_compute_instance_v2" "admin_instance" {
  name      = "admin-ins"
  image_id  = "${openstack_images_image_v2.rancheros.id}"
  flavor_id = "${openstack_compute_flavor_v2.flavor_admserv.id}"
  key_pair  = "${openstack_compute_keypair_v2.adm_keypair.name}"
  network {
    port    = "${openstack_networking_port_v2.adm_port.id}"
  }
}

resource "openstack_networking_port_v2" "adm_port" {
  name               = "adm-port"
  network_id         = "${openstack_networking_network_v2.adm_network.id}"
  admin_state_up     = true
  security_group_ids = ["${openstack_networking_secgroup_v2.adm_secgroup.id}"]
  fixed_ip {
    subnet_id        = "${openstack_networking_subnet_v2.admin_subnet.id}"
    ip_address       = "172.16.1.2"
  }
}

resource "openstack_networking_floatingip_v2" "adm_floatingip" {
  pool    = "${openstack_networking_network_v2.external.name}"
  address = "9.12.93.101"
  port_id = "${openstack_networking_port_v2.adm_port.id}"
}


# ---------- Creating application instances ---------- #
resource "openstack_compute_instance_v2" "application_instance_1" {
  name      = "application-ins-1"
  image_id  = "${openstack_images_image_v2.rancheros.id}"
  flavor_id = "${openstack_compute_flavor_v2.flavor_appserv.id}"
  key_pair  = "${openstack_compute_keypair_v2.app_keypair_1.name}"
  user_data = file("./scripts/webserver-boot.sh")
  network {
    port    = "${openstack_networking_port_v2.app_port_1.id}"
  }
}

resource "openstack_compute_instance_v2" "application_instance_2" {
  name      = "application-ins-2"
  image_id  = "${openstack_images_image_v2.rancheros.id}"
  flavor_id = "${openstack_compute_flavor_v2.flavor_appserv.id}"
  key_pair  = "${openstack_compute_keypair_v2.app_keypair_2.name}"
  user_data = file("./scripts/web-boot.sh")
  network {
    port    = "${openstack_networking_port_v2.app_port_2.id}"
  }
}

resource "openstack_networking_port_v2" "app_port_1" {
  name               = "app-port-1"
  network_id         = "${openstack_networking_network_v2.app_network.id}"
  admin_state_up     = true
  security_group_ids = ["${openstack_networking_secgroup_v2.app_secgroup.id}"]
  fixed_ip {
    subnet_id        = "${openstack_networking_subnet_v2.application_subnet.id}"
    ip_address       = "10.50.1.2"
  }
}

resource "openstack_networking_port_v2" "app_port_2" {
  name               = "app-port-2"
  network_id         = "${openstack_networking_network_v2.app_network.id}"
  admin_state_up     = true
  security_group_ids = ["${openstack_networking_secgroup_v2.app_secgroup.id}"]
  fixed_ip {
    subnet_id        = "${openstack_networking_subnet_v2.application_subnet.id}"
    ip_address       = "10.50.1.3"
  }
}

resource "openstack_networking_floatingip_v2" "app_floatingip_1" {
  pool    = "${openstack_networking_network_v2.external.name}"
  address = "9.12.93.102"
  port_id = "${openstack_networking_port_v2.app_port_1.id}"
}

resource "openstack_networking_floatingip_v2" "app_floatingip_2" {
  pool    = "${openstack_networking_network_v2.external.name}"
  address = "9.12.93.103"
  port_id = "${openstack_networking_port_v2.app_port_2.id}"
}

# ---------- Creating database instances ---------- #
resource "openstack_compute_instance_v2" "database_instance_1" {
  name      = "database-ins-1"
  image_id  = "${openstack_images_image_v2.rancheros.id}"
  flavor_id = "${openstack_compute_flavor_v2.flavor_dbserv.id}"
  key_pair  = "${openstack_compute_keypair_v2.db_keypair_1.name}"
  network {
    port    = "${openstack_networking_port_v2.db_port_1.id}"
  }
}

resource "openstack_compute_instance_v2" "database_instance_2" {
  name      = "database-ins-2"
  image_id  = "${openstack_images_image_v2.rancheros.id}"
  flavor_id = "${openstack_compute_flavor_v2.flavor_appserv.id}"
  key_pair  = "${openstack_compute_keypair_v2.app_keypair_2.name}"
  network {
    port    = "${openstack_networking_port_v2.db_port_2.id}"
  }
}

resource "openstack_networking_port_v2" "db_port_1" {
  name               = "db-port-1"
  network_id         = "${openstack_networking_network_v2.db_network.id}"
  admin_state_up     = true
  security_group_ids = ["${openstack_networking_secgroup_v2.db_secgroup.id}"]
  fixed_ip {
    subnet_id        = "${openstack_networking_subnet_v2.database_subnet.id}"
    ip_address       = "192.168.1.2"
  }
}

resource "openstack_networking_port_v2" "db_port_2" {
  name               = "db-port-2"
  network_id         = "${openstack_networking_network_v2.db_network.id}"
  admin_state_up     = true
  security_group_ids = ["${openstack_networking_secgroup_v2.db_secgroup.id}"]
  fixed_ip {
    subnet_id        = "${openstack_networking_subnet_v2.database_subnet.id}"
    ip_address       = "192.168.1.3"
  }
}
