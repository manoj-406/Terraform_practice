data "terraform_remote_state" "vpc" {
  backend = "local" 
  config = {
    path = "../vpc/terraform.tfstate"  
  }
}


output "vpc_id" {
  value = data.terraform_remote_state.vpc.outputs.vpc_id
}

output "Public_subnet_ids" {
  value = data.terraform_remote_state.vpc.outputs.Public_subnet_ids
}
