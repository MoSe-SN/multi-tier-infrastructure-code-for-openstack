# Admin security group
resource "openstack_networking_secgroup_v2" "adm_secgroup" {
  name        = "admin-secgroup"
  description = "Admin security group"
}


resource "openstack_networking_secgroup_rule_v2" "admtcp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.adm_secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "admudp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.adm_secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "admicmp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.adm_secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "admssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.adm_secgroup.id}"
}

# Database security group
resource "openstack_networking_secgroup_v2" "db_secgroup" {
  name        = "database-secgroup"
  description = "Database security group"
}

resource "openstack_networking_secgroup_rule_v2" "dbtcp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.db_secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "dbudp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.db_secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "dbicmp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.db_secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "dbadmtcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "172.16.1.0/24"
  security_group_id = "${openstack_networking_secgroup_v2.db_secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "dbadmudp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "172.16.1.0/24"
  security_group_id = "${openstack_networking_secgroup_v2.db_secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "dbadmicmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "172.16.1.0/24"
  security_group_id = "${openstack_networking_secgroup_v2.db_secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "dbapp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1521
  port_range_max    = 1521
  remote_ip_prefix  = "10.50.1.0/24"
  security_group_id = "${openstack_networking_secgroup_v2.db_secgroup.id}"
}

# Application security group
resource "openstack_networking_secgroup_v2" "app_secgroup" {
  name        = "application-secgroup"
  description = "Application security group"
}

resource "openstack_networking_secgroup_rule_v2" "apptcp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.app_secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "appudp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.app_secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "appicmp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.app_secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "appadmtcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "172.16.1.0/24"
  security_group_id = "${openstack_networking_secgroup_v2.app_secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "appadmudp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "172.16.1.0/24"
  security_group_id = "${openstack_networking_secgroup_v2.app_secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "appadmicmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "172.16.1.0/24"
  security_group_id = "${openstack_networking_secgroup_v2.app_secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "apphttp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.app_secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "apphttps" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.app_secgroup.id}"
}

