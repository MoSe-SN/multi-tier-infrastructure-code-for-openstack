resource "openstack_compute_flavor_v2" "flavor_appserv" {
  name  = var.appserv_flavor["name"]
  ram   = var.appserv_flavor["ram"]
  vcpus = var.appserv_flavor["vcpus"]
  disk  = var.appserv_flavor["disk"]
}

resource "openstack_compute_flavor_v2" "flavor_dbserv" {
  name  = var.dbserv_flavor["name"]
  ram   = var.dbserv_flavor["ram"]
  vcpus = var.dbserv_flavor["vcpus"]
  disk  = var.dbserv_flavor["disk"]
}

resource "openstack_compute_flavor_v2" "flavor_admserv" {
  name  = var.admserv_flavor["name"]
  ram   = var.admserv_flavor["ram"]
  vcpus = var.admserv_flavor["vcpus"]
  disk  = var.admserv_flavor["disk"]
}