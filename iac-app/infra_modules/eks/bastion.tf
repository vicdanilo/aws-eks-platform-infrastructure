## bastion ##
module "bastion_ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.7"

  name                        = local.bastion_name
  ami                         = data.aws_ami.amazon_linux_ami.id
  instance_type               = "t2.small"
  subnet_id                   = var.subnets[0]
  associate_public_ip_address = false
  disable_api_stop            = false
  root_block_device = [
    {
      encrypted   = false
      volume_type = "gp3"
      throughput  = 125
      volume_size = 50
    },
  ]
  tags                        = local.bastion_tags
  vpc_security_group_ids      = [var.bastion_sg]
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance - ${var.cluster_name}-bastion"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }
}

# module "bastion_security_group" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "~> 5.3"

#   name        = local.bastion_sg
#   description = "Security group for ${var.cluster_name}-bastion host"
#   vpc_id      = var.vpc_id

#   ingress_rules            = ["https-443-tcp"]
#   ingress_cidr_blocks      = ["0.0.0.0/0"]

#   # allow all egress
#   egress_rules = ["all-all"]
#   tags         = var.tags
# }
