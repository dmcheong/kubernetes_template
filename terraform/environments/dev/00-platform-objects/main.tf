module "argocd_demo_app" {
  source = "../modules/argocd-application"

  name                  = "demo-app"
  namespace             = "argocd"
  repo_url              = "https://github.com/TON_USER/TON_REPO.git"
  target_revision       = "main"
  path                  = "kubernetes/demo-app"
  destination_namespace = "demo-app"

  auto_sync = false
  prune     = false
  self_heal = false
}