# iac-module-template

## Description

This is a template project for creating Terraform Infrastructure as Code (IaC) modules. It provides a standardized structure with GitHub configurations and AI agent integrations to accelerate module development and deployment.

## Usage

This section includes a code snippet to import the module

```hcl
module "resource_name" {
  source = "./modules/module_name"

  ...variables
}

# Output: xxx
```

## Variables

| Nom     | Type   | Default ? | Description                   |
|---------|--------|-----------|-------------------------------|
| exemple | string | "test"    | variable's description        |

## Outputs

| Nom     | Description                   |
|---------|-------------------------------|
| exemple | variable's description        |
