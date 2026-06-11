namespace_name = "platform"
environment    = "local"
managed_by     = "terraform"

#########################################
# KONG
#########################################

kong_enabled       = true
kong_namespace     = "kong"
kong_chart_version = "2.51.0"

#########################################
# POSTGRESQL
#########################################

postgresql_enabled       = true
postgresql_namespace     = "database"
postgresql_release_name  = "postgresql"
postgresql_chart_version = "18.7.0"
postgresql_database_name = "kong"
postgresql_username      = "kong"
postgresql_password      = "kong_password_local"

#########################################
# KONG - POSTGRESQL
#########################################

kong_database    = "postgres"
kong_pg_host     = "postgresql.database.svc.cluster.local"
kong_pg_database = "kong"
kong_pg_user     = "kong"
kong_pg_password = "kong_password_local"