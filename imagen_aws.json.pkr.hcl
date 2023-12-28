
packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


source "amazon-ebs" "autogenerated_1" {
  ami_name          = "ubuntu-nginx-project-4"
  instance_type     = "t2.micro"
  region            = "us-east-1"
  source_ami        = "ami-0c7217cdde317cfec"
  ssh_username      = "ubuntu"
  security_group_id = "sg-0c0880de6d5a631fd"
  subnet_id         = "subnet-0f70f2c24130bee4d"
  vpc_id            = "vpc-0ff67119a441f99e2"
}

build {
  name    = "DevOps-packer"
  sources = ["source.amazon-ebs.autogenerated_1"]

  provisioner "file" {
    source      = "public"
    destination = "/home/ubuntu/"
  }

  provisioner "shell" {
    script = "provision.sh"
  }
  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
    custom_data = {
      my_custom_data = "example"
    }
  }


}
