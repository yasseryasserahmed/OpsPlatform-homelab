AWS PlatformOps Homelab — Architecture and Learning Runbook
Scope: detailed architecture and implementation steps, not ready-to-run code or configuration files. Use this as a learning plan and record your own decisions and commands as you progress.

1. Mission and learning outcomes
Build a small but credible PlatformOps platform on one AWS EC2 m7i-flex.large instance. The lab should teach infrastructure lifecycle, host configuration, Kubernetes operations, GitOps, edge networking, automated TLS, CI/CD, observability, security, and reproducible recovery.
By completion, you should be able to explain and demonstrate:
- Terraform plans, applies, state, drift, variables, outputs, dependency ordering, and teardown.
- Ansible inventory, roles, idempotence, handlers, privilege escalation, and repeatable host bootstrap.
- Bash pre-flight checks, safe wrappers, health checks, clear exit codes, and guarded destructive actions.
- Linux service management, logs, storage pressure, memory limits, access control, patching, and recovery.
- Kubernetes Deployments, Pods, Services, probes, resource requests/limits, namespaces, RBAC, rollouts, and troubleshooting.
- Argo CD reconciliation, sync, health, drift detection, self-healing, pruning, and Git-based rollback.
- DNS, security groups, NGINX proxying, Kubernetes Gateway API, HTTP routing, TLS termination, and certificates.
- CI validation, immutable image tags, image publishing, GitOps promotion, and release rollback.
- Metrics, dashboards, useful alerts, incident notes, cost controls, and rebuild procedures.
2. Recommended architecture
2.1 Compute and cluster choice
Use one Ubuntu LTS EC2 m7i-flex.large host (2 vCPU and 8 GiB RAM) with EBS storage sized for the operating system, container images, logs, and temporary artifacts. Run K3s as a single-node Kubernetes distribution. This is intentionally a compact lab, not a high-availability design. Check the instance's availability and current pricing in your chosen region before provisioning. AWS lists the instance at 2 vCPU and 8 GiB RAM: https://docs.aws.amazon.com/ec2/latest/instancetypes/gp.html
Start with only the essential services. A full monitoring stack, multiple application stacks, Argo CD, a gateway controller, cert-manager, and build agents can pressure 8 GiB of memory. Prefer running CI on a hosted runner, not on the EC2 node. Add heavier observability only after the base platform is stable.
2.2 Logical components
1. Developer workstation: Git, Terraform CLI, Ansible, AWS CLI, an SSH/SSM client, and editor.
2. Git hosting: source, Terraform, Ansible, scripts, platform desired state, app desired state, documentation, and decision records.
3. AWS account: human IAM identity, MFA, billing budget and alerts, chosen region, and a tagged lab resource set.
4. Terraform: VPC, public subnet, internet gateway, route table, security group, EC2 instance, instance role/profile, and EBS storage.
5. Administrative access: prefer AWS Systems Manager Session Manager. If using SSH, allow TCP/22 only from your current trusted IP. Never expose Kubernetes API port 6443 to the internet.
6. Ansible: baseline OS configuration, packages, safe host settings, prerequisites, K3s installation, and post-install validation.
7. K3s: one server node that also runs application workloads. The single node is a deliberate availability limitation.
8. Argo CD: watches the Git repository and reconciles Kubernetes resources toward the desired state stored in Git.
9. NGINX Gateway Fabric + Kubernetes Gateway API: routes public HTTP/HTTPS traffic to application Services. Avoid starting a new deployment with the retired community ingress-nginx controller.
10. cert-manager: requests and renews TLS certificates using ACME. Public certificates need a valid DNS name and a reachable challenge method.
11. Sample application: small stateless app with readiness/liveness probes, requests/limits, and a Kubernetes Service.
12. Observability: first use Kubernetes events, logs and resource commands; later add one lightweight metrics/dashboard solution and a few useful alerts.
2.3 Traffic path
Browser → DNS → EC2 public IPv4 → security group (80/443) → NGINX Gateway Fabric listener → Gateway/HTTPRoute → Service → application Pod
TLS may terminate at the gateway with a certificate managed by cert-manager. Keep Argo CD, Grafana, Prometheus, and the Kubernetes API private at first. Reach administration tools using SSM port forwarding, a VPN, or a temporary tightly restricted route. Do not publish sensitive admin interfaces just because they are convenient to reach.
2.4 Delivery/control path
Code commit → CI checks/tests → image build → image registry → reviewed desired-image change in Git → Argo CD reconcile → Kubernetes rollout → health verification
Ownership boundaries are important:
- Terraform owns AWS infrastructure.
- Ansible owns host configuration and K3s bootstrap.
- Argo CD owns declared Kubernetes application/platform resources.
- CI builds and publishes artifacts; it should not normally bypass GitOps by applying directly to the live cluster.
- Bash orchestrates safe operator workflows; it should not duplicate Terraform or Ansible logic.
2.5 Why not EKS immediately?
A single EC2/K3s lab avoids managed control-plane cost and helps you learn the platform internals. It does not teach the full EKS control plane, managed node groups, AWS Load Balancer Controller, EKS IAM integration, or multi-AZ production patterns. Add EKS as a separate, budget-reviewed advanced exercise after you understand the base lab.
2.6 Why Gateway API instead of ingress-nginx?
The Kubernetes project announced that community Ingress NGINX would be retired in March 2026, with no further bug fixes or security releases after retirement. For a new lab, use a currently supported Gateway API implementation such as NGINX Gateway Fabric, and verify its current version compatibility before installing it. The Gateway API concepts to learn are GatewayClass, Gateway, HTTPRoute, listeners, hostnames, parent references, and backend references. Official notice: https://kubernetes.io/blog/2026/01/29/ingress-nginx-statement/
3. Cost and safety guardrails
Cloud labs are not automatically free. Cost depends on region, runtime, OS, storage, public IPv4, traffic, snapshots, DNS/domain services, and optional managed services.
Before applying Terraform:
- Pick one region and verify m7i-flex.large is available there.
- Estimate EC2 runtime, EBS, public IPv4, data transfer, snapshots, and domain/DNS costs.
- Create an AWS Budget and billing alerts before creating resources.
- Tag resources consistently, for example with project and environment tags.
- Use short-lived human credentials where possible; enable MFA and avoid using root for routine work.
- Give the instance only the IAM permissions needed for SSM and the lab's actual tasks. Do not attach broad administrator access to the instance role.
- Keep static AWS access keys off the EC2 host and out of Git.
- Open TCP/80 and TCP/443 only when ready to test public web access.
- Do not expose TCP/6443, etcd, node ports, Argo CD, Prometheus, Grafana, SSH, or other admin endpoints to the world.
- Never commit private keys, kubeconfig files, ACME secrets, registry credentials, Terraform state, or passwords.
- Stop or destroy the lab when not needed. Stopping can reduce compute charges but does not necessarily remove EBS or public IPv4 charges.
- Review the Terraform destroy plan and check retained volumes, snapshots, DNS records, and reserved addresses before teardown.
A NAT Gateway is not needed for the simplest lab and can add recurring cost. This design uses a public subnet for simplicity, so compensate with restrictive security groups and avoid placing sensitive databases or production data on the host. A private-subnet variant is a later exercise, after a cost review.
4. Repository organization
Start small; add directories when the corresponding phase begins. A reasonable target structure is:
- docs/: architecture, diagrams, decision log, cost checklist, runbooks, incident records, and troubleshooting.
- terraform/: provider/version constraints, variables, networking, security group, IAM/instance profile, EC2, storage, outputs, and environment-specific values.
- ansible/: inventory, group variables, base-host role, access role, packages role, K3s bootstrap role, and validation role.
- scripts/: pre-flight, tool/version check, Terraform workflow helper, Ansible workflow helper, cluster health check, endpoint test, and guarded destroy helper.
- platform/: desired state and release notes for Argo CD, Gateway API implementation, cert-manager, and optional observability.
- apps/: sample app deployment definitions and application notes.
- CI workflow definitions: formatting, linting, tests, image build, scanning, and publishing.
- README.md: overview, architecture, prerequisites, phase tracker, and links to the runbooks.
Keep secrets outside the repository. Document how each secret is supplied without writing the secret value into the documentation.
5. Tool ownership matrix
Tool	Owns	Does not own
Terraform	AWS network, EC2, IAM role/profile, security groups, EBS, outputs	OS configuration or application release state
Ansible	Linux baseline, packages, host settings, K3s installation and validation	AWS resource lifecycle or Kubernetes app releases
Bash	Safe operator workflow, pre-flight and health checks	Duplicating IaC/configuration-management logic
Git	Versioned source, desired state, docs, decisions	Secrets and generated state
CI	Validation, tests, image build/scan/publish	Uncontrolled direct changes to live cluster
Argo CD	Kubernetes reconciliation from Git	EC2 provisioning or host OS setup
NGINX Gateway Fabric	Gateway listeners, routes, edge proxy	Certificate lifecycle by itself
cert-manager	Certificate requests, issuers, renewals	DNS ownership or firewall changes
Kubernetes	Scheduling, service discovery, rollouts, probes, RBAC	Cloud billing governance or source CI
Monitoring	Metrics, dashboards, alerts and later logs	Replacing root-cause analysis or backups


6. Implementation phases
Phase 0 — Workstation and AWS account preparation
Goal: establish a safe operator environment before creating billable resources.
1. Install Git, Terraform, Ansible, AWS CLI, a Bash-compatible shell, and SSH/SSM tooling.
2. Record tool versions in the lab notes. Decide how versions will be pinned and updated.
3. Configure AWS CLI with an IAM Identity Center profile or another approved short-lived credential method. Do not use root credentials for daily tasks.
4. Enable MFA for the human identity and verify the active account and region before each infrastructure operation.
5. Select a region; record the reason and confirm instance availability there.
6. Create a billing budget and alerts. Understand what they can and cannot guarantee; alerts are not a hard spending cap.
7. Create the Git repository and record the architecture and cost assumptions before provisioning.
8. Define tags and naming rules so all billable resources are identifiable.
9. Decide whether you have a domain name. Without a valid DNS name, begin with internal/test routing and do not expect a public ACME certificate.
Exit criteria: authentication works, billing alerts exist, the repo has architecture and cost notes, and no infrastructure has been created yet.
Phase 1 — Terraform: minimum AWS foundation
Goal: create and destroy the same foundation predictably.
1. Configure the AWS provider and pin Terraform/provider versions deliberately.
2. Define inputs for region, instance type, AMI selection, EBS size, admin CIDR if SSH is used, and tags.
3. Create a VPC with a small documented CIDR, one public subnet, an internet gateway, and a route table.
4. Define a security group. Start with administration only; add HTTP/HTTPS in the later routing phase.
5. Create an IAM role and instance profile appropriate for Systems Manager. Avoid broad permissions.
6. Create the EC2 instance with an Ubuntu LTS AMI and m7i-flex.large.
7. Choose EBS size based on OS, image layers and logs; disk is billable separately from compute.
8. Output only useful non-secret values such as instance ID, region, and address.
9. Run formatting and validation, inspect the plan carefully, and then apply.
10. Verify instance health and secure administrative access.
11. Run a plan again and explain any unexpected changes. Practice reading a destroy plan, but do not destroy until access is verified and you understand what will be removed.
12. Record every created resource and the cleanup path.
Exit criteria: the plan is understandable, the host is reachable through the chosen safe path, a second plan has no unintended changes, and teardown is documented.
Learning notes: understand state, drift, dependency graphs, variables, outputs, provider constraints, and why state must not be committed. Local state may be acceptable for a solo initial lab if stored securely. A remote backend with locking is a later exercise; it has its own lifecycle and possible costs.
Phase 2 — Ansible: repeatable host configuration
Goal: rebuild a configured host without a long sequence of manual SSH commands.
1. Decide how Ansible connects: an SSM-based workflow if supported by your setup, or SSH restricted to your trusted IP.
2. Create an inventory that identifies the lab host without storing secrets.
3. Add a base-host role for updates, essential packages, time synchronization, access policy, and safe OS settings.
4. Add only the prerequisites required by the selected K3s installation method.
5. Add a K3s bootstrap role with an explicit version and a clear single-node server design.
6. Add validation tasks for service health, versions, disk space, memory, and Kubernetes readiness.
7. Use handlers for changes requiring service restarts and design tasks to be idempotent.
8. Keep secrets out of ordinary variables. Use Ansible Vault only where it solves a real need; keep the vault password outside Git.
9. Run syntax checks and dry-run/check mode where useful before changing the host.
10. Run the playbook twice and investigate unexpected changes on the second run.
11. Rebuild the instance and repeat to prove the process is reproducible.
Exit criteria: host setup is repeatable and validated; the second Ansible run is effectively idempotent; manual exceptions are documented.
Phase 3 — Bash: safe operator workflows
Goal: automate repetitive checks without obscuring what the underlying tools do.
Create separate small scripts for:
- Pre-flight: required commands, active AWS identity, region, repository root, and required environment variables.
- Terraform workflow: formatting, validation, workspace/target display, plan output, and explicit approval before apply.
- Ansible workflow: syntax check and playbook execution against the intended inventory.
- Cluster health: node readiness, system pods, failed workloads, disk pressure, and memory pressure.
- Endpoint verification: request the test hostname and report status clearly.
- Destroy guard: show account, region, instance ID, and tags; require explicit confirmation; then show the Terraform destroy plan.
Use strict error handling, quote variables, avoid printing secrets, return meaningful exit codes, and print enough context to troubleshoot. A wrapper should call Terraform/Ansible, not reimplement their logic. Destructive scripts must fail closed when identity or region checks fail.
Exit criteria: each script has a purpose, prerequisites, failure behavior, and manual equivalent documented in the README.
Phase 4 — K3s and Kubernetes fundamentals
Goal: learn the cluster before adding GitOps and public routing.
1. Install K3s through Ansible and pin the version.
2. Keep the Kubernetes API available only through the administrative path; never expose port 6443 publicly.
3. Establish a safe kubeconfig workflow. Treat kubeconfig as a credential and never commit it.
4. Learn namespaces, Pods, Deployments, ReplicaSets, Services, ConfigMaps, Secrets, probes, requests/limits, labels, selectors, and RBAC.
5. Deploy a simple stateless test app manually for learning; later move its desired state into Git.
6. Test rolling updates, a bad image tag, readiness failure, pod deletion, restart behavior, and rollback.
7. Practice diagnosing Pending, CrashLoopBackOff, ImagePullBackOff, failed probes, and insufficient resources.
8. Set requests and limits on every workload. The node is constrained, so install optional components incrementally.
9. Learn storage classes and persistent volumes, but keep the first app stateless. Data on one EC2 host is not highly available.
10. Reboot the host deliberately during a maintenance window and verify cluster recovery.
Exit criteria: you can deploy, inspect, break, and recover a workload using Kubernetes tools and explain the request path.
Phase 5 — Argo CD: GitOps control loop
Goal: Git becomes the source of truth for desired Kubernetes state.
1. Install Argo CD using a supported method and pin its release.
2. Keep the UI/API private initially. Use port forwarding over the administrative path rather than a public unauthenticated endpoint.
3. Define separate logical paths for platform components and apps, even if both live in one repository.
4. Connect Argo CD to Git with least-privilege access; prefer read-only repository access where possible.
5. Start with one application definition pointing to the sample app's desired state.
6. Compare manual sync and automated sync. Understand pruning and self-healing before enabling them.
7. Change a replica count or image version in Git and observe Argo CD reconcile it.
8. Change a live object manually and observe drift detection and reconciliation.
9. Practice a bad commit, failed health check, Git revert, and recovery.
10. Add platform components only after the app works. Document dependency ordering; controllers and CRDs may need time to become ready.
11. Keep bootstrap ownership clear: Ansible installs K3s; a documented bootstrap step installs Argo CD; Argo CD manages declared platform/app resources afterward.
Exit criteria: a reviewed Git change drives a rollout, drift is visible, and normal recovery occurs through Git rather than untracked live edits.
Phase 6 — DNS, NGINX Gateway Fabric, and routing
Goal: publish one low-risk app over HTTP, then add HTTPS.
1. Choose a DNS name and create an A record pointing to the EC2 public IPv4 address. Consider address changes after stop/start or replacement; a stable address may have cost implications.
2. Open inbound TCP/80 and TCP/443 only when ready to test public web traffic.
3. Install Gateway API CRDs and a supported NGINX Gateway Fabric release after checking its current compatibility matrix.
4. Learn GatewayClass, Gateway, HTTPRoute, listeners, hostnames, parent references, and backend references.
5. Define one route: hostname → route → Service → Pod.
6. Test a harmless app over HTTP before configuring TLS.
7. Verify DNS, listener/programmed status, route attachment, Service endpoints, and backend health as separate checks.
8. Test unknown hostnames and missing routes. Do not route arbitrary hostnames to admin interfaces.
9. Keep Argo CD and observability tools private unless you intentionally add authentication, TLS, and restricted access.
10. Distinguish network access controls (security group), gateway route policy, and application-level authorization.
Exit criteria: one test hostname reaches only the intended application; sensitive services and the Kubernetes API are not public.
Phase 7 — cert-manager and HTTPS
Goal: automate issuance and renewal instead of copying certificates manually.
1. Install cert-manager using the current supported method and pin the release.
2. Learn Issuer, ClusterIssuer, Certificate, Secret, CertificateRequest, Order, and Challenge.
3. Start with an ACME staging issuer to debug safely and avoid production rate limits.
4. Choose HTTP-01 or DNS-01. HTTP-01 needs a reachable challenge path on port 80. DNS-01 needs controlled DNS API access and carefully scoped credentials.
5. Keep DNS API credentials out of Git and grant only the permissions required to validate the chosen zone.
6. Verify issuer readiness, certificate readiness, hostname/SAN, validity, and the Secret reference used by the gateway.
7. Test HTTPS externally, validate hostname and certificate chain, then add HTTP-to-HTTPS redirection.
8. Observe renewal behavior and learn to read challenge events.
9. Write a certificate-expiry/renewal troubleshooting runbook.
10. Do not expect public trust for an invalid hostname or a self-signed certificate.
Exit criteria: the test hostname serves valid HTTPS, certificate status is visible, and the renewal process is understood.
Phase 8 — CI/CD and image lifecycle
Goal: build an artifact once, then promote it through Git.
1. Keep app source and platform configuration logically separate.
2. Add CI checks for formatting, tests, static analysis, and container build.
3. Use immutable image tags such as a commit SHA; do not rely on latest for releases.
4. Publish to a registry. A public registry is simplest; a private registry adds credential, storage, and transfer considerations.
5. Keep registry credentials out of Git and use short-lived or narrowly scoped access where possible.
6. Have CI publish the image, then update the desired version in Git through a reviewed change or controlled automation.
7. Let Argo CD deploy from Git; avoid direct CI kubectl apply as the normal delivery path.
8. Verify rollout status and the app's health endpoint after promotion.
9. Add image scanning and dependency checks once the basic pipeline works.
10. Practice a failed build, bad release, and rollback by reverting the desired version in Git.
Exit criteria: source change → CI → image publish → Git promotion → Argo CD rollout → health check is repeatable and auditable.
Phase 9 — Observability and incident response
Goal: detect and diagnose failures without exhausting the host.
1. Start with Kubernetes events, workload logs, system logs, and resource usage.
2. Add one lightweight metrics/dashboard stack after the app, gateway, and Argo CD are stable.
3. Set conservative resource limits and a short retention period appropriate to the lab.
4. Monitor node CPU, memory, disk, pod restarts, rollout failures, certificate expiry, and HTTP success/failure.
5. Create a small set of actionable alerts: node not ready, disk pressure, application unavailable, and certificate nearing expiry.
6. Add log aggregation only if the host has enough headroom; logs can consume substantial disk and memory.
7. Create incident runbooks with symptom, initial checks, likely causes, mitigation, recovery, and follow-up.
8. Simulate a bad image, wrong route hostname, failed certificate challenge in a test setup, low disk, and readiness failure.
9. Capture evidence and write a short root-cause explanation after each exercise.
Exit criteria: you can detect a deliberate failure, identify the layer responsible, recover, and document the incident.
Phase 10 — Security, backups, and rebuildability
1. Review human IAM and EC2 instance-role permissions.
2. Review every inbound security-group rule and verify no sensitive port is public.
3. Remove or rotate credentials used during experiments.
4. Store Terraform state and backups securely; state may contain sensitive values.
5. Decide what is disposable and what must be backed up. Git stores desired state, not runtime secrets or application data.
6. If persistent data is added, define backup frequency, retention, restore steps, and test restores. A snapshot is not proven until restored.
7. Rebuild from a fresh instance using Terraform, Ansible, and the documented bootstrap sequence.
8. Record recovery time and remaining manual steps.
9. Verify which resources survive destruction: volumes, snapshots, DNS, and reserved addresses.
10. Review the AWS bill after each experiment.
Exit criteria: the lab can be rebuilt from docs, secrets are absent from Git, and cleanup has been tested.
7. Milestone sequence
- M1 — Foundation: AWS identity, budget, repository, Terraform creates one host, secure access works.
- M2 — Reproducible host: Ansible configures OS and K3s; second run is idempotent.
- M3 — Kubernetes basics: deploy and troubleshoot an app; understand Services, probes, and limits.
- M4 — GitOps: Argo CD reconciles from Git; demonstrate drift and rollback.
- M5 — Routing: DNS and NGINX Gateway Fabric route one hostname to the app.
- M6 — TLS: cert-manager obtains and renews a valid certificate.
- M7 — Delivery: CI publishes immutable images; Git promotion triggers deployment.
- M8 — Operations: metrics, alerts, incident runbooks, restore exercise, and full rebuild.
- M9 — Advanced extension: EKS, private subnets, multi-node topology, remote Terraform state, policy-as-code, secrets management, and progressive delivery.
8. Definition of done checklist
- [ ] Terraform can create and destroy the AWS foundation predictably.
- [ ] AWS budget/alerts and cleanup checklist are active.
- [ ] Admin access is restricted; Kubernetes API is not public.
- [ ] Ansible builds host and K3s from a fresh instance and is idempotent.
- [ ] Bash helpers fail safely and leave underlying commands understandable.
- [ ] Sample app has probes and resource requests/limits.
- [ ] Argo CD reconciles desired state from Git and exposes drift.
- [ ] Gateway routes one public hostname to the correct Service.
- [ ] cert-manager provisions valid TLS and renewal is understood.
- [ ] CI publishes immutable image versions and promotion is auditable.
- [ ] At least three deliberately introduced failures have been diagnosed and recovered.
- [ ] Lab can be rebuilt from the repository and docs.
- [ ] Teardown has been tested and billable leftovers checked.
9. Troubleshooting by layer
AWS/network: Is the instance running? Is the route table attached to an internet gateway? Does the security group allow only intended ports? Does DNS resolve to the current address? Is the instance role correct?
Host: Is the filesystem full? Is memory exhausted? Are K3s and the runtime healthy? Are time and package repositories working? What do system logs say?
Kubernetes: Is the node Ready? Are system pods healthy? Can requests be scheduled? Is the image tag correct? Do probes match the app endpoint? Does the Service selector match pod labels?
Argo CD: Is repository access valid? Is the target path correct? Are manifests valid? Is the app out of sync, unhealthy, or waiting on a dependency? Did pruning or self-healing cause the change?
Gateway/DNS: Does DNS resolve correctly? Is the Gateway programmed and listener accepted? Is the route attached to the listener? Does the backend Service have endpoints? Are hostnames and ports consistent?
cert-manager: Is the issuer Ready? Is the challenge method reachable? Is DNS correct? Are staging and production ACME endpoints mixed? Does the gateway reference the expected Secret? Do events show rate limiting or authorization failure?
CI/CD: Did tests pass? Was the image published? Is the tag immutable and correct? Did desired state change in Git? Did Argo CD reconcile it? Is the app healthy after rollout?
10. Official documentation to consult during implementation
Check current supported versions and compatibility at implementation time.
- AWS EC2 instance types: https://docs.aws.amazon.com/ec2/latest/instancetypes/gp.html
- AWS Systems Manager Session Manager: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html
- AWS Budgets: https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html
- Terraform AWS provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- Ansible documentation: https://docs.ansible.com/
- K3s documentation: https://docs.k3s.io/
- Kubernetes concepts: https://kubernetes.io/docs/concepts/
- Argo CD documentation: https://argo-cd.readthedocs.io/
- Kubernetes Gateway API: https://gateway-api.sigs.k8s.io/
- NGINX Gateway Fabric: https://docs.nginx.com/nginx-gateway-fabric/
- cert-manager: https://cert-manager.io/docs/
- Ingress NGINX retirement statement: https://kubernetes.io/blog/2026/01/29/ingress-nginx-statement/
11. Operating rule
Build one layer, verify it, document it, then add the next. Do not install Terraform, Ansible, K3s, Argo CD, Gateway API, cert-manager, CI/CD, and monitoring in one large step. The value of this lab is your ability to explain ownership boundaries, diagnose failures, and rebuild it—not the number of tools installed.