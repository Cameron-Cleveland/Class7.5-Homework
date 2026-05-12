---

# Week 9: GCP Cloud Infrastructure & Networking

## ## Q&A Section

### **Load Balancers**

Load-Balancers contribute to fault tolerance by relaunching instances that fail health checks and also redirecting traffic when required. LB provide resiliency which is an enemy of fault tolerance/high availability in GCP since provides you with multiple solutions for monitoring running instances health status and guiding traffic to functional instances.

* [Google Cloud Global External HTTP(S) Load Balancer Deep Dive](https://cloud.google.com/blog/topics/developers-practitioners/google-cloud-global-external-https-load-balancer-deep-dive)

Latency is reduced using a Global LB since traffic remains in Google's private network instead of being passed over multiple ISPs to from user to destination.

Health checks help you identify healthy running instances and troubleshoot as well. Health checks aren't always needed but are implemented for best practice.

Reverse Proxies work as part of the load balancing step when requests are made to web apps or services. You can think of reverse proxies like a traffic cop directing cars through a private intersection that requires certain rules and conditions to be met for access.

* [Zero Trust Reverse Proxy](https://cloud.google.com/blog/topics/developers-practitioners/zero-trust-reverse-proxy/)

URL map and Routing rules are used to direct traffic and requests to the proper destination.

Anycast IP addresses are used to direct traffic to healthy instances. They act as the "home address". The process is similar to a delivery going to a single mailbox while the package could belong to any resident of the home the delivery goes to a single location and is sorted after delivery.

---

### **🛡️ Cloud Armor**

**What does Cloud Armor offer?** It’s a security shield that provides **DDoS protection** and a **Web Application Firewall (WAF)** to block malicious traffic at the edge of Google’s network. [Google Cloud Armor Overview](https://cloud.google.com/security/products/armor)

**Why is it used in the first place?** To stop "bad" requests (like hackers or bots) from crashing your site, stealing data, or spiking your cloud bill. It keeps the app fast and available for real users. [When should I use Cloud Armor?](https://cloud.google.com/blog/topics/developers-practitioners/when-should-i-use-cloud-armor)

**What layer in the OSI model does it operate at?** It works at **Layer 7 (Application)** and **Layer 3/4 (Network)**.

* **Why it matters:** Layer 7 let's it "read" the traffic to find hidden attacks like SQL injections.
* **VS VPC Rules:** VPC rules only check "ID cards" (IP/Port). [Cloud Armor](https://docs.cloud.google.com/armor/docs/cloud-armor-overview) actually "opens the bags" to inspect the data inside.

**What are rate-based rules for?** They act as a speed limit. If a bot tries to guess a password 500 times a second, [Rate Limiting](https://cloud.google.com/security/products/armor) triggers to shut them down instantly.

**What is reCAPTCHA and how does it relate to this service?** It’s the "I am not a robot" test. [reCAPTCHA Enterprise](https://cloud.google.com/security/products/armor) integrates with Armor to challenge suspicious visitors before they can reach your backend.

---

### **🚀 Cloud CDN**

**What are POPs used for?** POPs (Points of Presence) are globally distributed edge locations used to cache content. Think of it like meal prepping for the month and storing your food in a deep freezer—POPs store copies of your data closer to users so they don't have to wait for a "fresh" response from the main server every time.

**What kind of files are served with Cloud CDN?** Files stored with Cloud CDN are both static and dynamic. These are used in everyday apps like Gmail, Maps, YouTube, gaming, and more to make sure images, scripts, and videos load instantly.

**What services can be used with Cloud CDN for the source of content (the origin)?** You can pull content from several sources:

* Cloud Storage buckets
* Compute Engine VMs
* Google Kubernetes Engine (GKE) backends
* External origins (like on-prem servers or other clouds)

**Does Cloud CDN help protect against any types of malicious actors or cyberattacks? Explain.** Yes. It acts as a frontline defense by integrating with Cloud Armor to block threats. Because the CDN sits at the "edge," it also helps absorb DDoS attacks, meaning the massive flood of fake traffic hits Google's global network instead of crashing your actual server.

**Should an enterprise always use cloud CDN? Why or why not?** Not always, but usually. It is a "yes" if you have a global audience and want to lower costs and latency. It might be a "no" if your users are all in one local office or if your content changes so fast that it can never actually be saved in a cache.

**What is TTL and how does it control content “freshness”?** TTL (Time to Live) is a timer for your cached data. It tells the CDN exactly how long to keep a "meal" in the freezer before it’s considered too old. Once the timer runs out, the CDN throws out the old copy and grabs a fresh one from the source.

---

### **References**

* [Cloud CDN Overview](https://cloud.google.com/cdn/docs/overview)
* [Cloud CDN Product Highlights](https://cloud.google.com/cdn)
* [What is Google Cloud CDN?](https://www.geeksforgeeks.org/cloud-computing/what-is-google-cloud-cdn/)
* [Cloud CDN Security & Armor Integration](https://cloud.google.com/cdn)

---

## ## Runbook: Managed Instance Group (MIG) Deployment + Load Balancer

**The Goal:** The objective is to deploy a Global Application Load Balancer with integrated health checks and a fleet of self-healing, identical virtual machines that automatically scale based on user demand. By the end of this guide, you will have a resilient application layer that provides a single stable entry point and can survive the failure of an entire physical data center.

### **Prerequisites**

* Access to a GCP Project with billing enabled.
* A functional startup script (e.g., [supera.sh](https://github.com/BalericaAI/SEIR-1/blob/main/weekly_lessons/weeka/userscripts/supera.sh)).
* Necessary IAM permissions for Compute Engine and Network Services.

---

### **Execution Steps**

#### **1. Instance Template Creation**

1. Inside of GCP type "instance template" in the search bar.
2. Select **Create Instance Template**.
3. Name the template i.e `My-Test-Instance-Template`.
4. Locate "Firewall" (use `ctrl + f`) & select **Allow HTTP traffic**.
5. Select the dropdown for **Advanced options**, select **Management**, and locate the **Automation** (startup script) section.
6. Paste your script: [supera.sh](https://github.com/BalericaAI/SEIR-1/blob/main/weekly_lessons/weeka/userscripts/supera.sh).
7. Select **Create** and wait for completion.

#### **2. Instance Group (MIG) Setup**

1. Select **Instance Groups** > **Create Instance Group**.
2. Provide a name or use the default.
3. Select **Instance template** and choose your newly created template.
4. **Number of instances:** Choose `4`.
5. **Location:** Choose **Multiple zones** for HA and Fault Tolerance.
6. **Autoscaling:** Select **Configure Autoscaling**. Set the minimum number of instances (default is fine for testing).
7. **Autohealing:** Select **Health check** > **Create health check**.
8. Name it `my-health-check`, set scope to **Regional**, turn **Logs On**, and **Save**.
9. Select **Create** to initialize the Instance Group.
* *Note: Autohealing + health checks with logs enabled allows you to monitor app status beyond just the server running and assists with troubleshooting.*



#### **3. Load Balancer Configuration**

1. Search for **Network Services** & select **Create a load balancer**.
2. Under Type of load balancer keep the default (**Application Load Balancer**) & select **Next**.
3. Keep **Public facing (external)** selected & choose **Next**.
4. Select **Best for global workloads** for Step 3 & choose **Next**.
5. Select **Global external Application Load Balancer** & select **Next**.
6. Choose **Configure** to continue.
7. **Frontend Configuration:** Name it `my-frontend`. Keep defaults: Protocol (HTTP), IP version (IPv4), IP address (Ephemeral), and Port (80).
8. **Backend Configuration:** Name the service `my-backend-service`.
9. Set **Backend type** to **Instance group**.
10. **Health Check:** Select **Create a health check**, name it `my-backend-health-check`, keep defaults, and select **Create**.
11. **New Backend:** Under **Instance group**, choose the group you created and enter `80` for **Port numbers**. Keep all other defaults and select **Create**.
12. **Routing Rules:** Keep defaults. Verify **Backend 1** is your `my-backend-service`.
13. Select **Review and finalize**, verify your config, and select **Create**.

---

### **Cleanup / Destroy**

1. **Load Balancer:** Navigate to Load Balancing, select your ALB, and click **Delete**.
2. **Instance Groups:** Navigate to **Compute Engine > Instance Groups**. Select your group (e.g., `my-instance-groups`) and select the 3 dots for **Deletion**.
3. **Template:** All active resources are now destroyed. You may leave the Instance Template for future use as it incurs no cost.