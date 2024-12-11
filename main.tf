/*resource "prismacloud_user_role" "example" {
  name        = "lombac user role"
  role_type = "Account Group Admin"
  description = "Made by Terraform"
} 
*/
/*
You can also create user roles from a CSV file using native Terraform
HCL and looping.  Assume you have a CSV file (user_roles.csv) of user roles that looks like this (with
"||" separating account group IDs from each other):

"name","description","roletype","account_group_ids","restrict_dismissal_access","only_allow_ci_access","only_allow_read_access","has_defender_permissions","only_allow_compute_access"
"test_role1","Made by Terraform","System Admin",,false,false,false,true,false
"test_role2","Made by Terraform","Account Group Admin","11111111-2222-3333-4444-555555555555||12345678-2222-3333-4444-555555555555",false,false,false,false,false
"test_role3","Made by Terraform","Account Group Read Only","12345678-2222-3333-4444-555555555555",true,false,true,false,false
"test_role4","Made by Terraform","Cloud Provisioning Admin","12345678-2222-3333-4444-555555555555",true,false,false,true,false
"test_role5","Made by Terraform","Build and Deploy Security",,true,false,false,false,false
"test_role6","Made by Terraform","Account and Cloud Provisioning Admin","12345678-2222-3333-4444-555555555555",false,false,false,false,false

Here's how you would do this:
*/
locals {
    user_roles = csvdecode(file("user_roles.csv"))
}

// Now specify the user role resource with a loop like this:
resource "prismacloud_user_role" "example" {
    for_each = { for inst in local.user_roles : inst.name => inst }

    name = each.value.name
    description = each.value.description
    role_type = each.value.roletype
    restrict_dismissal_access = each.value.restrict_dismissal_access
    account_group_ids = (each.value.roletype == "System Admin" || each.value.roletype == "Build and Deploy Security") ? [] : split("||", each.value.account_group_ids)
    /*additional_attributes {
        only_allow_ci_access = each.value.only_allow_ci_access
        only_allow_read_access = each.value.only_allow_read_access
        has_defender_permissions = each.value.has_defender_permissions
        only_allow_compute_access = each.value.only_allow_compute_access
    } */ 
}