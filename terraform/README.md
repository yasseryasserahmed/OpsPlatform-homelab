# Terraform

## Layout

- `environments/lab/` is the deployable lab configuration and owns its state.
  It composes modules and defines the lab EC2 instance.
- `modules/network/` creates the lab VPC, public subnet, routing, Internet
  Gateway, and SSH-restricted security group.

The EC2 instance stays in the environment while there is only one instance.
Extract it into a module when another environment or multiple instances need
the same configurable implementation.

