Este projeto foi desenvolvido como parte da disciplina de DevOps & CI/CD para implementar uma solução moderna de automação e gerenciamento na nuvem AWS. O objetivo foi criar e provisionar uma infraestrutura como código, configurar um pipeline CI/CD e executar uma aplicação conteinerizada no ECS (Elastic Container Service). 

A infraestrutura foi provisionada utilizando Terraform, organizada no repositório GitHub (em substituição ao CodeCommit) em três pastas principais: 

app: Contém o código Python de uma aplicação simples "Hello World" e o Dockerfile. 

infra: Contém o código Terraform para provisionar a infraestrutura da aplicação, incluindo a VPC, Subnet, ECS Cluster e ECR. 

pipe: Contém o código Terraform para configurar a pipeline CI/CD. 

Uma única pipeline CI/CD foi criada para gerenciar o deploy tanto da infraestrutura quanto da aplicação, utilizando: 

CodePipeline como orquestrador do fluxo. 

CodeBuild para criar imagens Docker a partir da aplicação e armazená-las no ECR (Elastic Container Registry). 

CodeDeploy para gerenciar o deploy das tarefas no ECS Cluster e provisionar a infraestrutura automaticamente. 

Essa abordagem garante uma automação completa do fluxo de deploy, integrando as melhores práticas de DevOps. A aplicação foi testada com sucesso e está acessível por meio do endereço público configurado na instância EC2. 