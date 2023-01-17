# Importing RancherOS image
resource "openstack_images_image_v2" "rancheros" {
  name             = "rancheros"
  container_format = "bare"
  disk_format      = "qcow2"
  image_source_url = "https://github.com/rancher/os/releases/download/v1.5.8/rancheros-openstack.img"
}
