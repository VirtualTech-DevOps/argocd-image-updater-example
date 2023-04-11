output "aws_region" {
  value = data.aws_region.current.name
}

output "role_to_assume" {
  value = aws_iam_role.github_oidc.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.private.repository_url
}

output "eksctl_cluster_config" {
  value = yamlencode({
    apiVersion = "eksctl.io/v1alpha5"
    kind       = "ClusterConfig"
    metadata = {
      name   = "poc"
      region = data.aws_region.current.name
      version : "1.25"
    }
    iam = {
      withOIDC = true
      serviceAccounts = [
        {
          metadata = {
            name      = "argocd-image-updater"
            namespace = "argocd"
          }
          attachPolicyARNs = [
            aws_iam_policy.argocd.arn
          ]
        }
      ]
    }
    vpc = {
      cidr = "10.64.0.0/16"
      clusterEndpoints = {
        privateAccess = true
        publicAccess  = true
      }
      nat = {
        gateway = "Single"
      }
    }
    addons = [
      {
        name = "vpc-cni"
      },
      {
        name = "coredns"
      },
      {
        name = "kube-proxy"
      }
    ]
    managedNodeGroups = [
      {
        name              = "ng-1"
        instanceType      = "t3.medium"
        desiredCapacity   = 3
        minSize           = 3
        maxSize           = 3
        volumeSize        = 20
        privateNetworking = true
        iam = {
          attachPolicyARNs = [
            "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
            "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
            "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
            "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
          ]
        }
      }
    ]
  })
}
