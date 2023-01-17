output "adm_private_key" {
    description = "Admin private key"
    value = openstack_compute_keypair_v2.adm_keypair.private_key
}

output "db_private_key_1" {
    description = "Database private key"
    value = openstack_compute_keypair_v2.db_keypair_1.private_key
}

output "db_private_key_2" {
    description = "Database private key"
    value = openstack_compute_keypair_v2.db_keypair_2.private_key
}

output "app_private_key_1" {
    description = "Application private key"
    value = openstack_compute_keypair_v2.app_keypair_1.private_key
}

output "app_private_key_2" {
    description = "Application private key"
    value = openstack_compute_keypair_v2.app_keypair_2.private_key
}