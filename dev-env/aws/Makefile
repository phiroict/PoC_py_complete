infra_pre_build:
	cd terraform && terraform init &&   aws-vault exec home -- terraform plan -out plan.plan && aws-vault exec home -- terraform apply plan.plan
	cd terraform && echo $(aws-vault exec home -- terraform output) > ../echo.sh
	# sed -e 's/^/export /g' -i echo.sh
infra_teardown:
	cd terraform && aws-vault exec home -- terraform destroy
build_pre_image:
	cd packer && packer init . && aws-vault exec home -- packer build -var aws_subnet=$(shell cd terraform && aws-vault exec home -- terraform output aws_subnet) -var aws_vpc=$(shell cd terraform &&  aws-vault exec home -- terraform output aws_vpc) .