# Create a new load balancer
provider "aws" {
region = "us-east-2"
}
#this is a single-line-comment.
resource " aws_instance" "base"{
ami = "ami-0fb653ca2d3203ac1"
instance_type = "t2.micro"
count = "1"
key_name = "${aws_key_pair.keypair.key_name}"
vpc_security_group_ids = {aws_security_group.allow_ports.id}
user_data=<<-EOF 
			#!/bin/bash
			sudo apt-get update -y
			sudo apt-get upgrade  -y
			sudo apt install apache2 -y
EOF
tags = {
	name = "jmsth21_9pm${count.index}"
}
}
 
resource "aws_key_pair" "keypair" {
	key_name = "jmsth21_9pm"
	public_key = "ssh - rsa MIIEpAIBAAKCAQEAxuGKlqvxxqQLROB4ZmoxrtrpspMI2gR9YFCdDG0xQTZ3G0hBE8HKG/JnaMmfRJvgv4Tkjw8nB9k44klzny2s4qHmL8XDDxRtxKJG1iB0aUY13SSmo4GKmwU+gy/maD6xh4UO+RNEJ9SXdsp49fT7nugQkW4gbY/UlAMivzm+Fu2eR20PD2KanAPzudGpWSANIKtOT8K7EFCANOIfof+lF3BF6qwCRqZr3Ob+ZzO/Ih0u76Aqr3ap8dT62FXJZRaHygrfFTU9VDduDwiySLLfZnRiUhYqVgnfY39kxPTKzdmlWhSboQwkz5sZkemrnfrQXykumTrsBUL6oWouNPWWSwIDAQABAoIBAQC1hqNihyq1LoICqgf7Iq6adMGd9sq7hCGTycCu2PN+HGJ2imqrx9Pb0lNEt9MhYk2vQXMEiMYNSd273WMlRSFp8nAR5qX1m6XdNmkFhLX8aNM9N/jJgLGscQrv3salG6Qal/5kpYst98MP8BqcFLGeBx8oPqZmmkNjncEXXXL9pOPTj70lOCZssnTFB/xMAQAVomCcOTxryPQxa7+9POBIU5/0Fw9kAC95grygJBAEKSiZgGPjvdDTCqlxWzRYd37+Wfd5SQ5H1tr4x9lyZCWdK9NLL5s71Ed1ca8y8LBoXd7qEMFTnulRdj2zfUzbRzxp+//r1axVHt/yCiDBzApRAoGBAPWPn+OALT2z/ohPFjpbfoERirnbHudb4VEMdKgcQvxdSSa0nZ/3wkL274muaRk7M6WOkVhBqKpbEXvs7DnXgUJFtdngWfq9EAE5YHVPCW6L0upD87rIyxhEQVm29k4qXwMim0KREf8ivlgEu2mJcUWlrS6fQiQSLegf1ftX2AgNAoGBAM9V6R8ttmeGWOaULn2RONURMlbi0w3t6aRkm7djPYeoTp0CI8RxzEGB8RiGoZRy2gqCqoBGtzPbXCyn9lqZHPbiIRvkTXxco0ZRvxCaUlU13d6z2OJIcGqN71IRh5EZbvqeDM9gPsWG7e35syGT/kzyZuShVV3Cb0Yu6+TSBOm3AoGBAI3PJp/ECtxiUPC483Y6FkFFNx8DysIDToh2r/vRbmG9IZyHm6ug8f+oCUcygKFAjh/iyE72hAf1VZCCjx0MNipmhZFQPcZOXqrGTs0QGrtLZj9BhMRuZtMZv7+mqHEViQ8PcigsDP+ROeksumpFJDP7bJrK//BCy14M3I8s+KYVAoGAMnG7g0ty6qMkNA1vdjuD8Ur6zWroYKY2xzl3LVom2T+YyNiBbUUmpfWAfDAdVenPpOj/pLAP2L0RIwhGhupjwqln1spoE87SJsSy0M5LI9I0Rf/Jz9xCBZq81GHRcvsWJkGX6kiHXTWj49dxvsSsBXqgkBW0mFg7DH9UA1sZuOcCgYBLD2iKATnM2VL2/8eO4zoYpssvjSLexM74SyTLqQRsRuYNjNKq4NEX4QTgFVKnBPqAu3KugjgFDUxT8WaLSRREJkYNSUqYpWYmVIXsHvHt21VwhNMQRe8Gv75GqBhjShU+kOpvQd5Y0wbuujrCA7w9MDu9SIXZciJwR8RefGeVLw ec2-user@ip - 172.31.20.50" 
}
resource "aws_eip" "myeip" {
	count = length (aws_instance.base)
	vpc = true
	instance = "${element(aws_instance.base.*.id,count.index}"

tags ={
	name = "eip-jmsth21_9pm${count.index + 1}"
	}
}

resource "aws_default_vpc" "default" {
	tags = {
	name = "Default VPC"
  }
}
resource " aws_security_group" "allow_ports" {
	name = "alb"
	descriptoion = "allow inbound traffice"
	vpc_id = "${aws_default_vpc.default.id}"
	ingress {
	descriptoion = "http from VPC"
	from_port = 80
	to_port = 80
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
	descriptoion = "TSL from Vpc"
	from_port = 443
	to_port = 443
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }
	
	egress {
	from_port = 0
	to_port = 0
	protocol = "-1"
	cidr_blocks = ["0.0.0.0/0"]
	}
	tags = {
		name = "allow_ports"
	}
}
data "aws_subnet_ids" "subnet" {
	vpc_id = "${aws_default_vpc.default.id}"
	
}
resource = ="aws_lb_target_group" "my_target_group" {
	health_check {
	interval = 10
	path = "/"
	protocol = "HTTP"
	timeout = 5
	healthy_threshold = 5
	unhealthy_threshhold = 2
  }

	name = "my-test-tg"
	port - 80
	protocol = "HTTP"
	target_type = "instance"
	vpc_id = "${aws_default_vpc.default.id}"
}
	
resource "aws_lb" "my-aws-alb {
	name = "jmsth-test-alb"
	internal = false
	security_group = [
	"${aws_security_group.allow_ports.id}",
	]
	
	subnets = data.aws_subnet_ids.subnets.ids
	tags = {
	name = "jmsth-test-alb"
   }
	
	ip_address_type = "ipv4"
	load_balncer_type = "application"
}

resource "aws_lb_listener" "jmsth-test-alb_listener"

load_balncer_arn = aws_lb.my-aws.alb.arn
	port = 80
	protocol = "HTTP"
	default_action {
	target_group_arn = "${aws_lb_target_group.my-target-group.arn}"
	type = "forward"
	}
}
resource "aws_alb_target_group_attachment" "ec2_attach" {
	count = length(aws_instance.base)
	target_group_arn = aws_lb_target_group.my-target-group.arn
	target_id = aws_instance.base[count.index].id
}
	
