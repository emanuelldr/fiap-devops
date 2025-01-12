# Role para o CodePipeline
resource "aws_iam_role" "codepipeline_role" {
  name = "CLD34-devops-final-CodePipeline-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "codepipeline_policy" {
  name       = "attach-codepipeline-policy"
  roles      = [aws_iam_role.codepipeline_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

# Role para o CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "CLD34-devops-final-CodeBuild-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "codebuild_policy" {
  name       = "attach-codebuild-policy"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_s3_bucket_policy" "pipeline_bucket_policy" {
  bucket = aws_s3_bucket.pipeline_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCodePipelineAccess",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::058264065873:role/CLD34-devops-final-CodePipeline-Role"
        },
        Action    = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource  = [
          "${aws_s3_bucket.pipeline_bucket.arn}",
          "${aws_s3_bucket.pipeline_bucket.arn}/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "codepipeline_codebuild_policy" {
  name = "CodePipelineCodeBuildPolicy"
  role = aws_iam_role.codepipeline_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "codebuild:BatchGetProjects",
          "codebuild:ListBuildsForProject"
        ],
        Resource = "arn:aws:codebuild:us-east-1:058264065873:project/CLD34-devops-final-Build"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_logging_policy" {
  name = "CodeBuildLoggingPolicy"
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:us-east-1:058264065873:log-group:/aws/codebuild/*",
          "arn:aws:logs:us-east-1:058264065873:log-group:/aws/codebuild/*:log-stream:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_s3_policy" {
  name = "CodeBuildS3Policy"
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::cld34-devops-final-pipeline-bucket",           # Permissão para listar o bucket
          "arn:aws:s3:::cld34-devops-final-pipeline-bucket/*"         # Permissão para acessar objetos específicos
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_ecr_policy" {
  name = "CodeBuildECRPolicy"
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:CreateRepository"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_codebuild_project" "build" {
  name          = "CLD34-devops-final-Build"
  service_role  = aws_iam_role.codebuild_role.arn

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "S3"
    location  = "arn:aws:s3:::cld34-devops-final-pipeline-bucket/buildspec.yml"
  }

  artifacts {
    type                = "S3"
    location            = "cld34-devops-final-pipeline-bucket"  # Nome do bucket S3
    path                = "artifacts"                          # Subpasta no bucket
    packaging           = "ZIP"                                # Opcional: compactar os artefatos
    override_artifact_name = true                              # Permite nome personalizado
    artifact_identifier = "build-output"                       # Identificador opcional
  }
}

resource "aws_iam_role_policy" "codebuild_ec2_policy" {
  name = "CodeBuildEC2AccessPolicy"
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ec2:CreateVpc",
          "ec2:ModifyVpcAttribute",
          "ec2:DescribeVpcs",
          "ec2:CreateTags",
          "ec2:DescribeSubnets",
          "ec2:CreateSubnet",
          "ec2:DescribeRouteTables",
          "ec2:CreateRouteTable",
          "ec2:CreateRoute",
          "ec2:AssociateRouteTable",
          "ec2:DescribeSecurityGroups",
          "ec2:CreateSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_ecs_policy" {
  name = "CodeBuildECSAccessPolicy"
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecs:CreateCluster",
          "ecs:DeleteCluster",
          "ecs:DescribeClusters",
          "ecs:ListClusters",
          "ecs:TagResource",
          "ecs:UntagResource",
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition",
          "ecs:DescribeTaskDefinition",
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:ListTasks",
          "ecs:DescribeTasks",
          "ecs:UpdateClusterSettings",
          "ecs:PutClusterCapacityProviders"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy" "codebuild_iam_policy" {
  name = "CodeBuildIAMAccessPolicy"
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:GetRole",
          "iam:DeleteRole",
          "iam:ListRolePolicies",
          "iam:DeleteRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:PassRole"
        ],
        Resource = [
          "arn:aws:iam::058264065873:role/CLD34-devops-final-ECS-Instance-Role",
          "arn:aws:iam::058264065873:role/*"
        ]
      }
    ]
  })
}
