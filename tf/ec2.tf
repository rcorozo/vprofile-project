resource "aws_key_pair" "deployer" {
  key_name   = "udemy-devops-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGLqcokPYBQEJQUanKnKame7Zn/ERMnrN+yumcT0XrwXOBArcHin4+uznzn63/gU4QkPmgPHQeQSjmGNhZEyscXgHt2pNju9mzLP9GK/MWpLEYFpzEs2KeNdw0/MU9KxICT8CZJTJQa7qNjy1pOaOg9nU81ml4CABUKVr4LjBr5S/OC6VMQGSembReNGlP2ijfV0Bt5HfdGKm1+YT3LA2Cq2lBqvX5qc+QyutfqKmCrrruCmhTVRQL90Bk8TKLU67zcG8Vs8KtRBysXw1vrEDvfZEe8ZFpnJ1D7fDOqupNFugNcLET2pd2zpvWI+nbsnXGKAZJ8wVw1nLKBc9oYz0v rodericuus@woo"
  tags = {
    Terraform = "true"
  }
}