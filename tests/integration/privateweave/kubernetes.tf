resource "aws_autoscaling_attachment" "bastion-privateweave-example-com" {
  elb = "${aws_elb.bastion-privateweave-example-com.id}"
  autoscaling_group_name = "${aws_autoscaling_group.bastion-privateweave-example-com.id}"
}

resource "aws_autoscaling_attachment" "master-us-test-1a-masters-privateweave-example-com" {
  elb = "${aws_elb.api-privateweave-example-com.id}"
  autoscaling_group_name = "${aws_autoscaling_group.master-us-test-1a-masters-privateweave-example-com.id}"
}

resource "aws_autoscaling_group" "bastion-privateweave-example-com" {
  name = "bastion.privateweave.example.com"
  launch_configuration = "${aws_launch_configuration.bastion-privateweave-example-com.id}"
  max_size = 1
  min_size = 1
  vpc_zone_identifier = ["${aws_subnet.private-us-test-1a-privateweave-example-com.id}"]
  tag = {
    key = "KubernetesCluster"
    value = "privateweave.example.com"
    propagate_at_launch = true
  }
  tag = {
    key = "Name"
    value = "bastion.privateweave.example.com"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "master-us-test-1a-masters-privateweave-example-com" {
  name = "master-us-test-1a.masters.privateweave.example.com"
  launch_configuration = "${aws_launch_configuration.master-us-test-1a-masters-privateweave-example-com.id}"
  max_size = 1
  min_size = 1
  vpc_zone_identifier = ["${aws_subnet.private-us-test-1a-privateweave-example-com.id}"]
  tag = {
    key = "KubernetesCluster"
    value = "privateweave.example.com"
    propagate_at_launch = true
  }
  tag = {
    key = "Name"
    value = "master-us-test-1a.masters.privateweave.example.com"
    propagate_at_launch = true
  }
  tag = {
    key = "k8s.io/role/master"
    value = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nodes-privateweave-example-com" {
  name = "nodes.privateweave.example.com"
  launch_configuration = "${aws_launch_configuration.nodes-privateweave-example-com.id}"
  max_size = 2
  min_size = 2
  vpc_zone_identifier = ["${aws_subnet.private-us-test-1a-privateweave-example-com.id}"]
  tag = {
    key = "KubernetesCluster"
    value = "privateweave.example.com"
    propagate_at_launch = true
  }
  tag = {
    key = "Name"
    value = "nodes.privateweave.example.com"
    propagate_at_launch = true
  }
  tag = {
    key = "k8s.io/role/node"
    value = "1"
    propagate_at_launch = true
  }
}

resource "aws_ebs_volume" "us-test-1a-etcd-events-privateweave-example-com" {
  availability_zone = "us-test-1a"
  size = 20
  type = "gp2"
  encrypted = false
  tags = {
    KubernetesCluster = "privateweave.example.com"
    Name = "us-test-1a.etcd-events.privateweave.example.com"
    "k8s.io/etcd/events" = "us-test-1a/us-test-1a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "us-test-1a-etcd-main-privateweave-example-com" {
  availability_zone = "us-test-1a"
  size = 20
  type = "gp2"
  encrypted = false
  tags = {
    KubernetesCluster = "privateweave.example.com"
    Name = "us-test-1a.etcd-main.privateweave.example.com"
    "k8s.io/etcd/main" = "us-test-1a/us-test-1a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_eip" "us-test-1a-privateweave-example-com" {
  vpc = true
}

resource "aws_elb" "api-privateweave-example-com" {
  name = "api-privateweave"
  listener = {
    instance_port = 443
    instance_protocol = "TCP"
    lb_port = 443
    lb_protocol = "TCP"
  }
  security_groups = ["${aws_security_group.api-elb-privateweave-example-com.id}"]
  subnets = ["${aws_subnet.utility-us-test-1a-privateweave-example-com.id}"]
  health_check = {
    target = "TCP:443"
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 10
    timeout = 5
  }
}

resource "aws_elb" "bastion-privateweave-example-com" {
  name = "bastion-privateweave"
  listener = {
    instance_port = 22
    instance_protocol = "TCP"
    lb_port = 22
    lb_protocol = "TCP"
  }
  security_groups = ["${aws_security_group.bastion-elb-privateweave-example-com.id}"]
  subnets = ["${aws_subnet.utility-us-test-1a-privateweave-example-com.id}"]
  health_check = {
    target = 
    healthy_threshold = 
    unhealthy_threshold = 
    interval = 
    timeout = 
  }
}

resource "aws_iam_instance_profile" "masters-privateweave-example-com" {
  name = "masters.privateweave.example.com"
  roles = ["${aws_iam_role.masters-privateweave-example-com.name}"]
}

resource "aws_iam_instance_profile" "nodes-privateweave-example-com" {
  name = "nodes.privateweave.example.com"
  roles = ["${aws_iam_role.nodes-privateweave-example-com.name}"]
}

resource "aws_iam_role" "masters-privateweave-example-com" {
  name = "masters.privateweave.example.com"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.privateweave.example.com_policy")}"
}

resource "aws_iam_role" "nodes-privateweave-example-com" {
  name = "nodes.privateweave.example.com"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.privateweave.example.com_policy")}"
}

resource "aws_iam_role_policy" "masters-privateweave-example-com" {
  name = "masters.privateweave.example.com"
  role = "${aws_iam_role.masters-privateweave-example-com.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.privateweave.example.com_policy")}"
}

resource "aws_iam_role_policy" "nodes-privateweave-example-com" {
  name = "nodes.privateweave.example.com"
  role = "${aws_iam_role.nodes-privateweave-example-com.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.privateweave.example.com_policy")}"
}

resource "aws_internet_gateway" "privateweave-example-com" {
  vpc_id = "${aws_vpc.privateweave-example-com.id}"
  tags = {
    KubernetesCluster = "privateweave.example.com"
    Name = "privateweave.example.com"
  }
}

resource "aws_key_pair" "kubernetes-privateweave-example-com-c4a6ed9aa889b9e2c39cd663eb9c7157" {
  key_name = "kubernetes.privateweave.example.com-c4:a6:ed:9a:a8:89:b9:e2:c3:9c:d6:63:eb:9c:71:57"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.privateweave.example.com-c4a6ed9aa889b9e2c39cd663eb9c7157_public_key")}"
}

resource "aws_launch_configuration" "bastion-privateweave-example-com" {
  name_prefix = "bastion.privateweave.example.com-"
  image_id = "ami-12345678"
  instance_type = "t2.medium"
  key_name = "${aws_key_pair.kubernetes-privateweave-example-com-c4a6ed9aa889b9e2c39cd663eb9c7157.id}"
  iam_instance_profile = "${aws_iam_instance_profile.masters-privateweave-example-com.id}"
  security_groups = ["${aws_security_group.bastion-privateweave-example-com.id}"]
  associate_public_ip_address = false
  root_block_device = {
    volume_type = "gp2"
    volume_size = 20
    delete_on_termination = true
  }
  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "master-us-test-1a-masters-privateweave-example-com" {
  name_prefix = "master-us-test-1a.masters.privateweave.example.com-"
  image_id = "ami-12345678"
  instance_type = "m3.medium"
  key_name = "${aws_key_pair.kubernetes-privateweave-example-com-c4a6ed9aa889b9e2c39cd663eb9c7157.id}"
  iam_instance_profile = "${aws_iam_instance_profile.masters-privateweave-example-com.id}"
  security_groups = ["${aws_security_group.masters-privateweave-example-com.id}"]
  associate_public_ip_address = false
  user_data = "${file("${path.module}/data/aws_launch_configuration_master-us-test-1a.masters.privateweave.example.com_user_data")}"
  root_block_device = {
    volume_type = "gp2"
    volume_size = 20
    delete_on_termination = true
  }
  ephemeral_block_device = {
    device_name = "/dev/sdc"
    virtual_name = "ephemeral0"
  }
  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "nodes-privateweave-example-com" {
  name_prefix = "nodes.privateweave.example.com-"
  image_id = "ami-12345678"
  instance_type = "t2.medium"
  key_name = "${aws_key_pair.kubernetes-privateweave-example-com-c4a6ed9aa889b9e2c39cd663eb9c7157.id}"
  iam_instance_profile = "${aws_iam_instance_profile.nodes-privateweave-example-com.id}"
  security_groups = ["${aws_security_group.nodes-privateweave-example-com.id}"]
  associate_public_ip_address = false
  user_data = "${file("${path.module}/data/aws_launch_configuration_nodes.privateweave.example.com_user_data")}"
  root_block_device = {
    volume_type = "gp2"
    volume_size = 20
    delete_on_termination = true
  }
  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "us-test-1a-privateweave-example-com" {
  allocation_id = "${aws_eip.us-test-1a-privateweave-example-com.id}"
  subnet_id = "${aws_subnet.utility-us-test-1a-privateweave-example-com.id}"
}

resource "aws_route" "private-us-test-1a-privateweave-example-com" {
  route_table_id = "${aws_route_table.private-us-test-1a-privateweave-example-com.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.us-test-1a-privateweave-example-com.id}"
}

resource "aws_route" "wan" {
  route_table_id = "${aws_route_table.main-privateweave-example-com.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.privateweave-example-com.id}"
}

resource "aws_route53_record" "api-privateweave-example-com" {
  name = "api.privateweave.example.com"
  type = "A"
  alias = {
    name = "${aws_elb.api-privateweave-example-com.dns_name}"
    zone_id = "${aws_elb.api-privateweave-example-com.zone_id}"
    evaluate_target_health = false
  }
  zone_id = "/hostedzone/Z1AFAKE1ZON3YO"
}

resource "aws_route_table" "main-privateweave-example-com" {
  vpc_id = "${aws_vpc.privateweave-example-com.id}"
  tags = {
    KubernetesCluster = "privateweave.example.com"
    Name = "main-privateweave.example.com"
  }
}

resource "aws_route_table" "private-us-test-1a-privateweave-example-com" {
  vpc_id = "${aws_vpc.privateweave-example-com.id}"
  tags = {
    KubernetesCluster = "privateweave.example.com"
    Name = "private-us-test-1a.privateweave.example.com"
  }
}

resource "aws_route_table_association" "main-us-test-1a-privateweave-example-com" {
  subnet_id = "${aws_subnet.utility-us-test-1a-privateweave-example-com.id}"
  route_table_id = "${aws_route_table.main-privateweave-example-com.id}"
}

resource "aws_route_table_association" "private-us-test-1a-privateweave-example-com" {
  subnet_id = "${aws_subnet.private-us-test-1a-privateweave-example-com.id}"
  route_table_id = "${aws_route_table.private-us-test-1a-privateweave-example-com.id}"
}

resource "aws_security_group" "api-elb-privateweave-example-com" {
  name = "api-elb.privateweave.example.com"
  vpc_id = "${aws_vpc.privateweave-example-com.id}"
  description = "Security group for api ELB"
  tags = {
    KubernetesCluster = "privateweave.example.com"
    Name = "api-elb.privateweave.example.com"
  }
}

resource "aws_security_group" "bastion-elb-privateweave-example-com" {
  name = "bastion-elb.privateweave.example.com"
  vpc_id = "${aws_vpc.privateweave-example-com.id}"
  description = "Security group for bastion ELB"
  tags = {
    KubernetesCluster = "privateweave.example.com"
    Name = "bastion-elb.privateweave.example.com"
  }
}

resource "aws_security_group" "bastion-privateweave-example-com" {
  name = "bastion.privateweave.example.com"
  vpc_id = "${aws_vpc.privateweave-example-com.id}"
  description = "Security group for bastion"
  tags = {
    KubernetesCluster = "privateweave.example.com"
    Name = "bastion.privateweave.example.com"
  }
}

resource "aws_security_group" "masters-privateweave-example-com" {
  name = "masters.privateweave.example.com"
  vpc_id = "${aws_vpc.privateweave-example-com.id}"
  description = "Security group for masters"
  tags = {
    KubernetesCluster = "privateweave.example.com"
    Name = "masters.privateweave.example.com"
  }
}

resource "aws_security_group" "nodes-privateweave-example-com" {
  name = "nodes.privateweave.example.com"
  vpc_id = "${aws_vpc.privateweave-example-com.id}"
  description = "Security group for nodes"
  tags = {
    KubernetesCluster = "privateweave.example.com"
    Name = "nodes.privateweave.example.com"
  }
}

resource "aws_security_group_rule" "all-bastion-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes-privateweave-example-com.id}"
  source_security_group_id = "${aws_security_group.bastion-privateweave-example-com.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "all-master-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-privateweave-example-com.id}"
  source_security_group_id = "${aws_security_group.masters-privateweave-example-com.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes-privateweave-example-com.id}"
  source_security_group_id = "${aws_security_group.masters-privateweave-example-com.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "all-node-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-privateweave-example-com.id}"
  source_security_group_id = "${aws_security_group.nodes-privateweave-example-com.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes-privateweave-example-com.id}"
  source_security_group_id = "${aws_security_group.nodes-privateweave-example-com.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "api-elb-egress" {
  type = "egress"
  security_group_id = "${aws_security_group.api-elb-privateweave-example-com.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion-egress" {
  type = "egress"
  security_group_id = "${aws_security_group.nodes-privateweave-example-com.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion-elb-egress" {
  type = "egress"
  security_group_id = "${aws_security_group.bastion-elb-privateweave-example-com.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-privateweave-example-com.id}"
  source_security_group_id = "${aws_security_group.bastion-privateweave-example-com.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "https-api-elb" {
  type = "ingress"
  security_group_id = "${aws_security_group.api-elb-privateweave-example-com.id}"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "kube-proxy-api-elb" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-privateweave-example-com.id}"
  source_security_group_id = "${aws_security_group.api-elb-privateweave-example-com.id}"
  from_port = 443
  to_port = 443
  protocol = "tcp"
}

resource "aws_security_group_rule" "master-egress" {
  type = "egress"
  security_group_id = "${aws_security_group.masters-privateweave-example-com.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type = "egress"
  security_group_id = "${aws_security_group.nodes-privateweave-example-com.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-bastion" {
  type = "ingress"
  security_group_id = "${aws_security_group.bastion-privateweave-example-com.id}"
  source_security_group_id = "${aws_security_group.bastion-elb-privateweave-example-com.id}"
  from_port = 22
  to_port = 22
  protocol = "tcp"
}

resource "aws_security_group_rule" "ssh-external-to-bastion-elb" {
  type = "ingress"
  security_group_id = "${aws_security_group.bastion-elb-privateweave-example-com.id}"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_subnet" "private-us-test-1a-privateweave-example-com" {
  vpc_id = "${aws_vpc.privateweave-example-com.id}"
  cidr_block = "172.20.4.0/22"
  availability_zone = "us-test-1a"
  tags = {
    KubernetesCluster = "privateweave.example.com"
    Name = "private-us-test-1a.privateweave.example.com"
  }
}

resource "aws_subnet" "utility-us-test-1a-privateweave-example-com" {
  vpc_id = "${aws_vpc.privateweave-example-com.id}"
  cidr_block = "172.20.32.0/19"
  availability_zone = "us-test-1a"
  tags = {
    KubernetesCluster = "privateweave.example.com"
    Name = "utility-us-test-1a.privateweave.example.com"
  }
}

resource "aws_vpc" "privateweave-example-com" {
  cidr_block = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    KubernetesCluster = "privateweave.example.com"
    Name = "privateweave.example.com"
  }
}

resource "aws_vpc_dhcp_options" "privateweave-example-com" {
  domain_name = "us-test-1.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = {
    KubernetesCluster = "privateweave.example.com"
    Name = "privateweave.example.com"
  }
}

resource "aws_vpc_dhcp_options_association" "privateweave-example-com" {
  vpc_id = "${aws_vpc.privateweave-example-com.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.privateweave-example-com.id}"
}