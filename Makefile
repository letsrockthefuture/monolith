.PHONY: all
all: get_credentials

get_credentials:
	@echo "Getting Kubernetes Engine cluster credentials..."
	gcloud container clusters get-credentials hash-challenge-kubernetes-engine --zone us-east1-b

clean:
	@echo "Deleting Terraform resources..."
	terraform destroy -auto-approve
