# Screenshots Directory Guide

This folder contains the verification evidence for the **EWB Cloud Labs - AWS VPC Peering** project.

According to **Page 13 of the Student Workbook**, each screenshot should be clearly labeled and correspond to the project checklist.

---

### Folder Structure & Required Screenshots:

```text
screenshots/
├── 01_vpc_and_subnets/
│   ├── vpc_a_overview.png           # ewb-vpc-a (10.10.0.0/16)
│   ├── vpc_b_overview.png           # ewb-vpc-b (10.20.0.0/16)
│   └── subnets_list.png             # ewb-a-public, ewb-a-private, ewb-b-private
│
├── 02_internet_gateway/
│   └── igw_attached_vpc_a.png       # ewb-igw-a attached to ewb-vpc-a
│
├── 03_route_tables/
│   ├── rt_a_public.png              # Routes: 0.0.0.0/0 -> igw, 10.20.0.0/16 -> pcx
│   ├── rt_a_private.png             # Route: 10.20.0.0/16 -> pcx
│   └── rt_b_private.png             # Route: 10.10.0.0/16 -> pcx
│
├── 04_peering_connection/
│   └── peering_status_active.png    # ewb-a-b-peer showing 'Active' status
│
├── 05_security_groups/
│   ├── sg_bastion_inbound.png       # Port 22 allowed from Admin IP /32
│   ├── sg_app_a_inbound.png         # Port 22 from Bastion (10.10.1.10/32), ICMP from App-B
│   └── sg_app_b_inbound.png         # Port 22 from Bastion (10.10.1.10/32), ICMP from App-A
│
├── 06_ec2_instances/
│   ├── ec2_instances_list.png       # ewb-bastion, ewb-app-a, ewb-app-b running
│   └── private_instances_no_ip.png  # Verifying App-A and App-B have NO public IPv4
│
├── 07_test_verifications/
│   ├── test01_baseline_failure.png  # ping from App-A to App-B fails before peering routes
│   ├── test02_forward_ping.png      # ping from App-A to App-B succeeds (0% loss)
│   ├── test03_reverse_ping.png      # ping from App-B to App-A succeeds (0% loss)
│   └── test04_ssh_proxyjump.png     # Laptop -> Bastion -> App-B SSH shell
│
├── 08_controlled_failure/
│   ├── icmp_rule_removed_fail.png   # 100% packet loss after removing ICMP rule on App-B
│   └── icmp_rule_restored_pass.png  # 0% packet loss after restoring rule
│
└── 09_cleanup/
    └── instances_terminated.png     # EC2 instances terminated and VPCs deleted
```

> **Note:** When you perform the lab in your AWS Console, take a screenshot of each section and save it with the respective file name above.
