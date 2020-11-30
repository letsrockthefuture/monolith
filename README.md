# Monolith

[![Hash][logo]](images/hash.png)

Monolith is a single application that handles /cart and /checkout, and that was developed following the infrastructure standard as code using Terraform.

## Usage

Get the Google Kubernetes Engine cluster credentials:

```bash
make
```

Initializing Terraform and applying it's settings:

```bash
terraform init
terraform apply
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.
