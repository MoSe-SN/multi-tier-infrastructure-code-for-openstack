# Creating external network
resource "openstack_networking_network_v2" "external" {
  name               = "external-network"
  external           = "true"
  segments {
    physical_network = "physnet1"
    network_type     = "flat"
  }
}

# Creating the external subnet
ressource "openstack_networking_subnet_v2" "external_subnet" {
  network_id  = "${openstack_networking_network_v2.external.id}"
  cidr        = "9.12.93.0/24"
  gateway_ip  = "9.12.93.1"
  enable_dhcp = "false"
  allocation_pool {
    start     = "9.12.93.100"
    end       = "9.12.93.199"
  }
}

# Creating router
resource "openstack_networking_router_v2" "router" {
  name                = "router-generic"
  external_network_id = "${openstack_networking_network_v2.external.id}"
  admin_state_up      = "true"
}


# Creating internal networks
resource "openstack_networking_network_v2" "app_network" {
  name = "app-net"
}

resource "openstack_networking_network_v2" "db_network" {
  name = "db-net"
}

resource "openstack_networking_network_v2" "adm_network" {
  name = "adm-net"
}

# Creating subnets
resource "openstack_networking_subnet_v2" "admin_subnet" {
  name            = var.admin_network["subnet_name"]
  network_id      = "${openstack_networking_network_v2.adm_network.id}"
  cidr            = var.admin_network["cidr"]
  enable_dhcp     = "false"
  ip_version      = 4
  gateway_ip      = var.admin_network["gateway_ip"]
  dns_nameservers = var.dns_ip
}

resource "openstack_networking_subnet_v2" "database_subnet" {
  name            = var.database_network["subnet_name"]
  network_id      = "${openstack_networking_network_v2.db_network.id}"
  cidr            = var.database_network["cidr"]
  enable_dhcp     = "false"
  ip_version      = 4
  gateway_ip      = var.database_network["gateway_ip"]
  dns_nameservers = var.dns_ip
}

resource "openstack_networking_subnet_v2" "application_subnet" {
  name            = var.application_network["subnet_name"]
  network_id      = "${openstack_networking_network_v2.app_network.id}"
  cidr            = var.admin_network["cidr"]
  enable_dhcp     =" false"
  ip_version      = 4
  gateway_ip      = var.admin_network["gateway_ip"]
  dns_nameservers = var.dns_ip
}



# Router ports configuration
# Router interfaces configuration
resource "openstack_networking_router_interface_v2" "app_interface" {
  router_id = "${openstack_networking_router_v2.router.id}"
  subnet_id = "${openstack_networking_subnet_v2.application_subnet.id}"
}

resource "openstack_networking_router_interface_v2" "db_interface" {
  router_id = "${openstack_networking_router_v2.router.id}"
  subnet_id = "${openstack_networking_subnet_v2.database_subnet.id}"
}

resource "openstack_networking_router_interface_v2" "adm_interface" {
  router_id = "${openstack_networking_router_v2.router.id}"
  subnet_id = "${openstack_networking_subnet_v2.admin_subnet.id}"
}
