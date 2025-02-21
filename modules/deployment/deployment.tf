# Creates a Kubernetes deployment manifest using a template file
resource "kubectl_manifest" "deployment" {
  yaml_body = templatefile("${path.module}/deployment.yaml.tpl", {
    deployment_name = var.deployment_name
    replicas        = var.replicas
    image          = var.image
    node_selector  = jsonencode(var.node_selector)
  })
}
