---
### This file describes the steps to deploy a new environment of Project solution ###

# Deploy ARM templates in a sequence provided by folder names.
When deploying to Azure Stack you might need to adjust the default values as the parameters files might not be lodaed properly. Use the "Template deployment" tool through Portal when deploying to Azure Stack. Some instructions can be found here:
https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy-portal#deploy-resources-from-custom-template

# After deployment finishes be sure to:
1. Change the default passwords and save them to key vault.
2. Create a Service Principal in Azure AD tenant and give access to Key Vault.
3. In App service update Application Settings so they contain proper values and secrets.
4. To deploy Graylog with ansible follow instructions:
    - Be sure the domain in inventory file points to VM WAN IP:
        - for dev set https://VMinAzure
    - Log in to the VM with your user credentials so ansible won't reject VMs fingerpting `ssh user@VM domain`
    - insert secrets into inventory.yml from respective key vaults
    - run ansible: ansible-playbook graylog-playbook.yml -i inventory.yml
    - Log into graylog example https://graylog-dev.domain.com/
    - Setup GELF endpoints, folder graylog-GELF, in System/Inputs -> Select input GELF HTTP -> Launch new input.
    - if you need to create new secrets or peppers have a look into README inside roles/Graylog2.graylog-ansible-role.
    - you might want to raise java heap size according to this instructions https://www.graylog.org/videos/java-heap.
5. Paste the graylog secrets into key vault and remove them from ansible-playbook.yml or inventory.yml.
6. Disable any SSH or RDP port access on VMs.
7. Add dedicated app to key vault access policy.
8. Apply migration on SQL Database.

---