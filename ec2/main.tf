resource "aws_instance" "toy_store" {
    ami = var.aws_instance.ami
    tags = var.aws_instance.tags
    instance_type = var.aws_instance.instance_type
    key_name = var.aws_instance.key_name
    subnet_id = data.terraform_remote_state.vpc.outputs.Public_subnet_ids[0]
#    security_groups = var.aws_instance.security_groups

}
