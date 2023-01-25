output "alb_dns_name" {
  value       = module.hello-world-app.alb_dns_name
  description = "The domain name of the load balancer"
}
