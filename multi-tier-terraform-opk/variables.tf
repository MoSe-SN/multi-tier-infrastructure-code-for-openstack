# Params file for variables

# Neutron variables
variable "external_network_pool" {
  type    = string
  default = "public1"
}

variable "dns_ip" {
  type    = list(string)
  default = ["8.8.8.8"]
}

# VM parameters
variable "admserv_flavor" {
  type = map(string)
  default = {
    name = "t1.adm"
    ram = "1024"
    vcpus = "2"
    disk = "10"
  }
}

variable "dbserv_flavor" {
  type = map(string)
  default = {
    name = "t1.db"
    ram = "1024"
    vcpus = "1"
    disk = "10"
  }
}

variable "appserv_flavor" {
  type = map(string)
  default = {
    name = "t1.app"
    ram = "1024"
    vcpus = "1"
    disk = "10"
  }
}

# Network parameters
variable "admin_network" {
  type = map(string)
  default = {
    subnet_name = "adm-subnet"
    cidr        = "172.16.1.0/24"
    gateway_ip  = "172.16.1.1"
  }
}

variable "database_network" {
  type = map(string)
  default = {
    subnet_name = "db-subnet"
    cidr        = "192.168.1.0/24"
    gateway_ip  = "192.168.1.1"
  }
}

variable "application_network" {
  type = map(string)
  default = {
    subnet_name = "app-subnet"
    cidr        = "10.50.1.0/24"
    gateway_ip  = "10.50.1.1"
  }
}