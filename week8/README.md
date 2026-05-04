# Week 8 Assignment: GCP & Terraform

-- Q & A --
This assignment is GCP focused but concepts are cloud agnostic. I believe these are foundational topics to keep in mind and have been useful to me post/prior to acquiring my AWS SAA, GCP PCSE & Terraform Associate certs.

**High Availability(HA)** revolves around being able to access resources at any point in time. You can think of it like living solo vs living in a family home with multiple siblings since when it comes to the bathroom it's 1st come 1st served. 

**Fault Tolerance(FT)** revolves around the minimizing the ability of a system to be taken down. You can think of it like pulling a plug will take down the system so you treat the plug like a Russian Stacking Doll and make it difficult for one accidental detachment to cause your system to become unavailable. It's also best to strive for HA.

**Autoscaling** is the automatic increase/decrease of VMs to meet demands while **elasticity** is the ability of system to automatically change it's compute resources to match a changing workload. You can think of it like a cruise control on your car since it remains consist on flat terrain, but going up a hill requires more gas & speed(resources) while going down a hill would require less. 

**Vertical Scaling AKA Scaling Up/Down** relates to adding(scaling up) or removing resources(scaling down) from a single server or machine. Scaling up is similar to adding physical components like memory to meet demand while scaling down would imply that you would be removing resources once demand has ceased. This method allows you to handle the increase in demand by basically increasing the resources.

**Horizontal Scaling AKA scaling Out/In** relates to increasing the number of machines or nodes in a system to distribute the workload. This method allows you to handle the increase in demand by basically increasing the workers. Horizontal Scaling is generally the better option since in the long run since there is only so much vertical scaling that can added while horizontal scaling technically creates more workers which also comes with their own resources. These solutions are both feasible on prem for smaller sized companies but it's a better option to use cloud based solutions since they can be more cost efficient + allow for elasticity which wins in the long run.

**Application Based Health Checks** are useful in scenarios when you want to both verify that an VM is running + also verify that the App is running as well. 

**Load Balancer Health Checks** is useful when the LB is deciding where to distribute traffic to in an MIG. They serve different purposes and are associated with different resources and should be used alongside each other to increase HA and decrease FT. They are different API calls and doing so is best since it allows you to distinguish between the two and also troubleshoot.

**3-Tier architecture** generally refers to a Web, App, and DB layered approach that represents the main components of your design. This relates to what I've been learning since best practices for designing the layout requires you to understand and incorporate concepts and services associated with HA, FT, LB's, MIGs, and ect. These concepts when used correctly keep the apps up and running.

**Managed Instance Groups (MIGs)** offer the following advantages:
1. **High availability**: 
    - Automatically recreates failed Instances based on it's originally config as i.e. one or more instance(s) is terminated and one instance(s) is created.
    - App-based autoscaling uses health checks to verify that an app responds as expected on each MIG instances. Unresponsible VM's are replaced and this process is a step above a simple VM Health check since it can also verify that the VM is running & also the app is running.
    - Regional(multiple zone coverage) allows you to spreads app load across multiple zones instead of keeping them contained in one zone which can be problematic since failure of the zone would take out your vm/app. Using multiple zones reduces the chances of a single point in failure being the reason your vm/app crashes.
    - Load balancing distributes traffic across all of the instances in the group so it prevents traffic from being directed to a single instance and separates the flow of traffic to multiple instances to prevent stress to a single instance.
2. **Scalability**: allows you to adjust the compute resources a MIG can use automatically meeting demands so when demands are higher there will be an automated increase while when demands are lower the opposite takes place to reduce costs.

---

### Runbook: Managed Instance Group (MIG) Deployment

**The Goal:** The objective is to deploy a fleet of self-healing, identical virtual machines that automatically scale based on user demand. By the end of this guide, you will have a resilient application layer that can survive the failure of an entire physical data center.

**Runbook:**
1. Inside of GCP type "launch template" in the search bar. 
2. Select Create Instance Template.
3. Name the template i.e My-Test-Instance-Template.
4. Locate "Firewall"(you can use ctrl + f) & select Allow HTTP traffic.
5. Select the dropdown for Advanced options, Select the dropdown for Mangement, and location the section for Automation(startup script) & paste your script i.e. [https://github.com/BalericaAI/SEIR-1/blob/main/weekly_lessons/weeka/userscripts/supera.sh](https://github.com/BalericaAI/SEIR-1/blob/main/weekly_lessons/weeka/userscripts/supera.sh).
6. Select Create and wait for creation/completion.
7. Next select Instance Groups + Create Instance Group.
8. Provide a name or use the default name.
9. Select Instance template and choose your newly created instance template.
10. Number of instances choose 4.
11. Location: choose Multiple zones for HA and Fault Tolerance. Choosing multiple zones lets you know that instance groups will be managed across multiple zones the while single zone will only be managed for a single zone.
12. Autoscaling: Review the instance group you've created and select configure for the Autoscaling(should say not configured). Select Configure Autoscaling + change settings to Minimum number of instances default settings are fine for testing.
13. Autohealing: Select Health check + Create health check.
14. Provide a name i.e. my-health-check + Scope can be changed to regional + Logs On, and Save.
15. Select Create to create the Instance Group.
* Autohealing + health checks with logs enabled allows you to monitor the status of your application beyond just verifying the server is running and assists with troubleshooting as well as replacement of instances.

**Verification & Critical Configs:**
- **Multi-Zone Distribution:** By selecting "Multiple Zones," you ensure that if `us-central1-a` goes dark, your application stays alive in `us-central1-b` and `us-central1-c`.
- **The "Pulse" (Health Checks):** We use a Health Check with logs enabled so the system can automatically replace "zombie" instances—VMs that are powered on but whose internal application has crashed.
- **Testing:** To verify, you can manually delete one VM from the group; within minutes, the MIG will detect the loss and spin up a replacement automatically.
- There are several default settings that have explanations included that should be reviewed.

---

### Terraform: How to Output VM IP Addresses

**The "How":** To display the IPs, you use an `output` block that drills into the `network_interface` attribute of the VM. Since GCP hides the External IP inside the configuration for the network card, you have to follow the path all the way down to `nat_ip`.

```hcl
# Internal IP
output "internal_ip" {
  value = google_compute_instance.hw_vm.network_interface.0.network_ip
}

# External IP
output "external_ip" {
  value = google_compute_instance.hw_vm.network_interface.0.access_config.0.nat_ip
}
```

[google_compute_instance Attributes Reference](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#attributes-reference) to locate the **Attributes Reference** section, which lists exactly how these values are nested. I also cross-referenced a [HashiCorp Tutorial](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-outputs) and community discussions on [Reddit](https://www.reddit.com/r/Terraform/comments/rd8mx0/how_to_get_external_ip_address_that_google_cloud/) to confirm that the `.0` index is required because Terraform treats network interfaces as a list, even if there is only one card.

**2 Non-required Args:**
* Using `metadata_startup_script` runs a `gsutil cp gs://your-bucket/playbook.yml .` command to pull your files from a bucket would allow you point the userdata at a bucket which can be automatically updated via ci/cd instead of having to run a terraform apply to update your app.
* A Bastion host is secured by a [google_compute_firewall](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) resource that uses the "source_ranges" argument to whitelist only your specific public IP address. I used a similar setup of bastion with ansible + playbooks stored in a bucket to automate the process of updating running vm's(using the bastion) + vm's that were created from autoscaling(using the ansible playbooks stored in a bucket.

**Determining correct format for VM image:** To find the correct format, navigate to the **[OS and storage](https://console.cloud.google.com/compute/instancesAdd)** section in the "Create an instance" menu and click **Change**. Select **CentOS** from the "Operating System" dropdown and **CentOS Stream 10** from the "Version" list.

**Terraform Resource Attributes:**
- **Name:** There are two names: one for Terraform (the resource label `vm`) and one for GCP (the `name` argument `cameron-hw-vm`).

```hcl
# "vm" is the Terraform Label (Nickname)
resource "google_compute_instance" "vm" {
  # "cameron-hw-vm" is the real GCP Name
  name         = "cameron-hw-vm" 
  zone         = "us-central1-f"
  machine_type = "n2-standard-2"
}

output "vm_attributes" {
  value = {
    name      = google_compute_instance.vm.name
    id        = google_compute_instance.vm.instance_id
    self_link = google_compute_instance.vm.self_link
  }
}

```

- **ID (Computed):** A unique, permanent system-generated number assigned by Google to track the specific life of that hardware.
- **Self_link:** The full API URL address used by other GCP services to find and "talk" to this specific resource.

### How I figured this out
I used the [google_compute_instance Attributes Reference](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#attributes-reference) to see which values are provided by the user and which are exported by the provider after the VM is created.

---

### BONUS: Creating a single instance
**Creating single instances:**
1. Next select VM Instances(left panel under Virtual Machines or type in Virtual Instances in the search bar).
2. Select Create VM from(should be located at the top), select instance templates, and then choose your newly created instance template + Create.
3. Verify connectivity via SSH - Select SSH for the newly created VM Instance + Authorize, and then run ping 8.8.8.8(ctrl + c to cancel). Exit out once you've verified packets transmitted are successful i.e. 5 packets transmitted, 5 received, 0% packet loss, time 4092ms.
4. Select External IP(should be located on VM Instances near SSH) + Continue to site if prompted to view a successful deployment.

### references
* [https://docs.cloud.google.com/compute/docs/instance-groups#managed_instance_groups](https://docs.cloud.google.com/compute/docs/instance-groups#managed_instance_groups) used for MIG, HA, Autoscaling, Scalability, Health Checking.
* [https://cloud.google.com/discover/what-is-cloud-scalability](https://cloud.google.com/discover/what-is-cloud-scalability) used for autoscaling vertical/horizontal definitions.
* [https://docs.cloud.google.com/architecture/infra-reliability-guide/design](https://docs.cloud.google.com/architecture/infra-reliability-guide/design) for single point of failure & GCP lists this link for the definition of a single point of failure on wikipedia: [https://en.wikipedia.org/wiki/Single_point_of_failure](https://en.wikipedia.org/wiki/Single_point_of_failure)
* [https://cloud.google.com/discover/what-is-cloud-elasticity](https://cloud.google.com/discover/what-is-cloud-elasticity) reference for elastic definition
