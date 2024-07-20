provider "aws" {
  region = "us-east-1" # Substitua pela sua região
}

module "roles" {
  source = "./roles"
}

module "my-eks-vpc" {
  source = "./my-eks-vpc"
  
  depends_on = [module.roles]

}

module "eks-cluster" {
  source = "./eks-cluster"

  depends_on = [module.roles,module.my-eks-vpc]

}