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
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineFullAccess"
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