output "load_balancer_ip" {
  value = kubernetes_service.monolith_service.load_balancer_ingress.0.ip
}
