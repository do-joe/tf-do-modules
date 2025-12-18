terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    docidr = {
      source = "DO-Solutions/docidr"
    }
  }
}


data "digitalocean_kubernetes_versions" "all" {}

data "digitalocean_sizes" "slug_2vcpu_4gb" {
  filter {
    key    = "vcpus"
    values = [2]
  }

  filter {
    key    = "memory"
    values = [4096]
  }

  filter {
    key    = "regions"
    values = [var.region]
  }

  sort {
    key       = "price_monthly"
    direction = "asc"
  }
}


resource "docidr_pool" "network" {
  allocation {
    name          = "doks_cluster"
    prefix_length = 20
  }

  allocation {
    name          = "doks_services"
    prefix_length = 20
  }
}


locals {
  node_slug = var.node_slug != null ? var.node_slug : data.digitalocean_sizes.slug_2vcpu_4gb.sizes[0].slug
  doks_version   = var.doks_version != null ? var.doks_version : data.digitalocean_kubernetes_versions.all.latest_version
}

resource "digitalocean_kubernetes_cluster" "primary" {
  name                             = var.name
  region                           = var.region
  version                          = local.doks_version
  vpc_uuid                         = var.vpc_uuid
  ha                               = var.ha
  cluster_subnet                   = docidr_pool.network.allocations.doks_cluster
  service_subnet                   = docidr_pool.network.allocations.doks_services
  destroy_all_associated_resources = var.destroy_all_associated_resources
  tags                             = var.tags
  routing_agent {
    enabled = var.routing_agent
  }
  registry_integration = var.registry_integration
  node_pool {
    name       = "${var.name}-primary"
    size       = local.node_slug
    min_nodes  = 2
    max_nodes  = 3
    auto_scale = true
    tags       = var.tags
    labels = {
      pool = "primary"
    }
  }
}
