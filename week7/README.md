This lab reflects a GCP deployment of a baisc vpc + a file + output of the network name.
I used the Terraform Registry as a reference to create the vpc, local_file, outputs, and providers resources. 
Terraform Registry is constantly being updated so issues faced usually revolve around navigation and searching 
,but become easier once you get the hang of searching for specific resources and understanding how to the registry/community stores it data.

Reference links:
1. [Used to create the basic vpc resource + tags]
(https://registry.terraform.io/modules/terraform-google-modules/network/google/latest/submodules/vpc)

2. [Used for example usage of a local_file resource]
(https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file)

3. [Used to create the providers resource]
(https://registry.terraform.io/providers/hashicorp/google/latest/docs & Used to reference the correct verison + formatting)
[b.](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_versions)

4. [Used to output the network/vpc name]
(https://github.com/terraform-google-modules/terraform-google-network/blob/main/outputs.tf & [Used to verify the correct output value "network_name"]
(https://registry.terraform.io/modules/terraform-google-modules/network/google/latest/submodules/vpc?tab=outputs)

